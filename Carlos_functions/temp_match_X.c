/*==========================================================
    Template matching function.
    Adapted from MATLAB code by Carlos Vargas
        Jonas Zimmermann (c) 2013

    @version $Id$
    @author Jonas Zimmermann
    Copyright (c) Jonas Zimmermann, Brown University. All rights reserved.

 *========================================================*/

#include "mex.h"
#include "math.h"
#include "temp_match.h"

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    double *wav, *temp;             // input data
    int shift_range;                // 3rd optional input
    double *tmatch, *resmatch, *residue, *shift;  // output matrices
    mwSize nS, nT, sr;              // and their sizes


    /* check for proper number of arguments */
    if ((nrhs!=2) && (nrhs!=3)) {
        mexErrMsgIdAndTxt("DSXII:temp_match_X:nrhs", "This function expects two or three inputs: (wav, temp[, shift_range=1]), where wav is a column vector with M elements, temp is a MxN matrix and shift_range={1,2}.");
    }
    if (nlhs>4) {
        mexErrMsgIdAndTxt("DSXII:temp_match_X:nlhs","At max four output arguments required: tmatch, resmatch, residue, shift.");
    }

    /* make sure the first input argument is type double and real valued */
    if ( !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0])) {
        mexErrMsgIdAndTxt("DSXII:temp_match_X:notDouble","Expects array of double as argument wav.");
    }

    /* make sure the second input argument is type double and real valued */
    if ( !mxIsDouble(prhs[1]) || mxIsComplex(prhs[1])) {
        mexErrMsgIdAndTxt("DSXII:temp_match_X:notDouble","Expects matrix of double as argument temp.");
    }

    /* check that number of columns in first input argument is 1 */
    if (mxGetN(prhs[0]) != 1) {
        mexErrMsgIdAndTxt("DSXII:temp_match_X:notColumnVector","First argument wav has to be a column vector.");
    }

    /* check shift_range (third) argument, and set default value if omitted */
    if (nrhs==3)
    {
        if (mxIsComplex(prhs[2]) || !mxIsNumeric(prhs[2]))
        {
            mexErrMsgIdAndTxt("DSXII:temp_match_X:notScalar","Argument shift_range must be a real scalar.");
        }
        else
        {
            shift_range = (int) mxGetScalar(prhs[2]);
        }
    }
    else
        shift_range = 1;

    /* get input data */
    wav = mxGetPr(prhs[0]);
    temp = mxGetPr(prhs[1]);

    /* get dimensions the input arguments */
    nS = mxGetM(prhs[1]);
    nT = mxGetN(prhs[1]);
    sr = (shift_range * 2 + 1);

    /* Create output matrices */
    plhs[0] = mxCreateDoubleMatrix(sr, nT, mxREAL);
    tmatch = mxGetPr(plhs[0]);
    plhs[1] = mxCreateDoubleMatrix(sr, nT, mxREAL);
    resmatch = mxGetPr(plhs[1]);
    mwSize dims[3] = {nS, sr, nT};
    plhs[2] = mxCreateNumericArray(3, dims, mxDOUBLE_CLASS, mxREAL);
    residue = mxGetPr(plhs[2]);
    plhs[3] = mxCreateDoubleMatrix(sr, nT, mxREAL);
    shift = mxGetPr(plhs[3]);
    // This is the workhorse
    matchTemp(wav, temp, nS, nT, tmatch, resmatch, residue, shift, sr, shift_range);

}
