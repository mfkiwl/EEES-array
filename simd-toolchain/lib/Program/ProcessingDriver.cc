#include "SIR/SIRModule.hh"
#include "SIR/SIRFunction.hh"
#include "SIR/SIRBasicBlock.hh"
#include "SIR/SIRInstruction.hh"
#include "SIR/SIRConstant.hh"
#include "SIR/SIRParser.hh"
#include "SIR/Pass.hh"
#include "Target/TargetModuleData.hh"
#include "Target/TargetBasicInfo.hh"
#include "Target/TargetCodeGenEngine.hh"
#include "Target/TargetBlockData.hh"
#include "Transform/CommonSIRPasses.hh"
#include "Program/ProcessingDriver.hh"
#include "Utils/LogUtils.hh"
#include "llvm/Support/Casting.h"

#include "SIRModuleVerifier.hh"

using namespace std;
using namespace ES_SIMD;

ProcessingDriver::
ProcessingDriver(const string& name, int logLevel,
                 std::ostream& log, std::ostream& err)
  : name_(name), noSched_(false), printPassName_(logLevel>0),
    printFuncInfo_(false),logLevel_(logLevel), log_(log), err_(err),
    passCount_(0) {
  irPasses_        = std::make_pair(0, 0);
  translatePasses_ = std::make_pair(0, 0);
  schedPasses_     = std::make_pair(0, 0);
  regAllocPasses_  = std::make_pair(0, 0);
  postRAPasses_    = std::make_pair(0, 0);
}

bool ProcessingDriver::
SetPassesLogLv(pair<int, int> p, int l) {
  for (unsigned i = p.first,
         e = min(p.second, static_cast<int>(codeGenPasses_.size()));i < e; ++i){
    codeGenPasses_[i]->SetLogLevel(l);
  }
  return true;
}

ProcessingDriver::
~ProcessingDriver() {
  for (unsigned i = 0, e = codeGenPasses_.size(); i < e; ++i) {
    delete codeGenPasses_[i];
  }
}

void ProcessingDriver::
SetLogLevel(int l) {
  logLevel_ = l;
  SetPassesLogLv(make_pair(0, codeGenPasses_.size()), l);
}

void ProcessingDriver::
SetIRParserLogLevel(int l) { irParser_->SetLogLevel(l); }

void ProcessingDriver::
SetPassLogLevel(const string& n, int l) {
  logLevel_ = l;
  for (unsigned i = 0, e = codeGenPasses_.size(); i < e; ++i) {
    if (codeGenPasses_[i]->GetName() == n) {
      codeGenPasses_[i]->SetLogLevel(l);
    }
  }
}

void ProcessingDriver::
AddCommomIRPasses() {
  codeGenPasses_.push_back(new SIRGlobalSymbolPass(logLevel_, log_, err_));
  codeGenPasses_.push_back(new SIRCFGPass(logLevel_, log_, err_));
  codeGenPasses_.push_back(new SIRKernelParamPass(logLevel_, log_, err_));
  codeGenPasses_.push_back(new SIRInitValueInfoPass(logLevel_, log_, err_));
  codeGenPasses_.push_back(new SIRCallSiteProcessing(logLevel_, log_, err_));
  codeGenPasses_.push_back(new SplitSIRCallBlock(logLevel_, log_, err_));
  codeGenPasses_.push_back(new SIRSimplfyBranch(logLevel_, log_, err_));
  if (!module_->IsBareModule()) {
    codeGenPasses_.push_back(new SIRFunctionLayoutPass(logLevel_, log_, err_));
    codeGenPasses_.push_back(new DeadFunctionElimination(logLevel_,log_,err_));
  }
  if (!noSched_) {
    // codeGenPasses_.push_back(new SIRLocalOpt(logLevel_, log_, err_));
  }
  codeGenPasses_.push_back(new SIRModuleVerifier(logLevel_, log_, err_));
}// AddCommomIRPasses()

void ProcessingDriver::
InitializeCodeGenerator(const string& arch) {
  module_.reset(new SIRModule);
  irParser_.reset(new SIRParser(logLevel_, log_, err_));
  target_.reset(TargetBasicInfoFactory::GetTargetBasicInfo(arch));
  codeGenerator_.reset(TargetCodeGenEngineFactory::GetTargetCodeGenEngine(
                         target_.get()));
  if (!target_.get() ||  !target_->ValidateTarget() || !codeGenerator_.get()) {
    return errors_.push_back(
      Error(ErrorCode::TargetInitError,
            "Cannot initialize target \""+ arch +"\""));
  }// if (!codeGenerator_.get())
}// InitializeCodeGenerator()

