// The portal to get_noise_data() in Zingers.c
// Written on 22 June, 2000.
// See get_noise_data.m for details

#include "mex.h"
#include "tiff.h"
#include "Zingers.c"
#include "string.h"

void mexFunction(
	  int nlhs, mxArray *plhs[],
	  int nrhs, mxArray *prhs[] )
     {
			// Variables needed by get_noise_data.c
			int num_images;
			uint16 **data_ptrs;
			int width, height;
			double exclude_width, exclude_height, fraction;
			double * Variance; double * Intensity; long int Npoints;  

			// Variables needed for loading and unloading.
			int *Dim, Ndim;			
			mxClassID data_type;
			uint16 *x; int i;
			int mrows, ncols;

			// Check input and output numbers
			if (nrhs!=4)
				{mexErrMsgTxt("Need exactly four inputs");}
			if (nlhs!=2)
				{mexErrMsgTxt("Need two outputs.");}

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
				  mexErrMsgTxt("Must have at least two images to compare.");

			// Finally suck out the data.
			x = (uint16 *)mxGetData(prhs[0]);  
	      data_ptrs=(uint16 **)malloc(num_images*sizeof(uint16 *));
         for (i=0;i<num_images;i++) 
             data_ptrs[i]= (uint16 *)(x+i*Dim[0]*Dim[1]);

			// STEP TWO - Getting exclude_width
			mrows=mxGetM(prhs[1]); ncols=mxGetN(prhs[1]);  
         if (!mxIsDouble(prhs[1])|| mxIsComplex(prhs[1]) || 
             !(mrows==1 && ncols==1) )
 	      mexErrMsgTxt("exclude_width must be a noncomplex scalar double.");		
         exclude_width = mxGetScalar(prhs[1]);
			if ((exclude_width<0.0)||(exclude_width>1.0))
				mexErrMsgTxt("exclude_width must be between 0 and 1.");
			
		   // STEP THREE - Getting exclude_height
			mrows=mxGetM(prhs[2]); ncols=mxGetN(prhs[2]);  
         if (!mxIsDouble(prhs[2])|| mxIsComplex(prhs[2]) || 
             !(mrows==1 && ncols==1) )
 	      mexErrMsgTxt("exclude_height must be a noncomplex scalar double.");		
         exclude_height = mxGetScalar(prhs[2]);
			if ((exclude_height<0.0)||(exclude_height>1.0))
				mexErrMsgTxt("exclude_height must be between 0 and 1.");

			 // STEP FOUR - Getting fraction
			mrows=mxGetM(prhs[3]); ncols=mxGetN(prhs[3]);  
         if (!mxIsDouble(prhs[3])|| mxIsComplex(prhs[3]) || 
             !(mrows==1 && ncols==1) )
 	      mexErrMsgTxt("exclude_height must be a noncomplex scalar double.");		
         fraction = mxGetScalar(prhs[3]);
			if ((fraction<0.0)||(fraction>1.0))
				mexErrMsgTxt("fraction must be between 0 and 1.");

			// STEP FIVE - Call get_noise_data()
			get_noise_data(num_images,data_ptrs,width,height,
								exclude_width,exclude_height,fraction,
								&Intensity, &Variance, &Npoints);

	 		// STEP SIX - Return Intensity	
		   plhs[0] = mxCreateDoubleMatrix(1,Npoints,mxREAL);
	      memcpy(mxGetPr(plhs[0]), Intensity, Npoints*sizeof(double));	

			// STEP SEVEN - Return variance
	 	   plhs[1] = mxCreateDoubleMatrix(1,Npoints,mxREAL);
	      memcpy(mxGetPr(plhs[1]), Variance, Npoints*sizeof(double));		
	
	  	   // STEP NINE - free up memory
		free(data_ptrs); free(Intensity); free(Variance);								
		}