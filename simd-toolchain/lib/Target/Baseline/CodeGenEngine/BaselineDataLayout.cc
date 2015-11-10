#include "BaselineDataLayout.hh"
#include "BaselineBasicInfo.hh"
#include "BaselineModuleData.hh"
#include "SIR/SIRDataObject.hh"
#include "SIR/SIRConstant.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRFunction.hh"
#include "SIR/SIRModule.hh"
#include "Target/TargetMemorySegments.hh"
#include "Utils/DbgUtils.hh"
#include "Utils/LogUtils.hh"
#include "Utils/StringUtils.hh"

using namespace std;
using namespace ES_SIMD;

BaselineDataLayoutPass::~BaselineDataLayoutPass() {}

bool BaselineDataLayoutPass::
RunOnSIRModule(SIRModule* m) {
  bool changed = false;
  BaselineModuleData* mData
    = dynamic_cast<BaselineModuleData*>(m->GetTargetData());
  DataMemorySegments& cpMemSegs = mData->GetCPMemorySegments();
  DataMemorySegments& peMemSegs = mData->GetPEMemorySegments();
  const int cpWordSize = target_.GetCPDataWidth() / 8;
  const int peWordSize = target_.GetPEDataWidth() / 8;
  const int cpMemSize  = target_.GetCPDMemDepth() * cpWordSize;
  const int peMemSize  = target_.GetPEDMemDepth() * peWordSize;
  cpMemSegs.stackBottom_ = cpMemSize;
  peMemSegs.stackBottom_ = peMemSize;
  if (SIRDataObject* ps = m->GetDataObject("__pe_array_size")) {
    ps->SetSize(cpWordSize);
    SIRDataType_t psType
      = (cpWordSize == 2) ? SIRDataType::Int16 : SIRDataType::Int32;
    ps->AddInit(psType, target_.GetNumPE());
  }
  if (SIRDataObject* hs = m->GetDataObject("__heap_start")) {
    hs->SetSize(cpWordSize);
  }
  if (SIRDataObject* ss = m->GetDataObject("__stack_start")) {
    ss->SetSize(cpWordSize);
    SIRDataType_t hpType
      = (cpWordSize == 2) ? SIRDataType::Int16 : SIRDataType::Int32;
    ss->AddInit(hpType, cpMemSegs.stackBottom_);
  }

  /// First allocate memory space for all
  int cpDataPtr = 0, peDataPtr = 0;
  for (SIRModule::dobj_iterator dIt = m->dobj_begin();
       dIt != m->dobj_end(); ++dIt) {
    SIRDataObject* dobj = dIt->second;
    if (!dobj->IsReferenced()) { continue; }
    int size = dobj->GetSize();
    if (!dobj->sym_empty()) {
      int wordSize = dobj->IsVector() ? peWordSize : cpWordSize;
      dobj->SetSize(size = wordSize*dobj->sym_size());
    }
    if (dobj->IsVector()) {
      ES_LOG_P(logLv_, log_, ">> V-Object "<< dobj->GetName()
               <<" allocated to "<< peDataPtr <<'\n');
      dobj->SetAddress(peDataPtr);
      peDataPtr += size;
      if (size % peWordSize) { peDataPtr += peWordSize - size % peWordSize; }
    } else {
      ES_LOG_P(logLv_, log_, ">> S-Object "<< dobj->GetName()
               <<" allocated to "<< cpDataPtr <<'\n');
      dobj->SetAddress(cpDataPtr);
      cpDataPtr += size;
      if (size % cpWordSize) { cpDataPtr += cpWordSize - size % cpWordSize; }
    }
  }// for m dobj_iterator dIt
  if (cpDataPtr > cpMemSize) {
    errors_.push_back(
      Error(ErrorCode::DataNotFit,
            "CP Data objects don't fit in memory: "
            +Int2DecString(cpDataPtr)+">"+Int2DecString(cpMemSize)));
    return true;
  }
  if (peDataPtr > peMemSize) {
    errors_.push_back(
      Error(ErrorCode::DataNotFit, "PE Data objects don't fit in memory: "
            +Int2DecString(peDataPtr)+">"+Int2DecString(peMemSize)));
    return true;
  }

  mData->SetCPDataPtr(cpDataPtr);
  mData->SetPEDataPtr(peDataPtr);

  /// Then replace the data object with immediates of the object's address
  for (SIRModule::iterator fIt = m->begin(); fIt != m->end(); ++fIt) {
    for (SIRFunction::iterator bIt = (*fIt)->begin();
         bIt != (*fIt)->end(); ++bIt) {
      for (SIRBasicBlock::iterator iIt = (*bIt)->begin();
           iIt != (*bIt)->end(); ++iIt) {
        SIRInstruction* instr = *iIt;
        for (SIRInstruction::operand_iterator oIt = instr->operand_begin();
             oIt != instr->operand_end(); ++oIt) {
          ES_ASSERT_MSG(*oIt, "Invalid operand");
          if (SIRDataObject::classof(*oIt)) {
            instr->ReplaceOperand(
              *oIt, m->AddOrGetImmediate(
                static_cast<SIRDataObject*>(*oIt)->GetAddress()));
          }
        }
      }// for (*bIt) iterator iIt
    }// for (*fIt) iterator bIt
  }// for moudle iterator fIt
  return changed;
}// RunOnSIRModule()
