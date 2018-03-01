/*  This is a clone of ctake.m written by Lisa Kwok - Pollack Matlab guru.
//  Written on 28 July, 2002.
// Note, has at least 1 bug.
// Will fix, one day.
// Does not actually load whole of simon Mochrie's image.
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
    int offset = 1024;
    int udim = 1242;
    int vdim = 1152;
    char * filename;
    double * data;
    int ncols, status;
    FILE * fd;
    uint16 * data16; uint8 * ptr1;
    long int range, j,k;
   
    
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
			mexPrintf("\nctake could not open filename %s.\n", filename);
			mexErrMsgTxt("   - Check filename and make sure you are in the same directory as file.");
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
		     data[j*vdim+k]=(double)(ptr1[0]*256 + ptr1[1]); 
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
		
			/*mexPrintf("That's all folks");*/
      } /*function end*/
 

/*
Note: see Matlab Solution Number 31621 on www.mathworks.com to read information
on why exit() cannot be used in mex files.  The short of it is that exit() will cause
not only the MEX process to exit, but also the parent process, which is Matlab itself.
*/





