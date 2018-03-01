#include "mex.h"
#include "tiffio.h"

void mexFunction(
	int nlhs, mxArray *plhs[],
   int nrhs, mxArray *prhs[])
   {
    uint16 *x,*y;
	 int mrows, ncols; 
	 int ival=0;
	 mxClassID data_type;
	 int i, j;
	 int size[2];	
  
    // Count the number of required inputs and outputs
	 if(nrhs!=1) {
       mexErrMsgTxt("One input required.");
    } 
    if (nlhs>1) {
       mexErrMsgTxt("Too many outputs.");}

    // Get the array
	 data_type=mxGetClassID(prhs[ival]);	       
    mrows=mxGetM(prhs[ival]); // Get the size.
    ncols=mxGetN(prhs[ival]);  

	 if ((data_type!=mxUINT16_CLASS)|| mxIsComplex(prhs[ival]))
 	     mexErrMsgTxt("Input must be a noncomplex UINT16 array.");  

  	 x = (uint16 *)mxGetData(prhs[ival]);  
      
	 // Write out the array
	 for(i=0;i<mrows;i++) 
      {for(j=0;j<ncols;j++) printf("%d  ",(int)x[i+j*mrows]);
       printf("\n");}
    
    // Return the array. 
	 size[0]=mrows; size[1]=ncols; 
    plhs[ival] = mxCreateNumericArray(2,size,mxUINT16_CLASS,mxREAL);
    y=(uint16 *)mxGetData(plhs[ival]);
    for(i=0;i<mrows;i++){for(j=0;j<ncols;j++) 
         {y[i+j*mrows]=x[i+j*mrows];}}

     
   }
   
