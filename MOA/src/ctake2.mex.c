/*  This is a clone of ctake.m written by Lisa Kwok - Pollack Matlab guru.
  Written on 28 July, 2002.
 Note, has at least 1 bug.
 Will fix, one day.
 Does not actually load whole of simon Mochrie's image.
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
    int fd;
    uint16 * data16; uint8 * ptr1;
    long int range, j,k;
    int a; 
    
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
         fd = _open(filename,_O_RDONLY);
        if (fd == -1)
		{
			printf("ctake could not open filename %s.", filename);
         	/*return -1;*/
		}
        
		/* Position the pointer */
		lseek(fd, offset, SEEK_SET);
		
		/* Read the file */
        range = udim*vdim;
		data16=mxCalloc(range,sizeof(uint16));
        a=_read(fd, data16,2*range); 
		printf("Hi %d \n",a);
		
		/* Do the byte flip and array index flip. */
  		for (j=0;j<udim;j++)
  		for (k=0;k<vdim;k++)
		   { ptr1=(uint8*)(data16+k*udim+j);
		     data[j*vdim+k]=(double)(ptr1[0]*256 + ptr1[1]); 		  
		   }
          
       /* free memory and close file */
			/*free(filename); free(data16);*/
			          /*freeing memory with free() can cause matlab 
			          to crash; use mxFree instead
			          */
			mxFree(filename); mxFree(data16);
		 	             /*free(filename); free(data16);*/ 
			             /*Freeing pointers might cause matlab to crash*/ 
			close(fd);
      }
 







