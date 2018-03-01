#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include "matrix.h"
#include "mex.h"   /* --This one is required */


/* pr_calc(xyzMatrix, Zvals, dMax) */ 
/* mex -O CFLAGS="\$CFLAGS -std=c99" -lm prcalc_noNorm.c */
/* $Id: prcalc_noNorm.c,v 1.2 2015/01/12 17:02:33 schowell Exp $ */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  /* Declarations */
  const mxArray *xyzData, *Zdata, *rMaxP;
  double *xyzVals, *Zvals, dist, *hist, sum=0;
  int i, j;
  int rowLen, colLen, ZrowLen, ZcolLen, rMax=151;
  
  switch (nrhs)  {
  case 2:
    printf("no rMax given\n");
    printf("using default rMax=150\n");
    break;
  case 3:
    rMaxP = prhs[2];
    rMax = (int)(mxGetScalar(rMaxP) ) + 1;
    printf("using rMax = %d\n",rMax-1);
    break;
  default:
    printf("ERROR: Wrong number of input arguments.\n");
    mexErrMsgTxt("Correct usage: pr_calc(xyz, Zeff, rMax)\n");
  }
  
  /* Copy input pointer to xyz, and effZ, then read in their data*/
  xyzData = prhs[0];
  xyzVals = mxGetPr(xyzData);
  rowLen = mxGetN(xyzData);
  colLen = mxGetM(xyzData);
  Zdata = prhs[1];
  Zvals = mxGetPr(Zdata);
  if ( colLen != (ZcolLen = mxGetM(Zdata) ) ) mexErrMsgTxt("ERROR: Array of effective Z values did not match the length of xyz locations!\n");

  if ( 1 != ( ZrowLen = mxGetN(Zdata) ) ) printf("ERROR: Array of effective Z values has %d columns.\nProceeding using 1st column. Results may be unexpected.\n", ZrowLen);

  printf("Calculating p(r) for %d atoms.\n", colLen);

  /* allocate memory for the output histogram */
  if ( NULL == (plhs[0] = mxCreateDoubleMatrix(rMax, 2, mxREAL ) ) ) mexErrMsgTxt("ERROR: failed to allocate memory for result");
  hist = mxGetPr(plhs[0]);

  /*** Main calculation loop: calculate the distance between differnt point and create weighted histogram ***/
  for(i=0;i<colLen-1;i++){
    for(j=i+1;j<colLen;j++){
      /* longer but easier to read: */
      dist = pow(xyzVals[(0*colLen)+i] - xyzVals[(0*colLen)+j],2.0);
      dist += pow(xyzVals[(1*colLen)+i] - xyzVals[(1*colLen)+j],2.0);
      dist += pow(xyzVals[(2*colLen)+i] - xyzVals[(2*colLen)+j],2.0);
      dist = round(sqrt(dist));
      /* more consise but harder to read: */
      //s dist = round( sqrt ( pow(xyzVals[(0*colLen)+i] - xyzVals[(0*colLen)+j],2.0) + pow(xyzVals[(1*colLen)+i] - xyzVals[(1*colLen)+j],2.0) + pow(xyzVals[(2*colLen)+i] - xyzVals[(2*colLen)+j],2.0) ) );

      //printf("distance between points %d and %d: %f %d \n",i,j,dist,dist); //useful for debugging
      if ( dist > rMax || dist < 0 ){
	printf("Distance between points %d and %d is %d.\n", i, j, dist);
	printf("This is outside the range of %d to %d.\n", 0, rMax);
      }
      else if ( dist == dist ){
	hist[rMax + (int)dist ] += Zvals[i] * Zvals[j] ;        // populate the p(r) values
	//hist[ (int)dist ] += Zvals[i] * Zvals[j] ;        // populate the p(r) values
      }
      else {
	printf("ERROR: Problem calculating distance between data %d and %d.\n",i,j);
	printf("Skipped this pair\n");
      }
    }
  }

  /* normalize the result */
  for(i=0; i<rMax; i++){
    hist[i] = i; // these are the distance values (for x-axis)
//     sum += hist[rMax +i];
  }
//   for(i=0; i<rMax; i++){
//     hist[rMax+i] /=sum;
//   }

  return;     // MATLAB mex functions should not have a return value/void
}
