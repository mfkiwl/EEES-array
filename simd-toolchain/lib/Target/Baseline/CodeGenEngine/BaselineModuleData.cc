#include "BaselineFuncData.hh"
#include "BaselineBlockData.hh"
#include "BaselineInstrData.hh"
#include "BaselineModuleData.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRFunction.hh"

using namespace std;
using namespace ES_SIMD;


BaselineModuleData::~BaselineModuleData() {}

TargetFuncData*  BaselineModuleData::
InitTargetData(SIRFunction* func) {
  if (IsElementOf(func, funcData_)) { delete funcData_[func]; }
  BaselineFuncData* fData = new BaselineFuncData(func, target_);
  funcData_[func] = fData;
  func->SetTargetData(fData);
  return fData;
}// InitTargetData(const SIRFunction* f)

TargetBlockData* BaselineModuleData::
InitTargetData(SIRBasicBlock* bb) {
  if (IsElementOf(bb, blockData_)) { delete blockData_[bb]; }
  BaselineBlockData* bData = new BaselineBlockData(bb, target_);
  blockData_[bb] = bData;
  bb->SetTargetData(bData);
  return bData;
}// InitTargetData(const SIRBasicBlock* b)

TargetInstrData* BaselineModuleData::
InitTargetData(SIRInstruction* instr) {
  if (IsElementOf(instr, instrData_)) { delete instrData_[instr]; }
  BaselineInstrData* iData = new BaselineInstrData(instr, target_);
  instrData_[instr] = iData;
  instr->SetTargetData(iData);
  return iData;
}// InitTargetData(const SIRInstruction* i)
