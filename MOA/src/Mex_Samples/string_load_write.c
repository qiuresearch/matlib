#include "mex.h"
#include "stdio.h"

void mexFunction(
	int nlhs, mxArray *plhs[],
   int nrhs, mxArray *prhs[])
   {
	 char *input_buf;
	 int ncols; 
	 int ival=0;
	 int status;
  
    // Count the number of required inputs and outputs
	 if(nrhs!=1) {
       mexErrMsgTxt("One input required.");
    } 
    if (nlhs>1) {
       mexErrMsgTxt("Too many outputs.");}

    // Get the string      
    if (mxIsChar(prhs[ival])!=1)
	     {mexErrMsgTxt("Input must be a string.");}
    if (mxGetM(prhs[0])!=1) 
        {mexErrMsgTxt("Input must be a row vector.");}
    ncols=mxGetN(prhs[ival])+1;  // Allocating memory 
	 input_buf=mxCalloc(ncols,sizeof(char));
    status=mxGetString(prhs[ival],input_buf,ncols);
    if (status!=0)
	      mexWarnMsgTxt("Not enough space.  String truncated.");
	
 
    //  print the string
	 printf("%s\n", input_buf);

    // return the string
    plhs[ival]=mxCreateString(input_buf);
   }
   
