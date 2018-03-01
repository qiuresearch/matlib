//  Mex interface for read_tiff_header() in the tiff_reading.c
//  See read_tiff_header.m or tiff_reading.c for details.

#include <mex.h>
#include "fcntl.h" // Unix open and read default holder.
#include "tiff_reading.c"

void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
  
  char *filename; // string for holding filename
  int fpointer ; // pointer to file
  int status;  
  struct image_info header; // header holds all the TV6 header info in structure image_info
                            // see tiff_reading.c for the image_info structure prototype. 

  // Check the inputs and outputs.
  if (nlhs != 1)
    mexErrMsgTxt("read_tiff_header : requires one output argument.");
  if (nrhs != 1)
    mexErrMsgTxt("read_tiff_header : requires one input argument.");
  if (!mxIsChar(prhs[0]))
    mexErrMsgTxt("read_tiff_header : filename (first argument) must be a string.");

  // Open the file.
  fpointer = (mxGetM(prhs[0])*mxGetN(prhs[0]))+1;
  filename = mxCalloc(fpointer,sizeof(char));
  status = mxGetString(prhs[0], filename, fpointer);
  if (status!=0) 
    mexWarnMsgTxt("Filename truncated because it was too long"); 
  fpointer = open(filename, O_RDONLY);
    mxFree(filename);
  if (fpointer == -1) 
    mexErrMsgTxt("Cannot open file for reading.");

  // Call read_tiff_header.c in tiff_reading.c
  // status=read_tiff_header(fpointer, & header );
  //if (status!=0)
  //  mexErrMsgTxt("Did not successfully read image header.");

  // Just have to transfer everything across to a record here.

  // Close the file before returning.
  close(fpointer);

}

