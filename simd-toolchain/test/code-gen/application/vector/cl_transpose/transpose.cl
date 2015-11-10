#include <solver/communication.h>

#define N    128
#define MASK 127
/// 128 x 128 kernel for 128-PE system
__kernel void cl_transpose(int * restrict out, int* restrict in) {
  int gid_x = get_local_id(0);
  int gid_y = get_local_id(1);
  int dim_x = get_local_size(0);
  out[dim_x*gid_x + gid_y] = in[dim_x*gid_y + gid_x];
}

int main() {
  _solver_set_comm_boundary_mode(2);
  __builtin_solver_set_num_group(1, 1, 1);
  __builtin_solver_set_group_size(4, 4, 1);
  cl_transpose(0, 512);

}
