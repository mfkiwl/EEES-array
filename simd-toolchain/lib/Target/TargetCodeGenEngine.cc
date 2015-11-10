#include "SIR/SIRInstruction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRKernel.hh"
#include "SIR/SIRFunction.hh"
#include "SIR/SIRDataObject.hh"
#include "SIR/SIRModule.hh"
#include "SIR/Pass.hh"
#include "Transform/SIRFunctionLayout.hh"
#include "Transform/DeadFunctionElimination.hh"
#include "Target/TargetIssuePacket.hh"
#include "Target/TargetInstrData.hh"
#include "Target/TargetBlockData.hh"
#include "Target/TargetFuncData.hh"
#include "Target/TargetModuleData.hh"
#include "Target/TargetDataLayout.hh"
#include "Target/TargetBasicInfo.hh"
#include "Target/TargetCodeGenEngine.hh"
#include <sstream>

using namespace std;
using namespace ES_SIMD;

auto_ptr<TargetCodeGenEngineFactory::TargetCGCreatorMap>
TargetCodeGenEngineFactory::map_;

TargetCodeGenEngine* TargetCodeGenEngineFactory::
GetTargetCodeGenEngine(const TargetBasicInfo* tgt) {
  const string& name = tgt->GetName();
  TargetCodeGenEngineFactory::TargetCGCreatorMap* m = GetMap();
  TargetCGCreatorMap::iterator it = m->find(name);
  return (it == m->end()) ? NULL : it->second(tgt);
}

TargetCodeGenEngine::TargetCodeGenEngine()
  : module_(NULL),  schedMode_(DefaultSched) {}

TargetCodeGenEngine::~TargetCodeGenEngine() {
  delete moduleData_;
}

void TargetCodeGenEngine::
Initialize(SIRModule* module) {
  module_ = module;
  moduleData_ = GetModuleData();
  module_->SetTargetData(moduleData_);
}// Initialize()

void TargetCodeGenEngine::
AddTargetTranslatePasses(vector<Pass*>& passes, unsigned logLv,
                         ostream& log, ostream& err) {
  passes.push_back(GetDataLayoutPass(logLv, log, err));
}

void TargetCodeGenEngine::
AddTargetSchedPasses(vector<Pass*>& passes, unsigned logLv,
                     ostream& log, ostream& err) {}

void TargetCodeGenEngine::
AddTargetRAPasses(vector<Pass*>& passes, unsigned logLv,
                  ostream& log, ostream& err) {}

void TargetCodeGenEngine::AddTargetPostRAPasses(
  vector<Pass*>& passes, unsigned logLv, ostream& log, ostream& err) {}

void TargetCodeGenEngine::
EmitTargetModule(ostream& out) {
  out <<"        .text\n";
  for (SIRModule::iterator fIt = module_->begin();fIt != module_->end();++fIt) {
    (*fIt)->GetTargetData()->Print(out);
    out <<'\n';
  }// for moudle iterator fIt
  vector<SIRDataObject*> emitObjs, emitVObjs;
  for (SIRModule::dobj_iterator dIt = module_->dobj_begin();
       dIt != module_->dobj_end(); ++dIt) {
    if ((*dIt).second->IsReferenced()) {
      if ((*dIt).second->IsVector()) { emitVObjs.push_back((*dIt).second); }
      else  { emitObjs.push_back((*dIt).second);  }
    }
  }
  if (!emitObjs.empty()) {
    out <<"        .data\n";
    for (int i = 0, e = emitObjs.size(); i < e; ++i) {
      emitObjs[i]->TargetPrettyPrint(out);
      out <<'\n';
    }
  }// if (!emitObjs.empty())
  if (!emitVObjs.empty()) {
    out <<"        .vdata\n";
    for (int i = 0, e = emitVObjs.size(); i < e; ++i) {
      emitVObjs[i]->TargetPrettyPrint(out);
      out <<'\n';
    }
  }// if (!emitVObjs.empty())
}// EmitTargetModule()

void TargetCodeGenEngine::
EmitTargetFunction(SIRFunction* func, ostream& out) {
  func->GetTargetData()->Print(out);
}// EmitTargetFunction()

Pass* TargetCodeGenEngine::
GetDataLayoutPass(unsigned logLv, ostream& log, ostream& err) const {
  return new TargetDataLayoutPass(logLv, log, err);
}

bool TargetCodeGenDataInit::
RunOnSIRModule(SIRModule* m) {
  TargetModuleData* mData = m->GetTargetData();
  for (SIRModule::iterator fIt = m->begin(); fIt != m->end(); ++fIt) {
    SIRFunction* func = *fIt;
    func->UpdateRegValueType();
    mData->InitTargetData(func);
    for (SIRFunction::iterator bIt = func->begin(); bIt != func->end(); ++bIt) {
      SIRBasicBlock* bb = *bIt; mData->InitTargetData(bb);
    }
  }// for m iterator fIt
  return true;
}// RunOnSIRModule()

bool TargetTimingVerifier::
RunOnSIRModule(SIRModule* m) {
  for (SIRModule::const_iterator fIt=m->begin();
       fIt != m->end(); ++fIt) {
    const SIRFunction* func = *fIt;
    for (SIRFunction::const_iterator bIt = func->begin();
         bIt != func->end();++bIt ){
      const SIRBasicBlock* bb = *bIt;
      const TargetBlockData* bData = bb->GetTargetData();
      // Basic timing check inside a block
      for (TargetBlockData::const_iterator pIt = bData->begin();
           pIt != bData->end(); ++pIt) {
        const TargetIssuePacket& packet = **pIt;
        int t = packet.IssueTime();
        for (int i=0, e=packet.size(); i < e; ++i) {
          if (SIRInstruction* instr = packet[i]) {
            if (!func->IsValidValueID(instr->GetValueID())) { continue; }
            if (IsTargetCall(instr->GetTargetOpcode()))     { continue; }
            int at = t + instr->GetTargetData()->GetLatency();
            for (SIRInstruction::use_const_iterator uIt = instr->use_begin();
                 uIt != instr->use_end(); ++uIt) {
              if (SIRInstruction* ui = dynamic_cast<SIRInstruction*>(*uIt)) {
                if (ui->GetParent() == bb) {
                  int ut = ui->GetTargetData()->GetIssueTime();
                  if ((at > ut)
                      && (instr->IsVectorInstr() == ui->IsVectorInstr())) {
                    stringstream ss;
                    ss << func->GetName() <<".B"<< bb->GetBasicBlockID()
                       <<": V_"<< instr->GetValueID() <<" (available at "<< at
                       <<") used at "<< ut <<" by "; ui->ValuePrint(ss);
                    errors_.push_back(Error(ErrorCode::InstrTimingErr, ss.str()));
                  }
                }// if (ui->GetParent() == bb)
              }// if (SIRInstruction* ui = dynamic_cast<SIRInstruction*>(*uIt))
            }// for instr use_const_iterator uIt
          }// if (SIRInstruction* instr = packet[i])
        }// for i = 0 to packet.size()-1
      }// for bData const_iterator pIt
    }// for func const_iterator bIt
  }// for m const_iterator fIt
  return false;
}// VerifyTargetTiming()
