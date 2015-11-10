#ifndef _SOLVER_OPENCL_WORKITEM_H_
#define _SOLVER_OPENCL_WORKITEM_H_

__attribute__((always_inline)) inline size_t get_local_id(uint dim) {
  switch (dim) {
  case 0:  return __builtin_solver_item_id_x();
  case 1:  return __builtin_solver_item_id_y();
  case 2:  return __builtin_solver_item_id_z();
  default: return 0;
  }
}

__attribute__((always_inline)) inline size_t get_local_size(uint dim) {
  switch (dim) {
  case 0:  return __builtin_solver_group_size_x();
  case 1:  return __builtin_solver_group_size_y();
  case 2:  return __builtin_solver_group_size_z();
  default: return 0;
  }
}

__attribute__((always_inline)) inline size_t get_num_groups(uint dim) {
  switch (dim) {
  case 0:  return __builtin_solver_num_group_x();
  case 1:  return __builtin_solver_num_group_y();
  case 2:  return __builtin_solver_num_group_z();
  default: return 0;
  }
}

__attribute__((always_inline)) inline size_t get_group_id(uint dim) {
  switch (dim) {
  case 0:  return __builtin_solver_group_id_x();
  case 1:  return __builtin_solver_group_id_y();
  case 2:  return __builtin_solver_group_id_z();
  default: return 0;
  }
}

__attribute__((always_inline)) inline size_t get_global_id(uint dim) {
  /// The same as get_group_id(dim)*get_local_size(dim) + get_local_id(dim);
  switch (dim) {
  case 0:  return __builtin_solver_global_id_x();
  case 1:  return __builtin_solver_global_id_y();
  case 2:  return __builtin_solver_global_id_z();
  default: return 0;
  }
}

__attribute__((always_inline)) inline size_t get_global_size(uint dim) {
  /// The same as get_num_groups(dim)*get_local_size(dim);
  switch (dim) {
  case 0:  return __builtin_solver_global_size_x();
  case 1:  return __builtin_solver_global_size_y();
  case 2:  return __builtin_solver_global_size_z();
  default: return 0;
  }
}

#endif//_SOLVER_OPENCL_WORKITEM_H_
