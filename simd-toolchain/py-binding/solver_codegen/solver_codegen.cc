#include "Program/ProcessingDriver.hh"
#include "Utils/FileUtils.hh"
#include <sstream>

extern "C" {
  ES_SIMD::ProcessingDriver* create_codegen_driver_from_cfg(
    const char* cfg, int logLv) {
    Json::Value aCfg;
    if (ES_SIMD::ReadJSONFile(cfg,aCfg)!=ES_SIMD::FileStatus::OK) {return NULL;}
    ES_SIMD::ProcessingDriver* drv = new ES_SIMD::ProcessingDriver(
      "Solver Python CodeGen Driver", logLv, std::cout, std::cerr);
    drv->InitializeCodeGenerator(aCfg);
    if (!drv->PrintErrors(std::cerr)) { delete drv; return NULL; }
    return drv;
  }
  ES_SIMD::ProcessingDriver* create_codegen_driver_from_str(
    const char* arch, int logLv) {
    ES_SIMD::ProcessingDriver* drv = new ES_SIMD::ProcessingDriver(
      "Solver Python CodeGen Driver", logLv, std::cout, std::cerr);
    std::string a(arch);
    drv->InitializeCodeGenerator(a);
    if (!drv->PrintErrors(std::cerr)) { delete drv; return NULL; }
    return drv;
  }
  void delete_codegen_driver(ES_SIMD::ProcessingDriver* d) { delete d; }
  void set_log_level(ES_SIMD::ProcessingDriver* d, unsigned l) {
    d->SetLogLevel(l);
  }
  void set_pass_log_level(ES_SIMD::ProcessingDriver* d,
                          const char* n, unsigned l) {
    const std::string p(n);
    d->SetPassLogLevel(p, l);
  }
  void set_cg_bare_mode(ES_SIMD::ProcessingDriver* d, bool b) {
    d->SetCodeGeneratorBareMode(b);
  }
  void set_cg_no_sched(ES_SIMD::ProcessingDriver* d, bool b) {
    d->SetNoSchedule(b);
  }
  bool init_cg_pipeline(ES_SIMD::ProcessingDriver* d) {
    d->InitTargetCodeGenPipeline();
    return d->PrintErrors(std::cerr);
  }
  bool add_sir_source(ES_SIMD::ProcessingDriver* d, const char* src) {
    d->AddSIRSource(src);
    return d->PrintErrors(std::cerr);
  }
  bool generate_target_code(ES_SIMD::ProcessingDriver* d) {
    d->GenerateTargetCode();
    return d->PrintErrors(std::cerr);
  }
  bool run_codegen_until(ES_SIMD::ProcessingDriver* d, const char* n) {
    const std::string p(n);
    d->RunUntil(p);
    return d->PrintErrors(std::cerr);
  }
  bool write_target_asm_file(ES_SIMD::ProcessingDriver* d, const char* of) {
    std::stringstream outss;
    d->EmitTargetASM(outss);
    if (!d->PrintErrors(std::cerr)) { return false; }
    ES_SIMD::WriteStringToFile(outss, of);
    return true;
  }
  void print_cg_stat(ES_SIMD::ProcessingDriver* d) {
    d->PrintCodeGenStat(std::cout);
  }
  void print_target_code(ES_SIMD::ProcessingDriver* d) {
    d->PrettyPrintTargetCode(std::cout);
  }
  void print_cg_passes(ES_SIMD::ProcessingDriver* d) {
    d->PrintCodeGenPasses(std::cout);
  }
}
