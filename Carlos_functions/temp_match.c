/*
//      Spike sorter utility functions
//
//  This is an implementation in C of several functions heavily used by Carlos Vargas-Irwin's
//  Density Spike Sorter.
//  Algorithms used in matchTemp() and temp_match_overlap_X() were developed by Carlos Vargas-Irwin.
//  Implementation by Jonas Zimmermann.
//  (c) 2013 Brown University
//
//  @author  Jonas Zimmermann
//  @version $Id$
*/


#include "mex.h"
#include "math.h"
#include "temp_match.h"

double dmax_array(double *a, mwSize N)
{
   mwSize i;
   double max = -INFINITY;
   for (i=0; i<N; i++)
   {
       if (a[i]>max)
       {
           max=a[i];
       }
   }
   return(max);
}
double dmin_array(double *a, mwSize N)
{
   mwSize i;
   double min = INFINITY;
   for (i=0; i<N; i++)
   {
       if (a[i]<min)
       {
           min=a[i];
       }
   }
   return(min);
}
mwIndex imax_array(mwIndex *a, mwSize N)
{
   mwSize i;
   mwIndex max = INT_MIN;
   for (i=0; i<N; i++)
   {
       if (a[i]>max)
       {
           max=a[i];
       }
   }
   return(max);
}
mwIndex imin_array(mwIndex *a, mwSize N)
{
   mwSize i;
   mwIndex min = INT_MAX;
   for (i=0; i<N; i++)
   {
       if (a[i]<min)
       {
           min=a[i];
       }
   }
   return(min);
}
mwIndex dmin_arg(double *a, mwSize N)
{
    mwIndex i, m = 0;
    double min = a[0];
    for (i = 1; i < N; ++i)
    {
        if (min > a[i])
        {
            m = i;
            min = a[m];
        }
    }
    return(m);
}
mwIndex dmax_arg(double *a, mwSize N)
{
    mwIndex i, m = 0;
    double max = a[0];
    for (i = 1; i < N; ++i)
    {
        if (max < a[i])
        {
            m = i;
            max = a[m];
        }
    }
    return(m);
}

void dmin_args(double * array, mwSize arrayLength, mwIndex **minIndices, mwIndex *minIndicesN)
{
    double currentMinimum = array[0];
    mwIndex currentMinimumIndex = 0, i;
    for(i = 1; i < arrayLength; ++i)
    {
        if (currentMinimum == array[i])
        {
            (*minIndices)[++currentMinimumIndex] = i;
        }
        if (currentMinimum > array[i])
        {
            currentMinimum = array[i];
            currentMinimumIndex = 0;
            (*minIndices)[currentMinimumIndex] = i;
        }
    }
    *minIndicesN = currentMinimumIndex + 1;
    *minIndices = realloc(*minIndices, (*minIndicesN)*sizeof(mwIndex));
}


