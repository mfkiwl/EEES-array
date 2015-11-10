#include "BaselineInitCodeEmitter.hh"
#include "BaselineFuncData.hh"
#include "BaselineBlockData.hh"
#include "BaselineInstrData.hh"
#include "BaselineBasicInfo.hh"
#include "BaselineModuleData.hh"
#include "SIR/SIRRegister.hh"
#include "SIR/SIRConstant.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRFunction.hh"
#include "SIR/SIRDataObject.hh"
#include "SIR/SIRModule.hh"
#include "Utils/BitUtils.hh"
#include "Utils/DbgUtils.hh"

using namespace std;
using namespace ES_SIMD;

BaselineInitCodeEmitter::~BaselineInitCodeEmitter() {}

bool BaselineInitCodeEmitter::
RunOnSIRModule(SIRModule* m) {
  bool changed = false;
  SIRFunction* ent = m->GetEntryFunction();
  if (!ent || ((ent->GetName() != "main") && (ent->GetName() != "__start"))) {
    errors_.push_back(
      Error(ErrorCode::LinkingFailure,
            "Cannot find entry function (main or __start)"));
    return false;
  }
  if (ent && ent->GetName() == "__start") { return changed; }
  BaselineModuleData* mData = dynamic_cast<BaselineModuleData*>(
    m->GetTargetData());
  const int cpWordSize = target_.GetCPDataWidth() / 8;
  const int peWordSize = target_.GetPEDataWidth() / 8;
  const int cpMemSize  = target_.GetCPDMemDepth() * cpWordSize;
  const int peMemSize  = target_.GetPEDMemDepth() * peWordSize;
  SIRFunction* init = new SIRFunction("__start", m);
  SIRBasicBlock* initBB = new SIRBasicBlock(0, init);
  init->push_back(initBB);
  mData->InitTargetData(init);
  BaselineBlockData* bData = dynamic_cast<BaselineBlockData*>(
    mData->InitTargetData(initBB));
  initBB->SetTargetData(bData);
  init->GetStackPointer()->SetValueID(init->AllocateValue());
  if (SIRDataObject* hs = m->GetDataObject("__heap_start")) {
    SIRDataType_t hpType
      = (cpWordSize == 2) ? SIRDataType::Int16 : SIRDataType::Int32;
    hs->AddInit(hpType, max(mData->GetCPDataMemoryUsage(), 16));
  }

  // Initialize CP stack pointer
  SIRInstruction* cSPInit = new SIRInstruction(TargetOpcode::ADD,initBB,false);
  cSPInit->SetValueID(init->GetStackPointer()->GetValueID());
  cSPInit->AddOperand(init->GetZeroRegister());
  bool fit = target_.ImmCanFit(TargetOpcode::ADD, false, cpMemSize);
  SIRInstruction* immInstr = NULL;
  uint32_t cSPImm = static_cast<uint32_t>(cpMemSize);
  if (!fit) {
    immInstr = new SIRInstruction(TargetOpcode::SIMM, initBB, false);
    unsigned ibits = target_.GetImmSize(cSPInit);
    uint32_t high = cSPImm >> ibits;
    cSPImm  = ExtractBitsFromWord(cSPImm, 0, ibits-1);
    mData->InitTargetData(immInstr);
    immInstr->AddOperand(init->GetParent()->AddOrGetImmediate(high));
  }// if (!fit)
  cSPInit->AddOperand(init->GetParent()->AddOrGetImmediate(cSPImm));
  BaselineInstrData* cSPData = dynamic_cast<BaselineInstrData*>(
    mData->InitTargetData(cSPInit));
  cSPData->SetDestPhyReg(1);
  cSPData->SetOperandPhyReg(0, 0);
  if (immInstr) { bData->InsertBefore(bData->end(), immInstr); }
  bData->InsertBefore(bData->end(), cSPInit);

  // Initialize PE stack pointer
  if (peMemSize > 0) {
    SIRInstruction* pSPInit=new SIRInstruction(TargetOpcode::ADD,initBB,false);
    pSPInit->SetValueID(init->GetStackPointer()->GetValueID());
    pSPInit->AddOperand(init->GetZeroRegister());
    bool fit = target_.ImmCanFit(TargetOpcode::ADD, false, peMemSize);
    SIRInstruction* immInstr = NULL;
    uint32_t pSPImm = static_cast<uint32_t>(peMemSize);
    if (!fit) {
      immInstr = new SIRInstruction(TargetOpcode::SIMM, initBB, false);
      unsigned ibits = target_.GetImmSize(pSPInit);
      uint32_t high = pSPImm >> ibits;
      pSPImm  = ExtractBitsFromWord(cSPImm, 0, ibits-1);
      mData->InitTargetData(immInstr);
      immInstr->AddOperand(init->GetParent()->AddOrGetImmediate(high));
    }// if (!fit)
    pSPInit->AddOperand(init->GetParent()->AddOrGetImmediate(pSPImm));
    BaselineInstrData* pSPData = dynamic_cast<BaselineInstrData*>(
      mData->InitTargetData(pSPInit));
    pSPData->SetDestPhyReg(2);
    pSPData->SetOperandPhyReg(0, 0);
    if (immInstr) { bData->InsertBefore(bData->end(), immInstr); }
    bData->InsertBefore(bData->end(), pSPInit);
  }// if (peMemSize > 0)

  if (SIRDataObject* hptr = m->GetDataObject("heap_ptr")) {
    if (hptr->IsReferenced()) {
      SIRInstruction* callInitMalloc
        = new SIRInstruction(TargetOpcode::JAL, initBB, false);
      SIRFunction* initMalloc
        = dynamic_cast<SIRFunction*>(m->GetSymbolValue("init_malloc"));
      ES_ASSERT_MSG(initMalloc, "init_malloc() not found");
      callInitMalloc->AddOperand(initMalloc);
      mData->InitTargetData(callInitMalloc);
      bData->InsertBefore(bData->end(), callInitMalloc);
      bData->InsertNOPBefore(bData->end());
    }// if (hptr->IsReferenced())
  }// if mallocFn
  // Branch to main()
  {
    SIRInstruction* callMain
      = new SIRInstruction(TargetOpcode::JAL, initBB, false);
    callMain->AddOperand(ent);
    mData->InitTargetData(callMain);
    bData->InsertBefore(bData->end(), callMain);
    bData->InsertNOPBefore(bData->end());
  }
  // Self loop to terminate the program
  {
    SIRInstruction* jInstr
      = new SIRInstruction(TargetOpcode::J, initBB, false);
    jInstr->AddOperand(init->GetParent()->AddOrGetImmediate(0));
    mData->InitTargetData(jInstr);
    bData->InsertBefore(bData->end(), jInstr);
    jInstr = new SIRInstruction(TargetOpcode::J, initBB, false);
    jInstr->AddOperand(init->GetParent()->AddOrGetImmediate(0));
    mData->InitTargetData(jInstr);
    bData->InsertBefore(bData->end(), jInstr);
    bData->InsertNOPBefore(bData->end());
  }
  return changed;
}// RunOnSIRModule()