void ProcessingDriver::
InitializeCodeGenerator(const Json::Value& cfg) {
  if (!cfg.isMember("arch")) {
    return errors_.push_back(
      Error(ErrorCode::TargetInitError,"Invalid config: no \"arch\" key"));
  }// if (!cfg.isMember("arch"))
  module_.reset(new SIRModule);
  irParser_.reset(new SIRParser(logLevel_, log_, err_));
  target_.reset(TargetBasicInfoFactory::GetTargetBasicInfo(cfg));
  codeGenerator_.reset(TargetCodeGenEngineFactory::GetTargetCodeGenEngine(
                         target_.get()));
  if (!target_.get() || !target_->ValidateTarget() || !codeGenerator_.get()) {
    return errors_.push_back(
      Error(ErrorCode::TargetInitError,
            "\""+ cfg["arch"].asString() +"\" initialization failed"));
  }// if (!codeGenerator_.get())
}// InitializeCodeGenerator()

void ProcessingDriver::
SetCodeGeneratorBareMode(bool b) {
  if (module_.get()) {  module_->SetBareModule(b); }
}// SetCodeGeneratorBareMode()

void ProcessingDriver::
SetNoSchedule(bool b) {
  noSched_ = b;
  if (codeGenerator_.get() && b) {
    codeGenerator_->SetScheduleMode(TargetCodeGenEngine::IROrder);
  }
}

void ProcessingDriver::
SetTargetParam(const std::string& param) {
  size_t sep = param.find(":");
  string k, v;
  if (sep != string::npos) {
    k = param.substr(0, sep);
    v = param.substr(sep+1, param.length()-sep-1);
  } else { k = param; }
  if (!target_->SetTargetParam(k, v)) {
    ES_WARNING_MSG(err_, "Invalid target parameter: "<< param <<"\n");
  }
}

void ProcessingDriver::
InitTargetCodeGenPipeline() {
  target_->InitCodeGenInfo();
  codeGenerator_->Initialize(module_.get());
  AddCommomIRPasses();
  translatePasses_.first = irPasses_.second = codeGenPasses_.size();
  codeGenerator_->AddTargetTranslatePasses(
    codeGenPasses_, logLevel_, log_, err_);
  schedPasses_.first = translatePasses_.second = codeGenPasses_.size();
  codeGenerator_->AddTargetSchedPasses(codeGenPasses_, logLevel_, log_, err_);
  regAllocPasses_.first = schedPasses_.second = codeGenPasses_.size();
  codeGenerator_->AddTargetRAPasses(codeGenPasses_, logLevel_, log_, err_);
  postRAPasses_.first = regAllocPasses_.second = codeGenPasses_.size();
  codeGenerator_->AddTargetPostRAPasses(codeGenPasses_, logLevel_, log_, err_);
  codeGenPasses_.push_back(new TargetTimingVerifier(logLevel_, log_, err_));
  postRAPasses_.second = codeGenPasses_.size();
}

void ProcessingDriver::
AddSIRSource(const string& src) {
  irParser_->err_clear();
  irParser_->ParseSIRFile(src, *module_);
  if (!irParser_->err_empty()) {
    errors_.insert(err_end(), irParser_->err_begin(), irParser_->err_end());
  }// if (!irParser_->err_empty())
}// AddSIRSource()

void ProcessingDriver::
GenerateTargetCode() {
  if (!RunPasses(codeGenPasses_, irPasses_))        { return; }
  if (printFuncInfo_) {
    for (SIRModule::iterator it = module_->begin();
         it != module_->end(); ++it) {
      (*it)->PrintIRInfo(log_);
      log_<<'\n';
    }
  }
  if (!RunPasses(codeGenPasses_, translatePasses_)) { return; }
  if (!RunPasses(codeGenPasses_, schedPasses_))     { return; }
  if (!RunPasses(codeGenPasses_, regAllocPasses_))  { return; }
  if (!RunPasses(codeGenPasses_, postRAPasses_))    { return; }
}

void ProcessingDriver::
RunUntil(const std::string& passName) {
  for (unsigned i = 0, e = codeGenPasses_.size(); i < e; ++i) {
    Pass* p = codeGenPasses_[i];
    ES_LOG_P(printPassName_, log_, ">> ["<< passCount_ <<"] Running "
             << p->getKindName() <<" -- "<< p->GetName() <<"\n");
    p->RunOnModule(module_.get());
    if (!p->err_empty()) {
      return errors_.insert(errors_.end(), p->err_begin(), p->err_end());
    }
    ++passCount_;
    if (p->GetName() == passName) { return; }
  }
}// RunUntil()

void ProcessingDriver::
EmitTargetASM(ostream& out) {
  if (codeGenerator_.get() == NULL) { return; }
  codeGenerator_->EmitTargetModule(out);
}// EmitTargetASM()

