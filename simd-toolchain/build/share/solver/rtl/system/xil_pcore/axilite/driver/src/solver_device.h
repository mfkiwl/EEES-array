#ifndef SOLVER_DEVICE_H_
#define SOLVER_DEVICE_H_

#include <stdint.h>
#include <stdbool.h>

typedef uint32_t solver_cp_i_t;
typedef uint32_t solver_cp_d_t;
typedef uint32_t solver_pe_i_t;
typedef uint32_t solver_pe_d_t;
typedef uint32_t solver_cfg_t;

typedef struct {
  void* baseaddress_;          /**< Device base address */
  solver_cp_i_t* cp_imem_;     /**< CP instruction memory pointer */
  solver_cp_d_t* cp_dmem_;     /**< CP data memory pointer */
  solver_pe_i_t* pe_imem_;     /**< PE instruction memory pointer */
  solver_pe_d_t* pe_dmem_;     /**< PE data memory pointer */
  solver_cfg_t*  config_regs_; /**< Memory-mapped config registers pointer */
  bool open_;                  /**< Status */
} SolverDevice;

void     solver_init_device(SolverDevice* d, void* baseaddress, void* highaddress);
void     solver_release_device(SolverDevice* s);
unsigned solver_read_cycle_counter(SolverDevice* s);
unsigned solver_read_config_reg(SolverDevice* s);
unsigned solver_read_task_ready(SolverDevice* s);
void     solver_write_config_reg(SolverDevice* s, unsigned c);

solver_cp_d_t* solver_get_cp_data_ptr(SolverDevice* s, unsigned offset);
solver_cp_d_t* solver_get_cp_inst_ptr(SolverDevice* s, unsigned offset);
solver_cp_d_t* solver_get_pe_data_ptr(SolverDevice* s, unsigned offset);
solver_cp_d_t* solver_get_pe_inst_ptr(SolverDevice* s, unsigned offset);

void solver_write_cp_inst_word(
    SolverDevice* s, solver_cp_i_t inst, unsigned offset);
void solver_write_cp_data_word(
    SolverDevice* s, solver_cp_d_t data, unsigned offset);
solver_cp_d_t solver_read_cp_data_word(SolverDevice* s, unsigned offset);

void solver_load_cp_inst(SolverDevice* s, solver_cp_i_t* inst,
    unsigned offset, unsigned size);
void solver_load_cp_data(SolverDevice* s, solver_cp_d_t* inst,
    unsigned offset, unsigned size);
void solver_load_pe_inst(SolverDevice* s, solver_pe_i_t* inst,
    unsigned offset, unsigned size);
void solver_load_cp_data(SolverDevice* s, solver_pe_d_t* inst,
    unsigned offset, unsigned size);

#endif /* SOLVER_DEVICE_H_ */
