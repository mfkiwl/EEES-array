#define C0 -23
#define C1 67
#define C2 -20

__kernel void cl_conv3(__global int * restrict out, __global int * restrict in) {
  int i = get_global_id(0);
  out[i] = in[i-1]*C0 + in[i]*C1 + in[i+1]*C2;
}

int main() {
  __builtin_solver_set_num_group(1, 1, 1);
  __builtin_solver_set_group_size(32, 1, 1);
  cl_conv3(0, 8);
}