bool ProcessingDriver::
PrintErrors(ostream& o) const {
  if (!errors_.empty()) { 
    o <<"[ERROR]: "<< err_size() << " error(s):\n";
    for (err_const_iterator it = err_begin(); it != err_end(); ++it) {
      o <<"* [ERR]: "<< *it <<"\n";
    }
  }
  return errors_.empty();
}

bool ProcessingDriver::
SetCodeGenDbg(const std::string& dbg) {
  if (codeGenerator_.get() != NULL) {
    if (dbg == "regalloc")        { return SetPassesLogLv(regAllocPasses_, 1); }
    else if (dbg == "schedule")   { return SetPassesLogLv(schedPasses_, 1); }
    else if (dbg == "trace-sched"){ return SetPassesLogLv(schedPasses_, 2); }
    else if (dbg=="translate")    { return SetPassesLogLv(translatePasses_, 1);}
    else if (dbg == "spill")      { return SetPassesLogLv(regAllocPasses_, 2); }
    else if (dbg == "postra")     { return SetPassesLogLv(postRAPasses_, 1);   }
    else if (dbg == "all") {
      SetPassesLogLv(translatePasses_, 1);
      SetPassesLogLv(schedPasses_,  1);
      SetPassesLogLv(regAllocPasses_,  1);
      SetPassesLogLv(postRAPasses_,    1);
      return true;
    } else if (dbg == "none") {
      SetPassesLogLv(translatePasses_, 0);
      SetPassesLogLv(schedPasses_,  0);
      SetPassesLogLv(regAllocPasses_,  0);
      SetPassesLogLv(postRAPasses_,    0);
      return true;
    }
  }
  return false;
}// SetCodeGenDbg()

bool ProcessingDriver::
SetTargetParam(const std::string& key, const std::string& val) {
  return (target_.get()) ? target_->SetTargetParam(key, val) : false;
}

bool ProcessingDriver::
RunPasses(std::vector<Pass*>& p, std::pair<int, int> r) {
  for (int i = r.first, e = r.second; i < e; ++i) {
    ES_LOG_P(printPassName_, log_, ">> ["<< passCount_ <<"] Running "
             << p[i]->getKindName() <<" -- "<< p[i]->GetName() <<"\n");
    p[i]->RunOnModule(module_.get());
    if (!p[i]->err_empty()) {
      err_ <<p[i]->getKindName() <<" "<<p[i]->GetName() <<" has error(s)\n";
      errors_.insert(errors_.end(), p[i]->err_begin(), p[i]->err_end());
      return false;
    }
    ++passCount_;
  }
  return true;
}

void ProcessingDriver::
PrettyPrintSIRParsing(ostream& o) const { module_->ValuePrint(o); }

void ProcessingDriver::
PrettyPrintTargetCode(ostream& o) const {  module_->ValuePrint(o); }

void ProcessingDriver::
PrintCodeGenStat(std::ostream& o) const {
  if (module_.get()) { module_->GetTargetData()->PrintStatistics(o); }
}

void ProcessingDriver::
PrintCodeGenPasses(std::ostream& o) const {
  for (unsigned i = 0, e = codeGenPasses_.size(); i < e; ++i) {
    o <<">> "<< codeGenPasses_[i]->GetName() <<" ["
      << codeGenPasses_[i]->getKindName() <<"]: "
      << codeGenPasses_[i]->GetDescription() <<"\n";
  }
}

void ProcessingDriver::
PrintSymbolTable(std::ostream& out) const {
  if (module_.get()) { module_->GetTargetData()->PrintSymbolTable(out); }
}

void ProcessingDriver::
PrintCFG(std::ostream& out) const {
  if (module_.get()) { module_->PrintCFG(out); }
}

void ProcessingDriver::
DrawDDG(const string& fn, int bid, ostream& o) const {
  if (!module_.get()) { return; }
  SIRFunction* func = dynamic_cast<SIRFunction*>(module_->GetSymbolValue(fn));
  if (!func) { return; }
  SIRBasicBlock* bb = func->GetBasicBlock(bid);
  if (!bb || !bb->GetTargetData()) { return; }
  bb->GetTargetData()->DrawDDG(o);
}// DrawDDG()

void ProcessingDriver::
DrawDDGSubTrees(const string& fn, int bid, ostream& o) const {
  if (!module_.get()) { return; }
  SIRFunction* func = dynamic_cast<SIRFunction*>(module_->GetSymbolValue(fn));
  if (!func) { return; }
  SIRBasicBlock* bb = func->GetBasicBlock(bid);
  if (!bb || !bb->GetTargetData()) { return; }
  bb->GetTargetData()->DrawDDGSubTrees(o);
}// DrawDDG()


void ProcessingDriver::
DumpModule(Json::Value& mInfo) const {
  if (!module_.get()) { return; }
  module_->GetTargetData()->Dump(mInfo);
}// DumpModule()
