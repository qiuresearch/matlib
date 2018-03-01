/*
MEX interface to get_extra_tiff_tags.c
Transfer values from struct to a matlab record.
*/
 


#include <mex.h>
#include <matrix.h>
#include <mex_adam.h>
#include "../extra_tiff_tags.h"

struct NonStandard_Tags get_extra_tiff_tags(char *filename);


// update this whenever you change the number of field_names below!
const int Number_Tags = 13;


const char *field_names[] = 
{ "black_level",
  "dark_current",
  "read_noise",
  "dark_current_noise",
  "beam_monitor",
  "num_exposure",
  "num_background",
  "exposure_time",
  "background_time",
  "sub_bpp",
  "sub_wide",
  "sub_high",
  "user_variables"
};


//mxArray *mxCreateStructMatrix(int m, int n, int nfields, 
//                              const char **field_names);



void
mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
  
  char *filename;
  struct NonStandard_Tags record;
  mxArray *field_value;

  if (nlhs != 1)
    mexErrMsgTxt("get_extra_tiff_tags: requires one output argument.");
  if (nrhs != 1)
    mexErrMsgTxt("get_extra_tiff_tags: requires one input argument.");
  if (!mxIsChar(prhs[0]))
    mexErrMsgTxt("get_extra_tiff_tags: filename (first argument) must be a string.");

  filename = Matrix2string(prhs[0]);

  // printf("About to enter mxCreateStructMatrix\n");
  plhs[0] = mxCreateStructMatrix(1, 1, Number_Tags, field_names);

  // printf("About to enter get_extra_tiff_tags\n");
  record = get_extra_tiff_tags(filename);

  field_value = mxCreateDoubleMatrix(1,1,mxREAL);
  *mxGetPr(field_value) = (double) record.BLACK_LEVEL;
  mxSetField(plhs[0], 0, "black_level", field_value);

  field_value = mxCreateDoubleMatrix(1,1,mxREAL);
  *mxGetPr(field_value) = (double) record.DARK_CURRENT;
  mxSetField(plhs[0], 0, "dark_current", field_value);
  //  mxSetFieldByNumber(plhs[0], 0, 1, field_value);

  field_value = mxCreateDoubleMatrix(1,1,mxREAL);
  *mxGetPr(field_value) = (double) record.READ_NOISE;
  mxSetField(plhs[0], 0, "read_noise", field_value);

  field_value = mxCreateDoubleMatrix(1,1,mxREAL);
  *mxGetPr(field_value) = (double) record.DARK_CURRENT_NOISE;
  mxSetField(plhs[0], 0, "dark_current_noise", field_value);

  field_value = mxCreateDoubleMatrix(1,1,mxREAL);
  *mxGetPr(field_value) = (double) record.BEAM_MONITOR;
  mxSetField(plhs[0], 0, "beam_monitor", field_value);

  field_value = mxCreateDoubleMatrix(1,1,mxREAL);
  *mxGetPr(field_value) = (double) record.NUM_EXPOSURE;
  mxSetField(plhs[0], 0, "num_exposure", field_value);

  field_value = mxCreateDoubleMatrix(1,1,mxREAL);
  *mxGetPr(field_value) = (double) record.NUM_BACKGROUND;
  mxSetField(plhs[0], 0, "num_background", field_value);

  field_value = mxCreateDoubleMatrix(1,1,mxREAL);
  *mxGetPr(field_value) = (double) record.EXPOSURE_TIME;
  mxSetField(plhs[0], 0, "exposure_time", field_value);

  field_value = mxCreateDoubleMatrix(1,1,mxREAL);
  *mxGetPr(field_value) = (double) record.BACKGROUND_TIME;
  mxSetField(plhs[0], 0, "background_time", field_value);

  field_value = mxCreateDoubleMatrix(1,1,mxREAL);
  *mxGetPr(field_value) = (double) record.SUB_BPP;
  mxSetField(plhs[0], 0, "sub_bpp", field_value);

  field_value = mxCreateDoubleMatrix(1,1,mxREAL);
  *mxGetPr(field_value) = (double) record.SUB_WIDE;
  mxSetField(plhs[0], 0, "sub_wide", field_value);

  field_value = mxCreateDoubleMatrix(1,1,mxREAL);
  *mxGetPr(field_value) = (double) record.SUB_HIGH;
  mxSetField(plhs[0], 0, "sub_high", field_value);

  field_value = mxCreateDoubleMatrix(1, record.NUMBER_USER_VARIABLES,mxREAL);
  { int i;
  for (i=0; i < record.NUMBER_USER_VARIABLES; ++i)
    mxGetPr(field_value)[i] = (double) record.USER_VARIABLES[i];
  //    *mxGetPr(field_value) = (double) record.USER_VARIABLES[i];
  mxSetField(plhs[0], 0, "user_variables", field_value);
  }

}
