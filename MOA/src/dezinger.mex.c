#include <mex.h>
#include <matrix.h>
#include <mex_adam.h>
#include "../dezinger.h"
#include "stdio.h"
#include "../tiff_data_typedefs.h"

// type of diagnostic data.  Assumed to be "long" here and in zinger_calc.c
typedef long diagnostic_data;

typedef struct  {
  int length;   // length of data
  diagnostic_data *data;
} diagnostic_type;


int dezinger_multiple_data(
                           int width,
                           int height,
                           int x_edge,
                           int y_edge,
                           double sigma_max,
                           scaling_type scaling,
                           uint32 *dest,
                           int num_images,
                           uint16 **data_ptrs,
                           diagnostic_type *diagnostics
                           );



void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

  int i,j; // loop counters
  int error = 0;
  int num_images;
  int ndim=0;  // number of dimensions (should be set to 2 later on)
               
  // used for creation of output matrix.  Assumes ndim == 2 or 3.
  //int dimensions[3];
  const int *dimensions;

    

  // rows and columns of the input (and output) matrices
  int rows,cols;


  // pointers to input data
  uint16 **data_ptrs;

  // pointer to output data
  uint32 *result;

  /* pointer to diagnostic information.  This is a vector of arrays which */
  /* keep track of various histograms, etc. along the way. */
  diagnostic_type *diagnostics;
  const int num_diagnostics = 3;  // number of records in diagnostics

  /* For now, just take all of these options to be the defaults.   Maybe
     later, allow them to be changed from within Matlab. */
  int x_edge = 0;
  int y_edge = 0;
  double sigma_max = 5.0;
  scaling_type scaling = NONE;
  /* end of defaults */


  if (nlhs < 1)
    mexErrMsgTxt("dezinger: requires at least one output argument.");

  if (nrhs < 1)
    mexErrMsgTxt("dezinger: requires at least one input argument.");
  else if (nrhs == 1) {
    ndim = mxGetNumberOfDimensions(prhs[0]);
    if (ndim != 3)
      mexErrMsgTxt("dezinger: if only one argument, it must have three dimensions.");
    if (!mxIsUint16(prhs[0]))
      mexErrMsgTxt("dezinger: input matrices must be uint16.");
  }
  else {   // more than one input argument
    // check number of dimensions, class types
    for (i = 0; i < nrhs; ++i) {
      ndim = mxGetNumberOfDimensions(prhs[i]);
      if (ndim != 2)
        mexErrMsgTxt("dezinger: input matrix dimensions cannot exceed 2.");
      if (!mxIsUint16(prhs[i]))
        mexErrMsgTxt("dezinger: input matrices must be uint16.");
    }
  }

  // get dimensions from one of the images.
  dimensions = mxGetDimensions(prhs[0]);
  rows = dimensions[0];
  cols = dimensions[1];
  // check that all other input matrices agree.
  for (i = 1; i < nrhs; ++i)
    if ((mxGetM(prhs[i]) != rows) || (mxGetN(prhs[i]) != cols))
      mexErrMsgTxt("dezinger: all input matrices must have same size.");

  if (nrhs == 1)
    num_images = dimensions[2];  // third index
  else
    // NB: this will have to change if command-line options are allowed.
    num_images = nrhs;
  

  // force number of output dimensions to be two;
  ndim = 2;
  //mxArray *mxCreateNumericArray(int ndim, const int *dims, 
  //            mxClassID class, mxComplexity ComplexFlag);
  plhs[0] = mxCreateNumericArray(ndim, dimensions, mxUINT32_CLASS, mxREAL);

  // set up pointers to input data

  /* NB: you don't need to check for NULL pointer, unless this is compiled as
     a stand-alone application.  Matlab checks for failure of mxAlloc and
     returns to command prompt if an error is detected. */
  data_ptrs = mxMalloc(num_images * sizeof(uint16 *));

  if (nrhs == 1) {
    data_ptrs[0] = mxGetData(prhs[0]);
    for (i=1; i<num_images; ++i)
      //
      data_ptrs[i] = data_ptrs[i-1] + (rows*cols);
  }
  else
    // NB: assumes no command-line options.
    for (i=0; i<num_images; ++i)
      data_ptrs[i] = mxGetData(prhs[i]);


  // set result pointer to data pointer of plhs[0].  Results will go here.
  result = mxGetData(plhs[0]);

  // set up for diagnostics if more than one output argument is requested.
  if (nlhs > 1) {
    // again, do not check for success, since we're in matlab.
    diagnostics = mxMalloc(num_diagnostics * sizeof(diagnostic_type));
    /* set all data pointers to NULL.  If an error occurs within
       dezinger_multiple_data, then we need to only free the pointers which
       have been set by mallocs (or callocs)  */
    for (i = 0; i < num_diagnostics; ++i)
      diagnostics[i].data = NULL;
  }
  else
    diagnostics = NULL;

  // call the actual dezingering routine
  error = dezinger_multiple_data(
                                 cols,
                                 rows,
                                 x_edge,
                                 y_edge,
                                 sigma_max,
                                 scaling,
                                 result,
                                 num_images,
                                 data_ptrs,
                                 diagnostics);

  if (0) {

  /* Transfer all of the data out of the diagnostics structure array into */
  /* Matlab double-precision vectors */
    if (diagnostics != NULL) {
      // index into plhs[], matlab return arguments
      int lhs_index = 1;   //  plhs[0] is where the image goes.

      fprintf(stderr, "before diagnostic for loop\n");
      // don't transfer data into output vectors which don't exist
      for (i=0; i < num_diagnostics && lhs_index < nlhs; ++i, ++lhs_index) {
        diagnostic_data *data_in;
        double *data_out;

        fprintf(stderr,
                "transferring diagnostic %d into plhs[%d]\n",i,lhs_index);
        // create a column vector for this diagnostic data.
      plhs[lhs_index] = mxCreateDoubleMatrix(diagnostics[i].length,1,mxREAL);
      data_out = mxGetPr(plhs[lhs_index]);
      data_in = diagnostics[i].data;
      for (j = 0; j < diagnostics[i].length; ++j)
        *data_out++ = (double) data_in[j];
      fprintf(stderr,"finished transferring diagnostic %d\n",i);
      }

    }

  }
  /* Matlab supposedly frees all memory from mxMalloc upon termination, but
     do this anyway.  */
  mxFree(data_ptrs);
  if (diagnostics != NULL) {
    for (i=0; i < num_diagnostics; ++i)
      if (diagnostics[i].data)
        free(diagnostics[i].data);   // these were allocated in zinger_calc
    mxFree(diagnostics);
  }

  if (error)
    // error occurred
    mexErrMsgTxt("dezinger: error in dezinger_multiple_data subroutine.");

}

