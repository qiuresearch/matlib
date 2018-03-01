// load_float_tiff() takes the tiff file of floats stored in filename and 
// loads them into the array result.  The width and length of the tiff are 
// also returned.
// Implimented on March 10, 2000.
// Returns 1 if successful and 0 if fails.

#include "tiffio.h"
#include "stdlib.h"

int load_float_tiff(char *filename, float **result, int *width, int *length);

int load_float_tiff(char *filename, float **result, int * width, int *length)
// filename is an image of floats stored in tiff format.
// Returns file into array of floats, "*result".
// Returns "width" and "length" of image correction file.
// Function returns 1 if everything is okay and 0 if an error occurs.
{

  uint32 imagewidth, imagelength, rows_per_strip;
  uint16 bits_per_sample, data_type;
  tdata_t buf; 
  tstrip_t strip;
  float *buf_out;
  short bytes_per_pixel = sizeof(float);
  const uint16 tiff_float=3; // Value of TIFFTAG_DATATYPE for float file

  // Open file
  TIFFSetWarningHandler(0); // Turn off Tiff Warnings
  TIFF* tif = TIFFOpen(filename, "r");  
  if (!tif) {
    fprintf(stderr,"load_float_tiff could not open tiff file.\n");
    return 0;
  }

  // Check it is an float file
  TIFFGetField(tif, TIFFTAG_DATATYPE, &data_type); 
  if (data_type!=tiff_float)
    { fprintf(stderr,"\nTIFF File %s is not a float TIFF file.\n",filename);
      fprintf(stderr,"load_float_tiff() unable to load file %s.\n",filename);
      return 0; }

  // Get File information and allocate memory to result.
  TIFFGetField(tif, TIFFTAG_ROWSPERSTRIP, &rows_per_strip) ;
  TIFFGetField(tif, TIFFTAG_IMAGEWIDTH, &imagewidth);
  TIFFGetField(tif, TIFFTAG_IMAGELENGTH, &imagelength);
  TIFFGetField(tif, TIFFTAG_BITSPERSAMPLE, &bits_per_sample) ;
  *width = imagewidth;
  *length = imagelength; 
  buf = _TIFFmalloc(TIFFStripSize(tif));
  if ((*result = (float *)malloc(bytes_per_pixel * imagewidth * imagelength)) ==
      NULL) {
    fprintf(stderr,"load_distortion_file: could not allocate memory.\n");
    return -1;
  }

  // Move tiff into result.
  buf_out = *result;
  for (strip = 0; strip < TIFFNumberOfStrips(tif); strip++) {
    TIFFReadEncodedStrip(tif, strip, buf, (tsize_t) -1);   
    memcpy(buf_out, buf, 
           (size_t) rows_per_strip * imagewidth * bytes_per_pixel);
    buf_out += rows_per_strip * imagewidth;      
  }

  // Close up tiff file.
  _TIFFfree(buf);
  TIFFClose(tif);

  return 1;
}








