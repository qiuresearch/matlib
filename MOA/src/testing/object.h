// Editted by Gil Toombes on July 15, 2000
// Added four fields to image_info - image_width and image_height, DataType, SignedData

/* object.h - define properties of objects - memory, video, disk and tape files.
   tv6 version

  Tabs = 5 to line up columns

	****NOTE: changes made to the OBJECT DESCRIPTOR STRUCTURE or to the enums
			which go into it should also be made in EdObject.c. 

History:
26 Jan 93 EFE  tv6 version built from swax version
4/9/93	MWT-- change image_info to include fields from overscan area
*/
#ifndef OBJECT_H
#define OBJECT_H

#include <time.h>					// time_t 

#define data_buffer_size 65536L		// length of data transfer buffer, bytes 

#ifndef Ulong
 #define Ulong unsigned long
#endif
#ifndef DeleteMemObj
 #define DeleteMemObj -1				// use to delete memory objects in DeleteObject
#endif
#ifndef DoNotDeleteMemObj
 #define DoNotDeleteMemObj 0			// use to not delete memory objects in DeleteObject
#endif

typedef enum			// kinds of objects 
		{
		Unknown,
		Image,		// images of all kinds 
		Rfile,		// rfiles of all kinds 
		} object_kind;


typedef enum			// types of objects - where they reside - the order is critical 
		{
		Memory,		// e.g. im0 
		VmemVRAM,		// in video memory VRAM- e.g., the Piranha board 
		VmemDRAM,		// in video memory DRAM- e.g., the Piranha board 
		Disk,		// named file on disk 
		Tape,		// e.g. imt23, accumulator required 
		ReadOnly,		// e.g. ime or imb, accumulator required 
		WriteOnly,	// e.g. imt (without a number) 
		Accumulator,	// internal use only 
		Numeral,		// internal use only 
		Unspecified,
		} object_type;


typedef enum			// status of objects 
		{
		UnknownStatus,	// before classification is complete
		Closed,		// disk or tape files
		OpenRead,		// disk or tape files
		OpenWrite,	// disk or tape files
		Ready,		// used when open doesn't apply 
		} object_status; 

typedef enum			// role of objects in expressions
		{
		UnknownRole,
		Source,
		Destination,
		} object_role;


typedef enum			// tape operations 
		{
		Read,
		Write,
		Rewind,
		SpaceBlock,
		SpaceFile,
		SkipToEnd,
		} tape_command;



typedef enum			// types of data in memory 
		{			// cf. TIFF 6.0 definition
		IntegerData,
		FloatData,
		ComplexData,
		DistortionData,
		IntensityData,
		UnknownData,	// your problem 
		} data_type;


typedef enum				// deletion status of object
		{
		Deletable,		// object descriptor may be deleted
		Nondeletable,		// object descriptor may not be deleted
		} object_delete;



#define StrcObj struct object_descriptor	// shorthand
struct object_descriptor
		{
		char StructureName[32];	// "object_descriptor"
		char *Text;		// the original text (name) supplied by ICF from the operator 
		char *Path;		// full path from name if given, or from default 
		int Identifier;	// e.g. the '34' if 'imt34' was given, -2 for 'imd' 
		float Value;		// e.g. 2.7, if such a constant was specified 
		long Handle;		// file handle 
		Ulong Bitadr;		// bit-address of Vmem image 
		Ulong Wide;		// width in pixels 
		Ulong High;		// height in pixels 
		Ulong Pitch;		// pitch in pixels per line 
		Ulong Bpp;		// bits per pixel, e.g. 16 
		Ulong Sbpp;		// significant bits per pixel, e.g. 8 
		Ulong Swide;		// subset width in pixels 
		Ulong Shigh;		// subset height in pixels 
		Ulong Sx;			// subset x offset 
		Ulong Sy;			// subset y offset 
		char *Data;		// pointer to actual data in memory 
		char *Buffer;		// r/w transfer buffer for image or rfile data - length = data_buffer_size 
		long NBytes;		// total number of valid bytes in transfer buffer 
		long NextByte;		// next byte to read in transfer buffer 
		char *Header;		// header array in memory 
		time_t TimeStamp;	// absolute time in seconds at last use 
		struct object_descriptor **DownLinkPointer;	// double linked list pointers 
		struct object_descriptor *UpLinkPointer;
		object_kind Kind;
		object_type Type;
		object_status Status;
		object_role Role;
		data_type DataType;
		long SignedData;	// 0/-1 for unsigned/signed data
		object_delete DeleteStatus;	// Deletion status of object
		} ;


#define object_hash_table_length 57			// must be prime 


/* ----- header structure for image in memory ----- */

#define OP_LENGTH 20		// array sizes for various ASCII descriptors 
#define DETECT_LENGTH 20		// detector field in header
#define DATE_LENGTH 20
#define TELEMETRY_LENGTH 512	// length defined for telemetry data 
#define NUM_USER_VARIABLES 20	// number of long user variables to be stored in header 
#define TITLE_LENGTH 80		// length of image title space 

struct image_info{
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
 // $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
  //  alteration to add width and height information.
        long image_width;
        long image_height;
        data_type DataType;
        long SignedData;	// 0/-1 for unsigned/signed data
  // $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

	};

#define RFILE_IDENTIFIER -1654329354

struct rfile_header{		// pointed to by *header in struct object_descriptor 
	long identifier;		// currently the same as TV4 rfiles 
	long kind;
	long x_start_index;
	long y_length;
	long unused1;
	long num_exp;
	long unused2;
	long num_bkg;
	long unused3;
	long unused4;
	long user_integers[5];
	float x_start_value;
	float del_x;
	float exp_time;
	float bkg_time;
	float unused5;
	float unused6;
	float d_spacing;
	float pix_per_order;
	float origin;
	float spec_to_phos;
	char title[80];
 
};



#endif

extern struct object_descriptor *ObjectHashTable[];	// global table defined in main 

extern struct object_descriptor *DefaultIMPtr;		// current default image object 
extern struct object_descriptor *DefaultRFPtr;		// current default rfile object 
extern Ulong DefaultWide;						// default image dimensions for general images 
extern Ulong DefaultHigh;
extern Ulong DefaultBpp;






