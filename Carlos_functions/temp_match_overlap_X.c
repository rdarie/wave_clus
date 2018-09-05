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
    double th_o;                // 3rd optional input
    double *final_match, *final_shift;  // output matrices
    mwSize nS, nT;              // and their sizes


    /* check for proper number of arguments */
    if ((nrhs!=3)) {
        mexErrMsgIdAndTxt("DSXII:temp_match_X:nrhs", "This function expects three inputs: (wav, temp, th_o), where wav is a column vector with M elements, temp is a MxN matrix and shift_range={1,2}.");
    }
    if (nlhs>2) {
        mexErrMsgIdAndTxt("DSXII:temp_match_X:nlhs","At max two output arguments required: final_match, final_shift.");
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
    if (mxIsComplex(prhs[2]) || !mxIsNumeric(prhs[2]))
    {
        mexErrMsgIdAndTxt("DSXII:temp_match_X:notScalar","Argument shift_range must be a real scalar.");
    }
    else
    {
        th_o = mxGetScalar(prhs[2]);
    }

    /* get input data */
    wav = mxGetPr(prhs[0]);
    temp = mxGetPr(prhs[1]);

    /* get dimensions the input arguments */
    nS = mxGetM(prhs[1]);
    nT = mxGetN(prhs[1]);

    /* Create output matrices */
    plhs[0] = mxCreateDoubleMatrix(1, nT, mxREAL);
    final_match = mxGetPr(plhs[0]);
    plhs[1] = mxCreateDoubleMatrix(1, nT, mxREAL);
    final_shift = mxGetPr(plhs[1]);
    // This is the workhorse
    tempMatchOverlap(wav, temp, nS, nT, th_o, final_match, final_shift);

}