void matchTemp(double* wav, double* temp, mwSize N, mwSize NT,
    double* tmatch, double* resmatch, double* residue, double* shift, mwSize sr, mwSize shift_range)
{

    double min_wav = dmin_array(wav, N);
    double max_wav = dmax_array(wav, N);
    double *max_temp = mxCalloc(NT, sizeof(double));
    double *min_temp = mxCalloc(NT, sizeof(double));
    mwIndex *max_arg_temp = mxCalloc(NT, sizeof(mwIndex));
    mwIndex *min_arg_temp = mxCalloc(NT, sizeof(mwIndex));
    mwSize t, i, it_n;
    mwIndex mt, mw, mw_max_arg, mw_min_arg, sc, sh, sh_t, *iw, *it, iw_min;
    mw_max_arg = dmax_arg(wav, N);
    mw_min_arg = dmin_arg(wav, N);

    for (t=0; t < NT; ++t)
    {
        max_temp[t] = -INFINITY;
        min_temp[t] = INFINITY;
        for (i=0; i<sr; ++i)
        {
            tmatch[t*sr + i] = INFINITY;
            resmatch[t*sr + i] = INFINITY;
        }
    }
    for(t = 0; t < NT; ++t)
    {
        for (i = 0; i < N; i++)
        {
            if (max_temp[t] < temp[t*N + i])
            {
                max_temp[t] = temp[t*N + i];
                max_arg_temp[t] = i;
            }
            if (min_temp[t] > temp[t*N + i])
            {
                min_temp[t] = temp[t*N + i];
                min_arg_temp[t] = i;
            }
        }
    }
    iw = mxCalloc(2*N+sr, sizeof(mwIndex));
    it = mxCalloc(2*N+sr, sizeof(mwIndex));

    for (t = 0; t < NT; t++)
    {
        if (max_temp[t] > - min_temp[t])
        {
            mt = max_arg_temp[t];
            mw = mw_max_arg;
        }
        else
        {
            mt = min_arg_temp[t];
            mw = mw_min_arg;
        }
        mw -= mt;
        sc = 0;

        for (sh = -shift_range; sh <= shift_range; ++sh)
        {
            sh_t = sh;
            if (mw>0)
            {
                it_n = N + sh - mw;
                for (i = 0; i < it_n; i++)
                {
                    iw[i] = i - sh + mw;
                    it[i] = i;
                }
            }
            else if (mw < 0)
            {
                it_n = N + sh + mw;
                for (i = 0; i < it_n; i++)
                {
                    iw[i] = i;
                    it[i] = i - mw - sh;
                }
            }
            else
            {
                sh_t = sc - 1;
                it_n = N;
                for (i = 0; i < it_n; i++)
                {
                    iw[i] = i;
                    it[i] = i;
                }
            }

            iw_min = imin_array(iw, it_n);

            if ((imax_array(it, it_n)<=N) && (imin_array(it, it_n)>=0) &&
                (imax_array(iw, it_n)<=N ) && (iw_min >=0 ))
            {
                for (i = 0; i < N; ++i)
                {
                    residue[i + N*(sc + t*sr) ] = wav[i];
                }
                for (i = 0; i< it_n; ++i)
                {
                    residue[iw[i]+ N*(sc) + N*sr*t] = wav[iw[i]]-temp[it[i] + t*N];
                }
                if (mw > 0)
                {
                    shift[sc + t*sr] = (double) iw_min + 1;
                }
                else if (mw<0)
                {
                    shift[sc + t*sr] = - (double)it[0] + 1;
                }
                else
                {
                    shift[sc + t*sr] = (double)sh_t +1;
                }

                double maxerr_plw_t=-INFINITY, maxerr_plw_r=-INFINITY;
                for (i = 0; i < it_n; ++i)
                {
                    if (maxerr_plw_t < fabs(residue[iw[i]+N*(sc)+t*sr*N]))
                        maxerr_plw_t = fabs(residue[iw[i]+N*(sc)+t*sr*N]);
                }
                for (i = 0; i < N; ++i)
                {
                    if (maxerr_plw_r < fabs(residue[i+N*(sc)+t*sr*N]))
                        maxerr_plw_r = fabs(residue[i+N*(sc)+t*sr*N]);
                }

                double mn_res = INFINITY, mx_res = -INFINITY,
                    mn_res_t = INFINITY, mx_res_t = -INFINITY,
                    mn_wav_t = INFINITY, mx_wav_t = -INFINITY;
                for (i = 0; i < N; ++i)
                {
                    if (mx_res < residue[i+N*(sc)+t*sr*N])
                        mx_res = residue[i+N*(sc)+t*sr*N];
                    if (mn_res > residue[i+N*(sc)+t*sr*N])
                        mn_res = residue[i+N*(sc)+t*sr*N];
                }
                for (i = 0; i < it_n; ++i)
                {
                    if (mx_wav_t < wav[iw[i]])
                        mx_wav_t = wav[iw[i]];
                    if (mn_wav_t > wav[iw[i]])
                        mn_wav_t = wav[iw[i]];
                    if (mx_res_t < residue[iw[i]+N*(sc)+t*sr*N])
                        mx_res_t = residue[iw[i]+N*(sc)+t*sr*N];
                    if (mn_res_t > residue[iw[i]+N*(sc)+t*sr*N])
                        mn_res_t = residue[iw[i]+N*(sc)+t*sr*N];
                }
                if ((mn_res_t < mn_wav_t) || (mx_res_t > mx_wav_t))
                {
                    maxerr_plw_t = INFINITY;
                }
                if ((mn_res<min_wav) || (mx_res > max_wav))
                {
                    maxerr_plw_r = INFINITY;
                }
                tmatch[sc + t*sr] = maxerr_plw_t;
                resmatch[sc + t*sr] = maxerr_plw_r;
            }
            ++sc;
        }
    }

    mxFree(iw);
    mxFree(it);
    mxFree(max_temp);
    mxFree(min_temp);
    mxFree(max_arg_temp);
    mxFree(min_arg_temp);
}

