#include "mex.h"
#include "stdio.h"
#include "string.h"

void mexFunction(
	int nlhs, mxArray *plhs[],
   int nrhs, mxArray *prhs[])
   {
    double *x; double *y;
	 int mrows, ncols; 
	 int ival=0;
    int i,j;
    
    // Count the number of required inputs and outputs
	 if(nrhs!=1) {
       mexErrMsgTxt("One input required.");
    } 
    if (nlhs>1) {
       mexErrMsgTxt("Too many outputs.");}

    // Get the double array and check it is the right type.
    mrows=mxGetM(prhs[ival]);
    ncols=mxGetN(prhs[ival]);  
	 if (!mxIsDouble(prhs[ival])|| mxIsComplex(prhs[ival]))
 	   {mexErrMsgTxt("Input must be an array of noncomplex doubles.");}  

  	  x = mxGetPr(prhs[ival]);  
       
    // Print out array.   
    for (i=0;i<mrows;i++) 
       {
          for(j=0;j<ncols;j++)
             {printf("%f  ", x[j*mrows+i]);}
       printf("\n");}
                
                
    // Return the array.  
    plhs[ival] = mxCreateDoubleMatrix(mrows,ncols,mxREAL);
    y=mxGetPr(plhs[ival]);
    for(i=0;i<mrows*ncols;i++) y[i]=x[i];       
   }
   
