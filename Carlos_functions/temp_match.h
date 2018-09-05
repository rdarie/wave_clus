#include "mex.h"
#define SHIFT_RANGE 1
#define min(a,b) \
  ({ __typeof__ (a) _a = (a); \
      __typeof__ (b) _b = (b); \
    _a < _b ? _a : _b; })
#define max(a,b) \
  ({ __typeof__ (a) _a = (a); \
      __typeof__ (b) _b = (b); \
    _a > _b ? _a : _b; })


double dmax_array(double *a, mwSize N);
double dmin_array(double *a, mwSize N);
mwIndex imax_array(mwIndex *a, mwSize N);
mwIndex imin_array(mwIndex *a, mwSize N);
mwIndex dmin_arg(double *a, mwSize N);
mwIndex dmax_arg(double *a, mwSize N);
void dmin_args(double * array, mwSize arrayLength, mwIndex **minIndices, mwIndex *minIndicesN);

void matchTemp(double* wav, double* temp, mwSize N, mwSize NT,
    double* tmatch, double* resmatch, double* residue, double* shift, mwSize sr, mwSize shift_range);

void tempMatchOverlap(double *wav, double *temp, mwSize N, mwSize NT, double th_o,
    double *final_match, double *final_shift);

