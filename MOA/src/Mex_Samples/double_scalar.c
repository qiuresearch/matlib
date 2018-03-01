#include "mex.h"
#include "stdio.h"

void mexFunction(
	int nlhs, mxArray *plhs[],
   int nrhs, mxArray *prhs[])
   {
    double x,*y;
	 int mrows, ncols; 
	 int ival=0;

  
    // Count the number of required inputs and outputs
	 if(nrhs!=1) {
       mexErrMsgTxt("One input required.");
    } 
    if (nlhs>1) {
       mexErrMsgTxt("Too many outputs.");}

    // Get the scalar and check it is the right type.       
    mrows=mxGetM(prhs[ival]);
    ncols=mxGetN(prhs[ival]);  

	 if (!mxIsDouble(prhs[ival])|| mxIsComplex(prhs[ival]) || 
        !(mrows==1 && ncols==1) )
 	     mexErrMsgTxt("Input must be a noncomplex scalar double.");  

  	  x = mxGetScalar(prhs[ival]);  
       
    // Return the scalar.  
    plhs[ival] = mxCreateDoubleMatrix(mrows,ncols,mxREAL);
    y=mxGetPr(plhs[ival]);
    *y=x;
      
   }
   
