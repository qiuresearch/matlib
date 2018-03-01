// The portal to remove_zingers() in Zingers.c
// Written on 21 June, 2000.
// See remove_zingers.m for details

#include "mex.h"
#include "tiff.h"
#include "Zingers.c"

void mexFunction(
	  int nlhs, mxArray *plhs[],
	  int nrhs, mxArray *prhs[] )
     {
			// Variables needed by remove_zingers.c
			int num_images;
			uint16 **data_ptrs;
			double *dest;
			int width, height;
			long int bkg; double sigma; double sigma_cut; double gain;
			long int num_zingers;

			// Variables needed for loading and unloading.
			int *Dim, Ndim;			
			mxClassID data_type;
			uint16 *x; int i;
			int j,k;
			int mrows, ncols;
			double *hold;

			// Check input and output numbers
			if (nrhs!=5)
				{mexErrMsgTxt("Need exactly five inputs");}
			if ((nlhs>2)||(nlhs<1))
				{mexErrMsgTxt("Need one or two outputs.");}

			// STEP ONE - Getting num_images, data_ptrs, width, height 	
    
         // Get the array
	      data_type=mxGetClassID(prhs[0]);	       
	      Ndim = mxGetNumberOfDimensions(prhs[0]); // Get the dimension	 	 
         if ((data_type!=mxUINT16_CLASS)|| mxIsComplex(prhs[0])||
             (Ndim!=3))
 	           mexErrMsgTxt("images must be a noncomplex UINT16 3D array.");  

			// Check the array sizes
			Dim=mxGetDimensions(prhs[0]); // Get matlab's array  	
			num_images=Dim[2]; width=Dim[0]; height=Dim[1];
			if (num_images<2) 
				  mexErrMsgTxt("Must have at least two images to dezinger.");

			// Finally suck out the data.
			x = (uint16 *)mxGetData(prhs[0]);  
	      data_ptrs=(uint16 **)malloc(num_images*sizeof(uint16 *));
         for (i=0;i<num_images;i++) 
             data_ptrs[i]= (uint16 *)(x+i*Dim[0]*Dim[1]);

			// STEP TWO - GETTING bkg
			mrows=mxGetM(prhs[1]); ncols=mxGetN(prhs[1]);  
         if (!mxIsDouble(prhs[1])|| mxIsComplex(prhs[1]) || 
             !(mrows==1 && ncols==1) )
 	      mexErrMsgTxt("bkg must be a noncomplex scalar double.");		
         bkg = (long int)(mxGetScalar(prhs[1])+0.5);

			// STEP THREE - GETTING sigma
		   mrows=mxGetM(prhs[2]); ncols=mxGetN(prhs[2]);  
         if (!mxIsDouble(prhs[2])|| mxIsComplex(prhs[2]) || 
             !(mrows==1 && ncols==1) )
 	        mexErrMsgTxt("sigma must be a noncomplex scalar double.");		
         sigma = mxGetScalar(prhs[2]);
			if (sigma<0) 
           mexErrMsgTxt("sigma must be a positive real number");

		// STEP FOUR - GETTING sigma_cut
			 mrows=mxGetM(prhs[3]); ncols=mxGetN(prhs[3]);  
         if (!mxIsDouble(prhs[3])|| mxIsComplex(prhs[3]) || 
             !(mrows==1 && ncols==1) )
 	        mexErrMsgTxt("sigma_cut must be a noncomplex scalar double.");		
         sigma_cut = mxGetScalar(prhs[3]);
			if (sigma_cut<0) 
           mexErrMsgTxt("sigma_cut must be a positive real number");

		// STEP FIVE - Getting gain
		    mrows=mxGetM(prhs[4]); ncols=mxGetN(prhs[4]);  
         if (!mxIsDouble(prhs[4])|| mxIsComplex(prhs[4]) || 
             !(mrows==1 && ncols==1) )
 	        mexErrMsgTxt("gain must be a noncomplex scalar double.");		
         gain = mxGetScalar(prhs[4]);
			if (gain<0) 
           mexErrMsgTxt("gain must be a positive real number");

		// STEP SIX - assign result
		   plhs[0] = mxCreateDoubleMatrix(width,height,mxREAL);
         dest=mxGetPr(plhs[0]);
	
		// STEP SEVEN - call remove_zinger.c
		remove_zingers(num_images, data_ptrs, dest, width, height,
							bkg, sigma, sigma_cut, gain, &num_zingers);

		// STEP EIGHT - return number of zingers if requested.
		if (nlhs==2)
		   {
				plhs[1]=mxCreateDoubleMatrix(1,1,mxREAL);
				hold = mxGetPr(plhs[1]); *hold=(double)num_zingers;		      
			}
	
  	   // STEP NINE - free up memory
		free(data_ptrs);
									
		}