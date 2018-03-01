// Last editted 15 July, 2000 by Gil Toombes

#include "tiff_data_types.h"
#include "tiff_in.c"
#include "errno.h"

        // Provides a set of functions for reading in TV6 tiffs.

int print_tiff_header(FILE * out,  struct image_info header);
//  Takes a header of format (imag_header) and prints it to the stream out.
//  You could, for example load the header with read_tiff_header and then print it out. 
//  returns 0 if successful, returns -1 if unhappy.


int read_tiff_data(int fhandle, void ** data);
// Takes a TV6 tiff file pointed to by fhandle.
// Loads the data in the TV6 tiff into the array data.
// You need to cast data on return into the appropriate data type.
// returns 0 if successful.
// returns -1 if unsuccessful. 


// int read_tiff_header(int fhandle, struct image_info * header );
// Takes a TV6 tiff file pointed to by fhandle.
// Exposure length, chip info and so on are all stored in the tiff header.
// returns all the header information in header as a the structure, image_info.
// returns 0 if successful.  returns -1 if unsuccessful.
// the image_info structure has the following fields,
/*
struct image_info(
	char operator[OP_LENGTH];			// operator field if we choose to use it 
	char detector[DETECT_LENGTH];			// detector field to be filled by camera code
	char date[DATE_LENGTH];				// date stamp- in format yyyy:mm:dd hh:mm:ss 
	long user_vars[NUM_USER_VARIABLES];		// variables for the user- fill with temp, etc 
	long num_exposures;				// number of exposure frames comprising this image 
	long num_backgrounds;				// number of backgrounds 
	long exposure_time;				// cumulative exposure time 
	long background_time;				// cumulative background time 
	float black_level;				// black level from overscan pixels
	float dark_current;				// from overscan pixels
	float read_noise;				// from overscan
	float dark_current_noise;			// from overscan
	float beam_monitor;				// scalar for intensity normalization
	long descriptor_length;				// length of next field 
	char *descriptor;				// history of image e.g. move im100=ime;move imt=im100;etc 
	char *telemetry;				// telemetry and setup info from chip
	char *title;					// our old title field 
	long *strip_pointers;				// filled with strip pointers if reading an image from disk 
	long *strip_byte_counts;			// number of bytes in each strip on disk 
	long num_strips;				// number of strips on disk file 
	long tif_head_length;
	long big_endian;
	long compression;
	char *LZW;
	long rows_per_strip;
	};
*/


int read_tiff_header(int fhandle, struct image_info * header )
{

  struct object_descriptor image; // TV6 structure for handling images.
  
  image.Type = Disk; // Set to disk file.
  image.Handle = fhandle;
  image.Buffer = NULL; // Initialize all pointers to null
  image.Header = NULL;
  image.Data = NULL;
  image.Text = NULL;
  image.Path = NULL;
  image.UpLinkPointer= NULL; 
  image.DownLinkPointer=NULL;

 
  get_im_head(&image);

  *header = *((struct image_info *)(image.Header)); 

  free(image.Buffer); free(image.Header); free(image.Data); free(image.Text);
  free(image.Path); free(image.UpLinkPointer); free(image.DownLinkPointer);
  return 0;
}

int read_tiff_data(int fhandle, void ** data)
{  
  struct object_descriptor image ; // TV6 structure for handling images.
  long data_length ;
  char * test;
  int i;

  image.Type = Disk;  // Read off the image header
  image.Handle = fhandle; 
  image.Buffer = NULL; // Initialize all pointers to null
  image.Header = NULL;
  image.Data = NULL;
  image.Text = NULL;
  image.Path = NULL;
  image.UpLinkPointer= NULL; 
  image.DownLinkPointer=NULL;
  
  get_im_head(&image);

  // asign memory to get the image in.
 data_length = image.Pitch * image.High * image.Bpp/8;
 test = (char *) malloc(data_length);
 if (test==NULL) 
    {fprintf(stderr,"\nread_tiff_data() to allocate memory to load image.\n");
     return -1; }

  // Get disk image
 read_diskimage(&image,0,data_length,test);
 *data = test; 
 
  free(image.Buffer); free(image.Header); free(image.Data); free(image.Text);
  free(image.Path); free(image.UpLinkPointer); free(image.DownLinkPointer);
  return 0;
}


int print_tiff_header(FILE *out,  struct image_info header)
{
  int i;

  fprintf(out,"Operator : %s\n", header.operator);
  fprintf(out,"Detector : %s\n", header.detector);
  fprintf(out,"Date : %s\n", header.date);

  fprintf(out,"User Variables : ");
  for(i=0;i<NUM_USER_VARIABLES;i++)
    fprintf(out,"  %d  ", header.user_vars[i]);
  fprintf(out,"\n");

  fprintf(out,"Number of Exposures : %d \n", header.num_exposures);
  fprintf(out,"Number of Backgrounds : %d \n", header.num_backgrounds);
  fprintf(out,"Exposure Time : %d \n", header.exposure_time);

  fprintf(out,"Background Time : %d \n", header.background_time);
  fprintf(out,"Black Level : %f \n", header.black_level);
  fprintf(out,"Read Noise : %f \n", header.read_noise);
  fprintf(out,"Dark Current Noise : %f \n", header.dark_current_noise);
  fprintf(out,"Beam Monitor Level : %f \n", header.beam_monitor);
  fprintf(out,"Descriptor Length : %f \n", header.descriptor_length);
  fprintf(out,"Descriptor : %s\n",header.descriptor);
  fprintf(out,"Telemetry : %s\n", header.telemetry);
  fprintf(out,"Title : %s\n", header.title);
  fprintf(out,"Image Width : %d \n", header.image_width);
  fprintf(out,"Image Height : %d \n", header.image_height);
  fprintf(out,"Data Type : %d \n", header.DataType);
  fprintf(out,"Signed/Unsigned : %d\n", header.SignedData);
   return 0;
}




