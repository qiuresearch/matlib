// The portal to correct_intensity() in CCD_Correction.c
// Written on 21 June, 2000.
// See correct_intensity.m for details

// Rows in matlab correspond to x in C.
// Columns in matlab correspond to y in C.

#include "mex.h"
#include "CCD_Correction.c"

void mexFunction(
	  int nlhs, mxArray *plhs[],
	  int nrhs, mxArray *prhs[] )
     {

      // Variables needed by radial_integral
		double *result; double *image;
	   float *intensity_map;
		int width; int height; 
		
		// Variables needed for loading and unloading.
		mxClassID data_type;
		int mrows, ncols;

		// Check number of outputs and inputs.
		if (nrhs!=2)
		  {mexErrMsgTxt("Two inputs required.");}
      if (nlhs!=1) 
        {mexErrMsgTxt("Need one output.");}
	
		// STEP ONE - Get the image and width*height
		// Get the double array and check it is the right type.
      if (!mxIsDouble(prhs[0])|| mxIsComplex(prhs[0]))
 	   mexErrMsgTxt("Image input should be an array of noncomplex doubles.");
      width=mxGetM(prhs[0]);
      height=mxGetN(prhs[0]);  
      image = mxGetPr(prhs[0]);  	

      // STEP TWO - Get the intensity_map correction file.
      data_type=mxGetClassID(prhs[1]);	       
      mrows=mxGetM(prhs[1]); 
      ncols=mxGetN(prhs[1]);  

  	   if ((data_type!=mxSINGLE_CLASS)|| mxIsComplex(prhs[1]))
			 {mexErrMsgTxt("intensity_map must be of an array of noncomplex singles.");}
		if ((mrows!=width)||(ncols!=height))
 	       mexErrMsgTxt("intensity_map array must be same size as image.");  
    	intensity_map = (float *)mxGetData(prhs[1]);  

		// STEP THREE - Allocate memory for result		
		 plhs[0] = mxCreateDoubleMatrix(width,height,mxREAL);
       result=mxGetPr(plhs[0]);

		// STEP FOUR - call correct_intensity.c
		if (correct_intensity(result,image,intensity_map,width,height)!=0)
			mexErrMsgTxt("Error occured in correct_distortion.c");

     }