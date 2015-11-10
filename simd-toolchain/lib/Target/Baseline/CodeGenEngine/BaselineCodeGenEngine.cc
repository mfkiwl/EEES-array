#include "BaselineBasicInfo.hh"
#include "BaselineInstrData.hh"
#include "BaselineCodeGenEngine.hh"
#include "BaselineBUSelector.hh"
#include "BaselineBlockData.hh"
#include "BaselineFuncData.hh"
#include "BaselineModuleData.hh"
#include "BaselineRegAlloc.hh"
#include "BaselineKernelBuilder.hh"
#include "BaselineDataLayout.hh"
#include "BaselinePostRATransform.hh"
#include "BaselineInitCodeEmitter.hh"
#include "SIR/SIRRegister.hh"
#include "SIR/SIRConstant.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRKernel.hh"
#include "SIR/SIRFunction.hh"
#include "SIR/SIRModule.hh"
#include "Target/DataDependencyGraph.hh"
#include "Target/BottomUpSchedule.hh"
#include "Target/PromoteLongImm.hh"
#include "Target/InterferenceGraph.hh"
#include "Graph/Graph.hh"
#include "Utils/LogUtils.hh"
#include "Utils/StringUtils.hh"
#include "Utils/DbgUtils.hh"
#include "Utils/BitUtils.hh"
#include "llvm/Support/Casting.h"

using namespace std;
using namespace ES_SIMD;

RegisterTargetCodeGenEngine<BaselineCodeGenEngine> BaselineCodeGenEngine::
reg_("baseline");

BaselineCodeGenEngine::
BaselineCodeGenEngine(const TargetBasicInfo* t)
  : TargetCodeGenEngine(), target_(*dynamic_cast<const BaselineBasicInfo*>(t)){}

BaselineCodeGenEngine::~BaselineCodeGenEngine() {}

TargetModuleData* BaselineCodeGenEngine::
GetModuleData() { return new BaselineModuleData(module_, target_); }

void BaselineCodeGenEngine::
AddTargetTranslatePasses(std::vector<Pass*>& passes, unsigned logLv,
                         std::ostream& log, std::ostream& err) {
  passes.push_back(new BaselineKernelBuilder(logLv, log, err, target_));
  passes.push_back(new PromoteLongImmPass(target_, logLv, log, err));
  passes.push_back(GetDataLayoutPass(logLv, log, err));
  passes.push_back(new BaselineBlockTranslationPass(target_, logLv, log, err));
  //passes.push_back(new BaselineLowerCommunication(target_, logLv, log, err));
  passes.push_back(new TargetCodeGenDataInit(logLv, log, err));
  passes.push_back(new BaselineLowerCommunication(target_, logLv, log, err));
}// AddTargetTranslatePasses()

void BaselineCodeGenEngine::
AddTargetSchedPasses(vector<Pass*>& passes, unsigned logLv,
                     ostream& log, ostream& err) {
  passes.push_back(new BaselineBlockSchedulingPass(
                     target_, schedMode_, logLv, log, err));
}

void BaselineCodeGenEngine::
AddTargetRAPasses(vector<Pass*>& passes, unsigned logLv,
                  ostream& log, ostream& err) {
  passes.push_back(new BaselineFuncRegAllocPass(target_, logLv, log, err));
}

void BaselineCodeGenEngine::
AddTargetPostRAPasses(std::vector<Pass*>& passes, unsigned logLv,
                      std::ostream& log, std::ostream& err) {
  passes.push_back(new BaselineCallerSavedRegPass(target_, logLv, log, err));
  passes.push_back(new LowerMOV(logLv, log, err));
  passes.push_back(new LowerRSUB(logLv, log, err));
  passes.push_back(new EmitFuncProEpilogue(target_,  logLv, log, err));
  passes.push_back(new CrossFuncBypassCheck(target_, logLv, log, err));
  if (((target_.GetCPNumStages() == 5) && !target_.IsCPExplicitBypass())
      || ((target_.GetPENumStages() == 5) && !target_.IsPEExplicitBypass())) {
    passes.push_back(new CrossBlockTimingCheck(target_, logLv, log, err));
  }
  if (!module_->IsBareModule()) {
    passes.push_back(new BaselineInitCodeEmitter(target_, logLv, log, err));
  }
  passes.push_back(new TargetAddressPass(logLv, log, err));
}// AddTargetPostRAPasses()

void ES_SIMD::
UpdateBaselineFuncBypass(
  SIRFunction* func, const BaselineBasicInfo& target,
  bool dbg, ostream& dbgs) {
  for (SIRFunction::iterator bIt = func->begin();
       bIt != func->end(); ++ bIt) {
    dynamic_cast<BaselineBlockData*>((*bIt)->GetTargetData())->ResetBypass();
    SetBaselineBlockBypass(*bIt, target, dbg, dbgs);
  }
}// UpdateBaselineFunctionBypass()

Pass* BaselineCodeGenEngine::
GetDataLayoutPass(unsigned logLv, ostream& log, ostream& err) const {
  return new BaselineDataLayoutPass(target_, logLv, log, err);
}// GetDataLayoutPass()
