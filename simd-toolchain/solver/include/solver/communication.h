#ifndef _SOLVER_SOLVER_COMMUNICATION_H_
#define _SOLVER_SOLVER_COMMUNICATION_H_

#define SOLVER_COMM_BOUNDARY_ZERO   (0)
#define SOLVER_COMM_BOUNDARY_SCALAR (1)
#define SOLVER_COMM_BOUNDARY_WRAP   (2)
#define SOLVER_COMM_BOUNDARY_SELF   (3)

void _solver_set_comm_boundary_mode(int m);

int _solver_get_comm_boundary_mode();

/**
 * Shift a row of words from CP to PE.
 *
 * The function shifts a row of words in src to a row in the PE data memory.
 * It assumes that there is sufficient data in src.
 * @param dst The destination PE data memory row index.
 * @param src The pointer to source data.
 */
void _solver_shift_row_to_pe(int dst, const int* src);

/**
 * Shift a number of rows of words from CP to PE.
 *
 * The function shifts a number of rows of words in src to a row in the
 * PE data memory. It assumes that there is sufficient data in src.
 * @param dst The destination PE data memory row index.
 * @param src The pointer to source data.
 * @param n The number of rows to be shifted
 */
void _solver_shift_nrow_to_pe(int dst, const int* src, int n);

/**
 * Shift a row of words from PE to CP.
 *
 * The function shifts a row of words in src for PE data memory to CP.
 * It assumes that there is sufficient space in dst.
 * @param dst The CP address to store the data.
 * @param src The source PE data memory row index.
 */
void _solver_shift_row_to_cp(int* dst, int src);

/**
 * Shift a number rows of words from PE to CP.
 *
 * The function shifts a number of rows of words in PE data memory to CP.
 * It assumes that there is sufficient space in dst.
 * @param dst The CP address to store the data.
 * @param src The source PE data memory row index.
 * @param n The number of rows to be shifted
 */
void _solver_shift_nrow_to_cp(int* dst, int src);

/**
 * Calculate the sum of a row in PE data memory.
 *
 * @param dat The PE data memory row index of the data to be calculated.
 * @return The sum of data in dat.
 */
int  _solver_sum_row(int dat);

/**
 * Calculate the sum of a number of rows in PE data memory.
 *
 * @param dst The CP address to store results.
 * @param dat The index of the first row in PE data memory to be calculated.
 * @param n The number of rows to be calculated.
 */
void _solver_sum_nrow(int* dst, int dat, int n);

#endif/*_SOLVER_SOLVER_COMMUNICATION_H_*/
