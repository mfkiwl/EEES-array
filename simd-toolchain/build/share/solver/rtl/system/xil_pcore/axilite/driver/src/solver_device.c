/*
 * solver_device.c
 *
 *  Created on: Sep 12, 2013
 *      Author: dshe
 */
#include "solver_device.h"
#include <stdlib.h>
#include <string.h>

void solver_init_device(SolverDevice* d, void* baseaddress, void* highaddress){
  // First get the next power of 2 of the address space
  unsigned s = (unsigned)((char*)highaddress - (char*)baseaddress) - 1;
  s |= s>>1;
  s |= s>>2;
  s |= s>>4;
  s |= s>>8;
  s |= s>>16;
  ++s;
  d->baseaddress_ = baseaddress;
  d->cp_imem_ = (solver_cp_i_t*)baseaddress;
  d->pe_imem_ = (solver_pe_i_t*)((char*)baseaddress + (s >> 4));
  d->cp_dmem_ = (solver_cp_d_t*)((char*)baseaddress + (s >> 3));
  d->pe_dmem_ = (solver_pe_d_t*)((char*)baseaddress + (s >> 2));
  d->config_regs_ = (solver_cp_d_t*)((char*)baseaddress + (s >> 2) - 1024);
  d->open_ = true;
}

void solver_release_device(SolverDevice* s) { s->open_ = false; }

unsigned solver_read_cycle_counter(SolverDevice* s) {
  return s->config_regs_[1];
}
unsigned solver_read_config_reg(SolverDevice* s) { return s->config_regs_[0]; }
unsigned solver_read_task_ready(SolverDevice* s) { return s->config_regs_[2]; }

void solver_write_config_reg(SolverDevice* s, unsigned c) {
  s->config_regs_[0] = c;
}

solver_cp_i_t* solver_get_cp_inst_ptr(SolverDevice* s, unsigned offset) {
  return s->cp_imem_ + offset;
}

solver_cp_d_t* solver_get_cp_data_ptr(SolverDevice* s, unsigned offset) {
  return s->cp_dmem_ + offset;
}

solver_pe_d_t* solver_get_pe_data_ptr(SolverDevice* s, unsigned offset) {
  return s->pe_dmem_ + offset;
}
solver_pe_i_t* solver_get_pe_inst_ptr(SolverDevice* s, unsigned offset) {
  return s->pe_imem_ + offset;
}

void solver_write_cp_inst_word(SolverDevice* s,
    solver_cp_i_t inst, unsigned offset) { s->cp_imem_[offset] = inst; }

void solver_write_cp_data_word(SolverDevice* s, solver_cp_i_t data,
    unsigned offset) { s->cp_dmem_[offset] = data; }

solver_cp_d_t solver_read_cp_data_word(SolverDevice* s, unsigned offset) {
  return s->cp_dmem_[offset];
}

void solver_load_cp_inst(SolverDevice* s, solver_cp_i_t* inst,
    unsigned offset, unsigned size) {
  memcpy(s->cp_imem_+offset, inst, size*sizeof(unsigned));
}

void solver_load_cp_data(SolverDevice* s, solver_cp_d_t* inst,
    unsigned offset, unsigned size) {
  memcpy(s->cp_dmem_+offset, inst, size*sizeof(unsigned));
}

void solver_load_pe_inst(SolverDevice* s, solver_pe_i_t* inst,
    unsigned offset, unsigned size) {
  memcpy(s->pe_imem_+offset, inst, size*sizeof(unsigned));
}

void solver_load_pe_data(SolverDevice* s, solver_pe_d_t* inst,
    unsigned offset, unsigned size){
  memcpy(s->pe_dmem_+offset, inst, size*sizeof(unsigned));
}
