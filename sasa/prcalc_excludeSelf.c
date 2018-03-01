#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include "matrix.h"
#include "mex.h"   /* --This one is required */


/* pr_calc(xyzMatrix1, Zvals1, xyzMatrix2, Zvals2, dMax) */ 
/* mex -O CFLAGS="\$CFLAGS -std=c99" -lm prcalc_excludeSelf.c */
/* $Id: prcalc_excludeSelf.c,v 1.2 2015/01/12 17:02:33 schowell Exp $ */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  /* Declarations */
  const mxArray *xyzData1, *Zdata1, *xyzData2, *Zdata2, *rMaxP;
  double *xyzVals1, *Zvals1, *xyzVals2, *Zvals2, dist, *hist, sum=0;
  int i, j;
  int rowLen1, colLen1, rowLen2, colLen2, ZrowLen1, ZcolLen1, ZrowLen2, ZcolLen2, rMax=151;
  
  switch (nrhs)  {
  case 4:
    printf("no rMax given\n");
    printf("using default rMax=150\n");
    break;
  case 5:
    rMaxP = prhs[4];
    rMax = (int)(mxGetScalar(rMaxP) ) + 1;
    printf("using rMax = %d\n",rMax-1);
    break;
  default:
    printf("ERROR: Wrong number of input arguments.\n");
    mexErrMsgTxt("Correct usage: pr_calc(xyz1, Zeff1, xyz2, Zeff2, rMax)\n");
  }
  
  /* Copy input pointer to xyz, and effZ, then read in their data*/
  xyzData1 = prhs[0];
  xyzVals1 = mxGetPr(xyzData1);
  rowLen1 = mxGetN(xyzData1);
  colLen1 = mxGetM(xyzData1);
  Zdata1 = prhs[1];
  Zvals1 = mxGetPr(Zdata1);
  if ( colLen1 != (ZcolLen1 = mxGetM(Zdata1) ) ) mexErrMsgTxt("ERROR: Array of effective Z_1 values did not match the length of xyz_1 locations!\n");
  if ( 1 != ( ZrowLen1 = mxGetN(Zdata1) ) ) printf("ERROR: Array of effective Z_1 values has %d columns.\nProceeding using 1st column. Results may be unexpected.\n", ZrowLen1);
  
  xyzData2 = prhs[2];
  xyzVals2 = mxGetPr(xyzData2);
  rowLen2 = mxGetN(xyzData2);
  colLen2 = mxGetM(xyzData2);
  Zdata2 = prhs[3];
  Zvals2 = mxGetPr(Zdata2);
  if ( colLen2 != (ZcolLen2 = mxGetM(Zdata2) ) ) mexErrMsgTxt("ERROR: Array of effective Z_2 values did not match the length of xyz_2 locations!\n");
  if ( 1 != ( ZrowLen2 = mxGetN(Zdata2) ) ) printf("ERROR: Array of effective Z_2 values has %d columns.\nProceeding using 1st column. Results may be unexpected.\n", ZrowLen2);

  printf("Calculating distances between %d and %d atoms.\n", colLen1, colLen2);

  /* allocate memory for the output histogram */
  if ( NULL == (plhs[0] = mxCreateDoubleMatrix(rMax, 2, mxREAL ) ) ) mexErrMsgTxt("ERROR: failed to allocate memory for result");
  hist = mxGetPr(plhs[0]);

  /*** Main calculation loop: calculate the distance between different point and create weighted histogram ***/
  for(i=0;i<colLen1;i++){
    for(j=0;j<colLen2;j++){
      /* longer but easier to read: */
      dist =  pow(xyzVals1[(0*colLen1)+i] - xyzVals2[(0*colLen2)+j],2.0);
      dist += pow(xyzVals1[(1*colLen1)+i] - xyzVals2[(1*colLen2)+j],2.0);
      dist += pow(xyzVals1[(2*colLen1)+i] - xyzVals2[(2*colLen2)+j],2.0);
      dist = round(sqrt(dist));

      //printf("distance between points %d and %d: %f %d \n",i,j,dist,dist); //useful for debugging
      if ( dist > rMax || dist < 0 ){
	printf("Distance between pdb1 point %d and pdb2 point %d is %d.\n", i, j, dist);
	printf("This is outside the range of %d to %d.\n", 0, rMax);
	mexErrMsgTxt("review error to correct problem and re-run\n");
      }
      else if ( dist == dist ){
	hist[rMax + (int)dist ] += Zvals1[i] * Zvals2[j] ;        // populate the p(r) values
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
    hist[i] = i;  // this creates the dist values for the x-axis
//     sum += hist[rMax +i];
  }
//   for(i=0; i<rMax; i++){
//     hist[rMax+i] /=sum;
//   }

  return;     // MATLAB mex functions should not have a return value/void
}