void printFArr(double*a, int n)
{
    int i ;
    mexPrintf("Array: ");
    for(i = 0; i < n; ++i)
    {
        mexPrintf("%f\t", a[i]);
    }
    mexPrintf("\n");
}


void tempMatchOverlap(double *wav, double *temp, mwSize N, mwSize NT, double th_o,
    double *final_match, double *final_shift)
{
    int sr = (SHIFT_RANGE * 2 + 1);
    mwIndex i,j, t, t2, t3, s, s2; // indices
    mwSize NT2 = 1;

    double *t_match = mxCalloc(sr*NT, sizeof(double));
    double *tm2 = mxCalloc(sr*NT2, sizeof(double));
    double *tm3 = mxCalloc(sr*NT2, sizeof(double));
    double *r_match = mxCalloc(sr*NT, sizeof(double));
    double *rm2 = mxCalloc(sr*NT2, sizeof(double));
    double *rm3 = mxCalloc(sr*NT2, sizeof(double));
    double *residue = mxCalloc(N*sr*NT, sizeof(double));
    double *residue2 = mxCalloc(N*sr*NT*sr*NT, sizeof(double));
    double *res = mxCalloc(N*sr*NT2, sizeof(double));
    double *t_shift = mxCalloc(sr*NT, sizeof(double));
    double *t_shift2 = mxCalloc(sr*NT*sr*NT, sizeof(double));
    double *t_shift3 = mxCalloc(sr*NT*sr*NT, sizeof(double));
    double *sh = mxCalloc(sr*NT2, sizeof(double));
    double *wav2 = mxCalloc(N, sizeof(double));
    double *temp2 = mxCalloc(N, sizeof(double));
    double *r2amp = mxCalloc(sr, sizeof(double));

    matchTemp(wav, temp, N, NT, t_match, r_match, residue, t_shift, sr, SHIFT_RANGE);

    //final_match = (double*) mxCalloc(NT, sizeof(double));
    mwIndex *ix = mxCalloc(NT, sizeof(mwIndex));

    if ((dmin_array(t_match, sr*NT)<th_o) || (dmin_array(r_match, sr*NT)<th_o) || (dmin_array(t_match, sr*NT)==INFINITY) || (dmin_array(r_match, sr*NT)==INFINITY))
    {
        for (j = 0; j < NT; ++j)
        {
            final_match[j] = t_match[j*sr];
            ix[j] = 0;

            for (i = 1; i < sr; ++i)
            {
                if (final_match[j] > t_match[i + j*sr])
                {
                    final_match[j] = t_match[i + j*sr];
                    ix[j] = i;
                }
            }
        }

        double final_match_min = dmin_array(final_match, NT);

        for (i = 0; i < NT; ++i)
        {
            final_shift[i] = t_shift[ix[i] + sr*i];
            if (final_match[i] != final_match_min)
                final_match[i] = INFINITY;
        }
        return;
    }
    for (i = 0; i < NT; ++i)
        final_match[i] = INFINITY;

    for (i = 0; i < NT; ++i)
    {
        for (j = 0; j < sr; ++j)
        {
            if (t_match[j + sr * i] < final_match[i])
                final_match[i] = t_match[j + sr * i];
        }
    }

    double min_amp_res2 = INFINITY, min_tm2, min_tm3;
    mwIndex shi2, shi3;


    double min_r2amp, final_match_min;

    for (t = 0; t < NT; ++t)
    {
        for (t2 = 0; t2 < NT; ++t2)
        {
            if (t != t2)
            {
                for (s = 0; s < sr; ++s)
                {
                    for (i = 0; i < N; ++i)
                    {
                        wav2[i] = residue[i + N*(s + sr * t)];
                        temp2[i] = temp[i + N*t2];
                    }
                    matchTemp(wav2, temp2, N, NT2, tm2, rm2, res, sh, sr, SHIFT_RANGE);

                    for (i = 0; i < sr; ++i)
                    {
                        r2amp[i] = dmax_array(res + i*sr, N) - dmin_array(res + i*sr, N);
                    }
                    min_r2amp = dmin_array(r2amp, sr);
                    if (min_r2amp < min_amp_res2)
                        min_amp_res2 = min_r2amp;

                    for (j = 0; j < sr; ++j)
                    {
                        for (i = 0; i < N; ++i)
                        {
                            residue2[i + N*(j + sr*(t2 + NT*(s + sr*t)))] = res[i + N*j];
                        }
                        t_shift2[j + sr*(t2 + NT*(s + sr * t))] = sh[j];
                    }
                    min_tm2 = dmin_array(tm2, sr);
                    shi2 = dmin_arg(tm2, sr);
                    min_tm2 = max(min_tm2, rm2[shi2]);

                    if ((min_tm2<final_match[t]) && (min_tm2<final_match[t2]) &&  ( rm2[shi2]<final_match[t] ) &&  ( rm2[shi2]<final_match[t2] ))
                    {
                        final_match[t]  = min_tm2;
                        final_match[t2] = min_tm2;
                        final_shift[t]  = t_shift[s + sr*t];
                        final_shift[t2] =  t_shift2[shi2 + sr*(t2 + NT*(s + sr*t))];

                        if (min_tm2 < th_o)
                        {
                            final_match_min = dmin_array(final_match, NT);

                            for (i = 0; i < NT; ++i)
                            {
                                if (final_match[i] > final_match_min)
                                    final_match[i] = INFINITY;
                            }
                            return;
                        }
                    }
                }
            }
        }
    }
    for (t = 0; t < NT; ++t)
    {
        for (t2 = 0; t2 < NT; ++t2)
        {
            for (t3 = 0; t3 < NT; ++t3)
            {
                if ((t != t2) && (t != t3) && (t2 != t3))
                {
                    for (s = 0; s < sr; ++s)
                    {
                        for (s2 = 0; s2 < sr; ++s2)
                        {
                            for (i = 0; i < N; ++i)
                            {
                                wav2[i] = residue2[i + N*(s2 + sr * (t2 + NT*(s + sr*t)))];
                                temp2[i] = temp[i + N*t3];
                            }
                            matchTemp(wav2, temp2, N, NT2, tm3, rm3, res, t_shift3, sr, SHIFT_RANGE);
                            min_tm3 = dmin_array(tm3, sr);
                            shi3 = dmin_arg(tm3, sr);
                            min_tm3 = max(min_tm3, rm3[shi3]);
                            if ((min_tm3 < final_match[t]) && (min_tm3 < final_match[t2]) && (min_tm3 < final_match[t3])  &&  ( rm3[shi3] < final_match[t] ) &&  ( rm3[shi3] < final_match[t2] )  &&  ( rm3[shi3] < final_match[t3] ))
                            {

                                final_match[t]  = min_tm3;
                                final_match[t2] = min_tm3;
                                final_match[t3] = min_tm3;

                                final_shift[t] = t_shift[s+sr*t];
                                final_shift[t2] = t_shift2[s2 + sr*(t2 + NT*(s + sr*t))];
                                final_shift[t3] = t_shift3[shi3];
                                if (min_tm3 < th_o)
                                {
                                    final_match_min = dmin_array(final_match, NT);

                                    for (i = 0; i < NT; ++i)
                                    {
                                         if (final_match[i] > final_match_min)
                                         {
                                            final_match[i] = INFINITY;
                                        }
                                    }
                                    return;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    final_match_min = dmin_array(final_match, NT);
//    printFArr(final_match, NT);
//    mexPrintf("Last loop %f\n", final_match_min);
    for (i = 0; i < NT; ++i)
    {
         if (final_match[i] > final_match_min)
         {
             final_match[i] = INFINITY;
         }
    }

    //*
    mxFree(t_match);
    mxFree(tm2);
    mxFree(tm3);
    mxFree(r_match);
    mxFree(rm2);
    mxFree(rm3);
    mxFree(residue);
    mxFree(residue2);
    mxFree(res);
    mxFree(t_shift);
    mxFree(t_shift2);
    mxFree(t_shift3);
    mxFree(sh);
    mxFree(wav2);
    mxFree(temp2);
    mxFree(r2amp);
    mxFree(ix);


    //*/
}
