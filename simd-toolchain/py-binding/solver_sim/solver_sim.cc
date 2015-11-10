#include "Target/TargetBasicInfo.hh"
#include "Target/TargetBinaryProgram.hh"
#include "Simulation/CycleAccurateSimulator.hh"
#include "Simulation/SimProcessor.hh"
#include <sstream>

extern "C" {
  ES_SIMD::TargetBasicInfo* create_target_from_cfg(const char* cfg) {
    Json::Value archCfg;
    if (ES_SIMD::ReadJSONFile(cfg, archCfg) != ES_SIMD::FileStatus::OK) {
      return NULL;
    }
    return ES_SIMD::TargetBasicInfoFactory::GetTargetBasicInfo(archCfg);
  }
  ES_SIMD::TargetBasicInfo* create_target_from_string(const char* arch) {
    std::string a(arch);
    return ES_SIMD::TargetBasicInfoFactory::GetTargetBasicInfo(a);
  }
  void delete_target(ES_SIMD::TargetBasicInfo* t) { delete t; }

  void set_target_param(ES_SIMD::TargetBasicInfo* t,
                        const char* k, const char* v) {
    t->SetTargetParam(k, v);
  }
  ES_SIMD::CycleAccurateSimulator* create_simulator(
    ES_SIMD::TargetBasicInfo* t, int logLv, int traceLv) {
    t->InitSimulationInfo();
    ES_SIMD::CycleAccurateSimulator* sim = new ES_SIMD::CycleAccurateSimulator(
      t->GetName(), logLv, std::cout, traceLv, std::cerr);
    sim->AddSimProcessor(
      ES_SIMD::SimProcessorFactory::GetSimProcessor(
        t->GetName(), t, logLv, std::cout,
        traceLv, sim->GetTraceStream(), std::cerr));
    sim->InitializeSimulator(0);
    return sim;
  }
  void delete_simulator(ES_SIMD::CycleAccurateSimulator* s) {
    s->ReleaseResources();
    delete s;
  }

  bool has_error(ES_SIMD::CycleAccurateSimulator* s) {return !s->error_empty();}
  void clear_error(ES_SIMD::CycleAccurateSimulator* s) { s->error_clear(); }
  void set_max_simulation_cycle(ES_SIMD::CycleAccurateSimulator* s,
                                unsigned long long mc) {
    s->SetMaxCycle(mc);
  }
  void set_trace_level(ES_SIMD::CycleAccurateSimulator* s, unsigned l) {
    s->SetTraceLevel(l);
  }
  void set_log_level(ES_SIMD::CycleAccurateSimulator* s, unsigned l) {
    s->SetLogLevel(l);
  }

  bool add_sim_instr(ES_SIMD::CycleAccurateSimulator* s, const char* imem_cmd) {
    return s->AddInstructionInit(imem_cmd);
  }
  bool add_sim_data(ES_SIMD::CycleAccurateSimulator* s, const char* dmem_cmd) {
    return s->AddDataInit(dmem_cmd);
  }
  bool add_sim_data_binary(ES_SIMD::CycleAccurateSimulator* s,
                           const char* dbin_cmd) {
    return s->AddDataBinary(dbin_cmd);
  }
  void add_pc_trap(ES_SIMD::CycleAccurateSimulator* s, unsigned t) {
    s->AddPCTrap(0, t);
  }
  void remove_pc_trap(ES_SIMD::CycleAccurateSimulator* s, unsigned t) {
    s->RemovePCTrap(0, t);
  }
  void clear_pc_trap(ES_SIMD::CycleAccurateSimulator* s) {
    s->ClearPCTrap(0);
  }
  void reset_simulator(ES_SIMD::CycleAccurateSimulator* s) { s->Reset(); }
  void run_simulator(ES_SIMD::CycleAccurateSimulator* s) {
    s->Run();
    if (!s->error_empty()) {
      s->PrintErrors(std::cout);
    }
  }
  void run_simulator_cycle(ES_SIMD::CycleAccurateSimulator* s,
                           unsigned long long c) {
    s->Run(c);
    if (!s->error_empty()) {
      s->PrintErrors(std::cout);
    }
  }
  void run_simulator_pc_trap(ES_SIMD::CycleAccurateSimulator* s,
                           unsigned long long c) {
    s->RunPCTrap(c);
    if (!s->error_empty()) {
      s->PrintErrors(std::cout);
    }
  }
  unsigned long long get_simulation_cycle(ES_SIMD::CycleAccurateSimulator* s) {
    return s->GetSimulationCycle();
  }
  unsigned long long get_max_cycle(ES_SIMD::CycleAccurateSimulator* s) {
    return s->GetMaxCycle();
  }
  bool simulation_finished(ES_SIMD::CycleAccurateSimulator* s) {
    return s->SimulationFinished();
  }

  unsigned get_vector_len(ES_SIMD::CycleAccurateSimulator* s) {
    return s->GetVectorLength(0);
  }
  unsigned get_cp_ctx_size(ES_SIMD::CycleAccurateSimulator* s) {
    return s->GetScalarContextSize(0);
  }
  unsigned get_pe_ctx_size(ES_SIMD::CycleAccurateSimulator* s) {
    return s->GetVectorContextSize(0);
  }
  unsigned get_cp_dmem_size(ES_SIMD::CycleAccurateSimulator* s) {
    return s->GetScalarMemorySize(0);
  }
  unsigned get_pe_dmem_size(ES_SIMD::CycleAccurateSimulator* s) {
    return s->GetVectorMemorySize(0);
  }
  uint32_t get_scalar_mem_val(ES_SIMD::CycleAccurateSimulator* s, unsigned a) {
    return s->GetScalarMemoryValue(0, a);
  }
  uint32_t get_scalar_ctx_val(ES_SIMD::CycleAccurateSimulator* s, unsigned a) {
    return s->GetScalarContextValue(0, a);
  }
  void get_vector_mem_val(ES_SIMD::CycleAccurateSimulator* s, unsigned a,
                          uint32_t* val) {
    s->GetVectorMemoryValue(0, a, val);
  }
  void get_vector_ctx_val(ES_SIMD::CycleAccurateSimulator* s, unsigned a,
                          uint32_t* val) {
    s->GetVectorContextValue(0, a, val);
  }
  uint32_t get_program_counter(ES_SIMD::CycleAccurateSimulator* s) {
    return s->GetProgramCounter(0);
  }

  void print_errors(ES_SIMD::CycleAccurateSimulator* s) {
    s->PrintErrors(std::cout);
  }
  size_t get_scalar_instr_str(ES_SIMD::CycleAccurateSimulator* s,
                                unsigned a, char* buff, size_t buff_size) {
    std::stringstream ss;
    s->PrintScalarOperation(0, a, ss);
    ss.seekg(0, std::ios::end);
    size_t tsize = ss.tellg();
    ss.seekg(0, std::ios::beg);
    if (tsize > buff_size) { return 0; }
    ss.read(buff, tsize);
    return tsize;
  }
  size_t get_vector_instr_str(ES_SIMD::CycleAccurateSimulator* s,
                                unsigned a, char* buff, size_t buff_size) {
    std::stringstream ss;
    s->PrintVectorOperation(0, a, ss);
    ss.seekg(0, std::ios::end);
    size_t tsize = ss.tellg();
    ss.seekg(0, std::ios::beg);
    if (tsize > buff_size) { return 0; }
    ss.read(buff, tsize);
    return tsize;
  }
  size_t get_trace_size(ES_SIMD::CycleAccurateSimulator* s) {
    return s->GetTraceSize();
  }
  void read_out_trace(ES_SIMD::CycleAccurateSimulator* s,
                      char* buff, size_t buff_size) {
    s->ReadOutTrace(buff, buff_size);
  }
  void clear_trace(ES_SIMD::CycleAccurateSimulator* s) {
    s->GetTraceStream().str("");
    s->GetTraceStream().clear();
  }
}
