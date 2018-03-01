#include "mex.h"
#include "stdio.h"



void mexFunction(
	int nlhs, mxArray *plhs[],
   int nrhs, mxArray *prhs[])
   {
    double x;
	 int mrows, ncols; 
	 int ival=0;

  
    // Count the number of required inputs
	 if(nrhs!=1) {
       mexErrMsgTxt("One input required.");
    } 

    // Get the scalar and check it is right.
       
    mrows=mxGetM(prhs[ival]);
    ncols=mxGetN(prhs[ival]);  

	 if (!mxIsDouble(prhs[ival])|| mxIsComplex(prhs[ival]) || 
        !(mrows==1 && ncols==1) )
 	     mexErrMsgTxt("Input must be a noncomplex scalar double.");  

  	  x = mxGetScalar(prhs[ival]);  
  

     printf("%f \n",x);  
      
   }
   
