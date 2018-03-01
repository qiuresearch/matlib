#include "mex.h"
#include "tiffio.h"

void mexFunction(
	int nlhs, mxArray *plhs[],
   int nrhs, mxArray *prhs[])
   {
    uint16 *x;
	 int *Dim, Ndim; 
	 int ival=0;
	 mxClassID data_type;
	 int i, j,k;
	 uint16 ** data_ptrs; 	
  
    // Count the number of required inputs and outputs
	 if(nrhs!=1) {
       mexErrMsgTxt("One input required.");
    } 
    if (nlhs>0) {
       mexErrMsgTxt("Too many outputs.");}

    // Get the array
	 data_type=mxGetClassID(prhs[ival]);	       
	 Ndim = mxGetNumberOfDimensions(prhs[ival]); // Get the dimension	 	 
    if ((data_type!=mxUINT16_CLASS)|| mxIsComplex(prhs[ival])||
         (Ndim!=3))
 	     mexErrMsgTxt("Input must be a noncomplex UINT16 3D array.");  

    Dim=mxGetDimensions(prhs[ival]); // Get matlab's array  	
  	 x = (uint16 *)mxGetData(prhs[ival]);  
    
 	// put x into data_ptrs
	data_ptrs=(uint16 **)malloc(Dim[2]*sizeof(uint16 *));
   for (i=0;i<Dim[2];i++) 
        data_ptrs[i]= (uint16 *)(x+i*Dim[0]*Dim[1]);
      
	 // Write out the arrays
	 for(k=0;k<Dim[2];k++)
   	{ 
			for (i=0;i<Dim[0];i++) 
			{ for (j=0;j<Dim[1];j++) printf("%d ",(data_ptrs[k])[i+j*Dim[0]]);
			  printf("\n");
			}
			printf("\n");
		}     
   }
   
