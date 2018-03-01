/* tiff.h      mwt 2-5-92
4/9/92	MWT -- add overscan definitions (BLACK_LEVEL etc) ver 1.3

 */

#ifndef TIFF2_H
#define TIFF2_H

#include "object.h"

/* ----- tiff IFD field data types ----- */
#define TIF_BYTE 1
#define TIF_ASCII 2
#define TIF_SHORT 3
#define TIF_LONG 4
#define TIF_RATIONAL 5
// include TIFF 6.0 data types
#define TIF_SBYTE 6
#define TIF_UNDEFINED 7
#define TIF_SSHORT 8
#define TIF_SLONG 9
#define TIF_SRATIONAL 10
#define TIF_FLOAT 11
#define TIF_DOUBLE 12

/* ----- IFD tag numbers ----- */
#define NEW_SUB_FILE_TAG 0xFE			// long
#define IMAGE_WIDTH_TAG 0x100			// long or short
#define IMAGE_LENGTH_TAG 0x101			// long or short
#define BITS_PER_SAMPLE_TAG 0x102		// short
#define DATA_COMPRESSION_TAG 0x103		// short
#define PHOTOMETRIC_INTERPRETATION_TAG 0x106	// short
#define IMAGE_DESCRIPTOR_TAG 0x10E		// ascii
#define DETECTOR_MAKE_TAG 0x110			// ascii
#define STRIP_OFFSET_TAG 0x111			// long or short
#define SAMPLES_PER_PIX_TAG 0x115		// short
#define ROWS_PER_STRIP_TAG 0x116		// long or short
#define STRIP_BYTE_COUNT_TAG 0x117		// long or short
#define X_RESOLUTION_TAG 0x11A			// rational
#define Y_RESOLUTION_TAG 0x11B			// rational
#define X_POSITION_TAG 0x11E			// rational
#define Y_POSITION_TAG 0x11F			// rational
#define SOFTWARE_VERSION_TAG 0x131		// ascii
#define DATE_TIME_TAG 0x132			// ascii
#define OPERATOR_TAG 0x13B			// ascii
#define SAMPLE_FORMAT_TAG 0x153			// short

// now define tiff standard data types for sample format tag
// to define distortion correction data type (really an double short)
// we can throw in 2 samples per pixel in this field specifying
// each as type integer. Do the same for complex data.
#define SF_unsigned_int_data 1
#define SF_signed_int_data 2
#define SF_float_data 3
#define SF_undefined_data 4



/* non-standard TAGS -- we will define these areas to store image parameters */
#define TITLE_TAG 0x9000
#define NUM_EXPOSURE_TAG 0x9001		/* type long */
#define NUM_BACKGROUND_TAG 0x9002		/* type long */
#define EXPOSURE_TIME_TAG 0x9003		/* in msec- type long */
#define BACKGROUND_TIME_TAG 0x9004		/* in msec- type long */
#define SIGN_STATUS_TAG 0x9005		/* type long -- use sample format tag instead */
#define TELEMETRY_TAG 0x9006			/* type ascii */
#define IMAGE_HISTORY_TAG 0x9007		/* type ascii */
#define DATA_TYPE_TAG 0x9008			/* type ascii -- use sample format tag instead */
#define SUB_BPP_TAG 0x9009			/* type long */
#define SUB_WIDE_TAG 0x900a			/* type long */
#define SUB_HIGH_TAG 0x900b			/* type long */
#define BLACK_LEVEL_TAG 0x900c		// type float
#define DARK_CURRENT_TAG 0x900d		// type float
#define READ_NOISE_TAG 0x900e			// type float
#define DARK_CURRENT_NOISE_TAG 0x900f	// type float
#define BEAM_MONITOR_TAG 0x9010		// type float
#define USER_VARIABLES_TAG 0x9100		/* type long */

/* ----- parameters defining tif format for WRITING ----- */
#define MAX_NUM_STRIPS 1		/* number of strips into which we divide the data */
#define SAMPLES_PER_PIX 1	/* number of units which describe a pixel */
#define NUM_FIELDS 32		/* number of fields in IFD */
#define SOFT_LENGTH 20		
#define SOFTWARE_VERSION "TV6 TIFF v 1.3     "

/* ----- structure of IFD field ----- */
struct tif_field
	{
	unsigned short tag;	/* IFD field tag */
	unsigned short type;	/* data type of value */
	unsigned long length;	/* length of array for values */
	unsigned long value;	/* values (if length*type < 4 bytes) or offset to array of values */
	};

/* ----- define structure for the fixed part of a tiff file ----- */
struct tif_preamble
{
	unsigned short tiff;		/* Specifies byte order */
	unsigned short version;		/* always 2A hex */
	unsigned long ifd_pointer;	/* pointer to beginning of first ifd table */
};

/* ****-----*** structure of our tiff header for WRITING ***-----**** */
struct tif_header
	{
	unsigned short tiff;		/* Specifies byte order */
	unsigned short version;		/* always 2A hex */
	unsigned long ifd_pointer;	/* pointer to beginning of first ifd table */

	unsigned short tape_number;	/* reserve 2 bytes for tape operations */

/* --- ASCII fields --pointed to from within ifd --- */
	char operator[OP_LENGTH];
	char date[DATE_LENGTH];
	char detector[DETECT_LENGTH];
	char software_ver[SOFT_LENGTH];
/* --- this is the IFD proper --- */
	unsigned short ifd_count;
	struct tif_field fields[NUM_FIELDS];
	unsigned long next_ifd;		
/* --- Now more arrays pointed to from within the IFD --- */
	unsigned long xres[2];		/* arbitrary resolution for image */
	unsigned long yres[2];
	long user_variables[NUM_USER_VARIABLES];
//	char title[TITLE_LENGTH];			// title and telemetry now  variable length
//	char telemetry[TELEMETRY_LENGTH];
	};
#endif

