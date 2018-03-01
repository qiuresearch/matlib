/*  Blatant copy and adaptation of ctake.mex.c 
(ctake2 uses _read, _open, etc.; ctake uses fread, fopen, etc.)
adsctake (this code) is for reading in ADSC MacCHESS images.
ctake, ctake2 (not the code) is for reading images from Simon Mochrie's
detector at the APS.

Image is 2,654,720 bytes and 1152x1152.  2654720/(1152*1152)=2.0158.  
=> 2 bytes per point, or 16bit.

compile by typing "mex -output adsctake adsctake.mex.c" at matlab prompt.
NO byteswap involved!!!!

*/

#include "mex.h"
#include "tiff.h"
#include "fcntl.h"
#include "stdio.h"
#include "stdlib.h"

void mexFunction(
	  int nlhs, mxArray *plhs[],
	  int nrhs, const mxArray *prhs[] )
   
    {
    int offset = 512;
    int udim = 1152;
    int vdim = 1152;
    char * filename;
    double * data;
    int ncols, status;
    FILE * fd;
    uint16 * data16; uint8 * ptr1;
    long int range, j,k;
    int diagnostic=0;   
    
       /* Check input and output numbers */
		 if (nlhs!=1)
			mexErrMsgTxt("Need one output.");
       if (nrhs!=1)
			mexErrMsgTxt("Need a filename input.");

		 /* Get the filename */
       if (mxIsChar(prhs[0])!=1)
	          {mexErrMsgTxt("Filename must be a string.");}
           if (mxGetM(prhs[0])!=1) 
             {mexErrMsgTxt("Filename must be a row vector.");}
           ncols=mxGetN(prhs[0])+1;  /* Allocating memory */
	        filename=mxCalloc(ncols,sizeof(char));
           status=mxGetString(prhs[0],filename,ncols);
           if (status!=0)
	         mexWarnMsgTxt("Not enough space.  Filename Truncated..");
	         
       /* Create the array to return the value to. */
  	    plhs[0] = mxCreateDoubleMatrix(vdim,udim,mxREAL);
        data=mxGetPr(plhs[0]);
	
       /* Open File */
         
        /*fd = fopen(filename,"r");
        mexPrintf("\nOpening image file\n");
		if (fd== NULL)*/        
		
        if ((fd = fopen(filename,"r")) == NULL)
		{
			/*fprintf(stderr,"ctake could not open filename %s.", filename);*/
			mexPrintf("\nctake could not open flename %s.\n", filename);
			mexErrMsgTxt("   - Check flename and make sure you are in the same directory as file.");
		}
        
		/*mexPrintf("\nPositioning pointer\n");*/
		/* Position the pointer */
		fseek(fd, offset, SEEK_SET);
		/* Read the file */
        range = udim*vdim;
		data16=mxCalloc(range,sizeof(uint16));
        fread(data16,2,range,fd); 
		
		/* Do the byte flip and array index flip. */
  		for (j=0;j<udim;j++)
  		for (k=0;k<vdim;k++)
		   { ptr1=(uint8*)(data16+k*udim+j);
		     /*data[j*vdim+k]=(double)(ptr1[0]*256 + ptr1[1]); */
		     data[j*vdim+k]=(double)(ptr1[1]*256 + ptr1[0]); 
		     /*printf("%d\n", ptr1[0]);*/
	             /*fprintf(stdout, "testing"); */
		     	/*if(j*k<200){
			mexPrintf("%d testing",ptr1[0]); 
			}*/
		     /*printf("%d  %d  %d \n", k,j, (int)data16[j*vdim+k]); */
                     /*data[j*vdim+k]=(double)data16[k*udim+j]; */
		     }
          
       /* free memory and close file */
			/*free(filename); free(data16);*/
			          /*freeing memory with free() can cause matlab 
			          to crash; use mxFree instead
			          */
			mxFree(filename); mxFree(data16);
			fclose(fd);
		
			/* mexPrintf("That's all folks");*/
      } /*function end*/
 

/*
Note: see Matlab Solution Number 31621 on www.mathworks.com to read information
on why exit() cannot be used in mex files.  The short of it is that exit() will cause
not only the MEX process to exit, but also the parent process, which is Matlab itself.
*/





