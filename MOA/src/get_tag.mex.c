//  This is the portal to get_tag.c
//  Written on 27 June, 2000 by Gil Toombes
//  See get_tag.m for help


#include "mex.h"
#include "get_tag.c"

void mexFunction(
	  int nlhs, mxArray *plhs[],
	  int nrhs, mxArray *prhs[] )
     {
       int ncols;
		 char * filename;
		 int status;
		 int AMOUNT_DATA=8; // This must be the same as in get_tag.
       double * tag_vals;

       // Check input and output numbers
		 if (nlhs!=1)
			mexErrMsgTxt("Need one output.");
       if (nrhs!=1)
			mexErrMsgTxt("Need a filename input.");

		 // Get the filename
       if (mxIsChar(prhs[0])!=1)
	          {mexErrMsgTxt("Filename must be a string.");}
           if (mxGetM(prhs[0])!=1) 
             {mexErrMsgTxt("Filename must be a row vector.");}
           ncols=mxGetN(prhs[0])+1;  // Allocating memory 
	        filename=mxCalloc(ncols,sizeof(char));
           status=mxGetString(prhs[0],filename,ncols);
           if (status!=0)
	         mexWarnMsgTxt("Not enough space.  Filename Truncated..");

       // Create the array to return the value to.
  	    plhs[0] = mxCreateDoubleMatrix(1,AMOUNT_DATA,mxREAL);
       tag_vals=mxGetPr(plhs[0]);
 
		 // call function
		 if (get_tag(filename, tag_vals)==-1)
				mexErrMsgTxt("Problem with get_tag.c");
         
        // free memory
			free(filename);

      }
 
