__kernel void cl_add(__global int * restrict out, __global int * restrict a,
                     __global int * restrict b) {
  int i = get_global_id(0);
  out[i] = a[i] + b[i];
}

int main() {
  __builtin_solver_set_num_group(1, 1, 1);
  __builtin_solver_set_group_size(14, 1, 1);
  cl_add(0, 16, 32);  
}
