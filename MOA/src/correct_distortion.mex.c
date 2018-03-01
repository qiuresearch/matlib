// The portal to correct_distortion() in CCD_Correction.c
// Written on 21 June, 2000.
// See correct_distortion.m for details

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
	   float *x_map; float *y_map;
		int width; int height; 
		
		// Variables needed for loading and unloading.
		mxClassID data_type;
		int mrows, ncols;
		int i,j;	

		// Check number of outputs and inputs.
		if (nrhs!=3)
		  {mexErrMsgTxt("Three inputs required.");}
      if (nlhs!=1) 
        {mexErrMsgTxt("Need one output.");}
	
		// STEP ONE - Get the image and width*height
		// Get the double array and check it is the right type.
      if (!mxIsDouble(prhs[0])|| mxIsComplex(prhs[0]))
 	   mexErrMsgTxt("Image input should be an array of noncomplex doubles.");
      width=mxGetM(prhs[0]);
      height=mxGetN(prhs[0]);  
      image = mxGetPr(prhs[0]);  	

      // STEP TWO - Get the x_map correction file.
      data_type=mxGetClassID(prhs[1]);	       
      mrows=mxGetM(prhs[1]); 
      ncols=mxGetN(prhs[1]);  

  	   if ((data_type!=mxSINGLE_CLASS)|| mxIsComplex(prhs[1]))
			 {mexErrMsgTxt("x_map must be of an array of noncomplex singles.");}
		if ((mrows!=width)||(ncols!=height))
 	       mexErrMsgTxt("x_map array must be same size as image.");  
    	x_map = (float *)mxGetData(prhs[1]);  

		
      // STEP THREE - Get the y_map correction file.
      data_type=mxGetClassID(prhs[2]);	       
      mrows=mxGetM(prhs[2]); 
      ncols=mxGetN(prhs[2]);  

  	   if ((data_type!=mxSINGLE_CLASS)|| mxIsComplex(prhs[2]))
			 {mexErrMsgTxt("y_map must be of an array of noncomplex singles.");}
		if ((mrows!=width)||(ncols!=height))
 	       mexErrMsgTxt("y_map array must be same size as image.");  
    	y_map = (float *)mxGetData(prhs[2]);  

		// STEP FOUR - Allocate memory for result		
		 plhs[0] = mxCreateDoubleMatrix(width,height,mxREAL);
       result=mxGetPr(plhs[0]);

 		// STEP FIVE - call correct_distortion.c
		if (correct_distortion(result,image,x_map,y_map,width,height)!=0)
			mexErrMsgTxt("Error occured in correct_distortion.c");
     }