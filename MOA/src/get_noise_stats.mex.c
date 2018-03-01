// The portal to get_noise_stats() in Zingers.c
// Written on 22 June, 2000.
// See get_noise_stats.m for details

#include "mex.h"
#include "tiff.h"
#include "Zingers.c"

void mexFunction(
	  int nlhs, mxArray *plhs[],
	  int nrhs, mxArray *prhs[] )
     {
			// Variables needed by get_noise_stats.c
			int num_images;
			uint16 **data_ptrs;
			double *dest;
			int width, height;
			long int bkg; double sigma; double gain;
			int condition;

			// Variables needed for loading and unloading.
			int *Dim, Ndim;			
			mxClassID data_type;
			uint16 *x; int i; double *hold;

			// Check input and output numbers
			if (nrhs!=1)
				{mexErrMsgTxt("Need exactly one input.");}
			if (nlhs>4)
				{mexErrMsgTxt("Only four available outputs.");}

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

			// STEP TWO - call get_noise_stats.
			if (get_noise_stats(num_images,data_ptrs,width,height,
									  &bkg, &sigma, &gain, &condition)!=0)
			mexErrMsgTxt("Problem in get_noise_stats() in Zingers.c");

			// STEP THREE - Returning bkg
		   if (nlhs>0) 
				{
					plhs[0]=mxCreateDoubleMatrix(1,1,mxREAL);
					hold=mxGetPr(plhs[0]); *hold=(double)bkg;				  
				}

			// STEP FOUR - Returning sigma
			if (nlhs>1) 
				{
					plhs[1]=mxCreateDoubleMatrix(1,1,mxREAL);
					hold=mxGetPr(plhs[1]); *hold=sigma;				  
				}

			// STEP FIVE - Returning gain
			if (nlhs>2) 
				{
					plhs[2]=mxCreateDoubleMatrix(1,1,mxREAL);
					hold=mxGetPr(plhs[2]); *hold=gain;				  
				}
	
			// STEP SIX - Returning condition
			if (nlhs>3)
				{
				if ((condition==1)||(condition==2))
					 plhs[3]=mxCreateString("Don't trust Sigma");
				else if (condition==3)	
					 plhs[3]=mxCreateString("Gain not trustworthy.");
				else 
					 plhs[3]=mxCreateString("No Problems noticed.");
				}

  	   // STEP SEVEN - free up memory
		free(data_ptrs);									
		}