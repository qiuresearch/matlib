// Taken from TV6 on 15 July, 2000 by Gil Toombes.
// Small modifications made to eliminate WATCOM specific features.
// Look for //$$$$$$$$$$$$$$$$$$  to indicate changes.

/* tiff_in.c     ----     MWT 3-20-92
	routines to get tiff images into TV5 format
4-19-93 	MWT-- 	bug fix in get_im_head
9-21-93	MWT--	fix float data in (black_level, etc.)
				was being stored as truncated integer.
				also fix tiff_out.c


Tiff routines---
read_diskimage() -- uses strip offset information to get data from file
get_im_head() -- reads tiff header and fills image object descriptor structure
tif_date_to_int() -- Takes ascii string of the form yyyy:mm:dd hh:mm:ss and forms time for TimeStamp
TIFF_field_order() -- makes sure TIFF fields are sorted according to tag number
TIFFSwabShort -- swaps bytes for short
TIFFSwabLong -- rearranges long
TIFFSwabArrayofShort
TIFFSwabArrayofLong
TIFFSwabIFD -- rearranges image file directory from MM to II
*/

// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
// #include <io.h> not on unix system
#include "unistd.h"  // unix equivalent
#include "lzw3.c" // needed for compressed tiffs
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
#include <stdio.h>
#include <malloc.h>
#include <stdlib.h>
#include <string.h>
#include "tiff2.h"
#include "object.h"
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
// #include "tv6sys.pro" includes the full TV6 function listing.
#include "tiffsys.pro"  // cut down version of tv6sys.pro to only include tiff routines.
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

/*read_compress_image(struct object_descriptor *, char *);
int read_diskimage(struct object_descriptor *,unsigned long,unsigned long,char *);
int get_im_head(struct object_descriptor *);
time_t tif_date_to_int(char *);
*/
static TIFF_field_order(struct tif_field *, unsigned short);
static TIFFSwabShort(unsigned short *);
static TIFFSwabLong(unsigned long *);
static TIFFSwabArrayofShort(unsigned short *,register int);
static TIFFSwabArrayofLong(unsigned long *,register int);
static TIFFSwabIFD(struct tif_field *,unsigned short);

// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
// Define functions min and max as they seem to be used in routines.
long max(long, long);
long max(long x, long y)
{ if (x>y) return x; else return y;}

unsigned long min(unsigned long, unsigned long);
unsigned long min(unsigned long x, unsigned long y)
{ if (x<y) return x; else return y;}
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


/* read_compress_image will read either a LZW compressed or uncompressed Tiff images
(only the whole image). read_diskimage will read any portion of an uncompressed
image.
*/
read_compress_image(struct object_descriptor *ObjPtr, char *buffer)
{
struct image_info	*info;				/* this will map ObjPtr->Header */
long				numstrips,
				bytes_read,
				real_bytes_per_strip,
				counter;
int				nerr,i,k;
char				*comp_buf,*c_ptr;


	if(ObjPtr->Kind != Image || ObjPtr->Type != Disk){
		printf("read_diskimage error- not a disk image file");
		return(-1);
	}
	info = (struct image_info *) ObjPtr->Header;
	c_ptr = (char *)buffer;
	numstrips = info->num_strips;
	if( numstrips < 1 ) return(-1);
	counter = 0;
	for(i=0;i<numstrips;i++){
		counter=max(counter,info->strip_byte_counts[i]);
	}
	if(info->compression == 5){
		if((comp_buf=(char *)malloc(counter))==NULL){
			printf("memory allocation error");
			return(1);
		}
		c_ptr=comp_buf;
	}
	counter = 0;
	for(i=0;i<numstrips;i++){
		lseek(ObjPtr->Handle , info->strip_pointers[i] , SEEK_SET);
		bytes_read = read(ObjPtr->Handle , c_ptr , info->strip_byte_counts[i]);
		if(info->compression == 5){
			real_bytes_per_strip=ObjPtr->Wide*info->rows_per_strip*ObjPtr->Bpp/8;
			if(i==numstrips-1){
				if((k=ObjPtr->High%info->rows_per_strip))
					real_bytes_per_strip=ObjPtr->Wide*k*ObjPtr->Bpp/8;
			}		
			LZWPreDecode(ObjPtr,bytes_read);
			LZWDecode(ObjPtr, buffer, comp_buf, real_bytes_per_strip);
/*			memcpy(buffer,comp_buf,bytes_read);
*/			buffer+=real_bytes_per_strip;
		}else{
			c_ptr+= bytes_read;
			counter+= bytes_read;
		}
	}
	if(info->compression == 5){
		LZWCleanup(ObjPtr);
		free(comp_buf);
	}			
	if(info->big_endian && ObjPtr->Bpp == 16)
		TIFFSwabArrayOfShort((unsigned short *)buffer,(int)(counter/2));
	nerr=0;
	return(nerr);
}


/******************* read_diskimage ************************************/
int read_diskimage(	struct object_descriptor *ObjPtr,
				unsigned long byteoffset,
				unsigned long numbytes,
				char *buffer)
{
/*	Reads Tiff files from disk once the strip offset and byte count
	tables have been read from disk via a call to get_im_head which
	loads the information into ObjPtr->Header. It is assumed that this
	call has already been made.
 - We also assume that an appropriate buffer has been malloc'd to accept
	the data.
*/

struct image_info	*info;				/* this will map ObjPtr->Header */
long				numstrips,
				start_strip,			start_strip_offset,
				end_strip,			end_strip_length,
				byte_offset,
				bytes_read,
				counter;
int				nerr,i;
void				*c_ptr;


	if(ObjPtr->Kind != Image || ObjPtr->Type != Disk){
		printf("read_diskimage error- not a disk image file");
		return(-1);
	}
	info = (struct image_info *) ObjPtr->Header;
	c_ptr = (char *)buffer;
	numstrips = info->num_strips;
	if( numstrips < 1 ) return(-1);
	if(info->compression!=1){
		if(numbytes!=ObjPtr->Pitch*ObjPtr->High*ObjPtr->Bpp/8||byteoffset){
			printf("image is compressed - read in whole image\n");
			return(-1);
		}
		read_compress_image(ObjPtr,buffer);
		return(numbytes);
	}	
	counter = 0;
	start_strip = -1;
	start_strip_offset=byteoffset;
	while( counter <= byteoffset ){
		start_strip++;
		start_strip_offset = byteoffset - counter;
		counter += info->strip_byte_counts[start_strip];
	}
	end_strip = start_strip;
	while( counter < byteoffset + numbytes ){
		end_strip++;
		counter+= info->strip_byte_counts[end_strip];
	}
	end_strip_length = info->strip_byte_counts[end_strip] - (counter - byteoffset - numbytes);
	if(end_strip == start_strip) end_strip_length-= start_strip_offset;
	counter = 0;
	byte_offset = start_strip_offset;
	for(i = start_strip; i < end_strip ; i++){
		lseek(ObjPtr->Handle , info->strip_pointers[i] + byte_offset , SEEK_SET);
		bytes_read = read(ObjPtr->Handle , c_ptr , info->strip_byte_counts[i] - byte_offset);
		c_ptr+= bytes_read;
		byte_offset = 0;
		counter+= bytes_read;
	}
	lseek(ObjPtr->Handle , info->strip_pointers[end_strip] + byte_offset , SEEK_SET);
	bytes_read = read(ObjPtr->Handle , c_ptr , end_strip_length);
	c_ptr+= bytes_read;
	counter+= bytes_read;
	nerr = counter;
	if( numbytes != counter ){
		nerr=counter;
		if(nerr>=0)
			printf("Only read %u bytes from disk\n",counter);
		else
			printf("read_diskimage error-- can't read from file\n");
	}
	if(info->big_endian && ObjPtr->Bpp == 16)
		TIFFSwabArrayOfShort((unsigned short *)buffer,(int)(numbytes/2));
	return(nerr);
}



#define READSIZE 32768

/****************** get_im_head *************************************/
int get_im_head(struct object_descriptor *ObjPtr)
{
/* This routine checks a disk file for the proper image format. If this is the
case, we load the object_descriptor structure. The file has been opened prior
to this call and the file handle is in ObjPtr.
*/
struct image_info	*info;
struct tif_preamble	*tif_top;
struct tif_field	*TifField;
struct tif_field	*fieldptr;
unsigned long	date_length,				date_offset,
			descriptor_length,			descriptor_offset,
			detector_length,			detector_offset,
			operator_length,			operator_offset,
			strip_offset_count,			strip_offset,
			strip_byte_count_count,		strip_byte_count_offset,
			telemetry_length,			telemetry_offset,
			title_length,				title_offset,
			user_var_length,			user_var_offset,
			num_exposures,				exp_time,
			num_backgrounds,			bkg_time,
			rows_per_strip,			sub_bpp,
			sub_wide,					sub_high,
			sample_format_defined,		sample_format,
			compression,
			dp;
unsigned short strip_offset_type,
			strip_byte_count_type,
			*short_ptr,
			TifCount;
long			i,	k,	kk,
			big_endian,
			ifd_ptr;
int			readflag, tapeflag,
			read_count,
			ifd_counter;
char			*c_ptr;
float 		black_level,
			dark_current,
			read_noise,
			dark_current_noise,
			beam_monitor;

/* Read a block of data if none is read */
	tapeflag = 0;			/* set to 1 if this is called from tape routine */
	if(ObjPtr->Type != Tape){
				// don't assume data in Buffer is read from beginning of file
				// that data may be corrupted if someone has used the buffer
				// for something else-- lets read it again
		ObjPtr->NBytes=0;
		if(ObjPtr->Buffer!=NULL){
		  // $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
		  //	if(_msize(ObjPtr->Buffer)<READSIZE){
				free(ObjPtr->Buffer);
				ObjPtr->Buffer=NULL;
		  // }  This seems to be a WATCOM specific function outside the ansi standard.
		  //  I believe eliminating it only makes us marginally less efficient. 
		  // $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 	
		}
		if(ObjPtr->Buffer==NULL){
			if( (ObjPtr->Buffer = (char *)malloc(READSIZE))  ==  NULL){	/* read some */
				printf("GET_IM_HEAD memory allocation error\n");
				return(1);
			}
		}
		lseek(ObjPtr->Handle , 0L, SEEK_SET);
		read_count = read(ObjPtr->Handle , ObjPtr->Buffer , READSIZE);
		ObjPtr->NBytes = read_count;
		readflag = 1;
		ObjPtr->NextByte = 0;
	}else{		// we assume nobody has messed with the tape buffer yet
			readflag = 1;
			tapeflag = 1;
			read_count = ObjPtr->NBytes;
	}

/* **now look for TIFF specific bytes */
/* We assume this program is running on a little-endian machine */

	tif_top=(struct tif_preamble *)ObjPtr->Buffer;
	big_endian=0;
	if(tif_top->tiff != 0x4949 || tif_top->version != 0x2A){		/* little_endian */
		if(tif_top->tiff == 0x4D4D && tif_top->version == 0x2A00){	/* big_endian */
			big_endian=1;
		}else{
			ObjPtr->Kind = Unknown;		/* Not a Tiff file */
			ObjPtr->NextByte = 0;
			return(1);
		}
	}

/* **ifd_ptr points to header- can be anywhere in a tiff file */
/* ** TifCount is the number of TIFF fields */
/* ** TifField will contain the 12 byte TIFF fields */

/* *** GET TifCount */
	ifd_ptr=tif_top->ifd_pointer;		/* points to TifCount in file */
	if(big_endian) TIFFSwabLong((unsigned long *)&ifd_ptr);
	if(ifd_ptr > read_count - 2){  /* is header in our buffer block? */
		readflag = 0;
		if(tapeflag) return(2);		/* Tape Tiff file, all info not in first block- image should go to disk first */
		lseek(ObjPtr->Handle , (long int)ifd_ptr , SEEK_SET);
		read(ObjPtr->Handle , &TifCount , sizeof(TifCount));
	}else{
		c_ptr=ObjPtr->Buffer + ifd_ptr;
		short_ptr = (unsigned short *)c_ptr;
		TifCount=*short_ptr;
	}
	if(big_endian) TIFFSwabShort(&TifCount);

/* *** NOW GET TifCount TIFF Directories */
	if(ifd_ptr > read_count - 2 - (TifCount * sizeof(struct tif_field) - 4)){
		readflag = 0;
		read_count = 0;
		if(tapeflag) return(2);		/* Tape Tiff file, all info not in first block- image should go to disk first */
		lseek(ObjPtr->Handle , ifd_ptr + 2 , SEEK_SET);
    //  $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
		// Another call to the WATCOM _msize function.  I don't think eliminating it is too serious.
		// if(_msize(ObjPtr->Buffer)< sizeof(struct tif_field) * TifCount){
			free(ObjPtr->Buffer);
			if( (ObjPtr->Buffer = (char *)malloc(sizeof(struct tif_field) * TifCount))  ==  NULL){
				printf("GET_IM_HEAD memory allocation error\n");
				return(1);
			}
	       //}
    //  $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
		TifField = (struct tif_field *)ObjPtr->Buffer;
		read(ObjPtr->Handle , TifField , sizeof(struct tif_field) * TifCount);
	}else{
		TifField=(struct tif_field *) (ObjPtr->Buffer + ifd_ptr + 2);
	}
	if(big_endian) TIFFSwabIFD(TifField,TifCount);

/* ** Now look through the fields for information -- note fields are
written in ascending order of TAG number- we sort through them in ascending order
also.
*/
	fieldptr=TifField;
	TIFF_field_order(fieldptr,TifCount);	/* makes sure fields are written in ascending order */
	ifd_counter = 0;

	while(ifd_counter < TifCount && fieldptr->tag < NEW_SUB_FILE_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag == NEW_SUB_FILE_TAG){
	}

/* WIDTH */
	while(ifd_counter < TifCount && fieldptr->tag < IMAGE_WIDTH_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag == IMAGE_WIDTH_TAG){
		ObjPtr->Wide = fieldptr->value;
		if(fieldptr->type == TIF_SHORT)ObjPtr->Wide = ObjPtr->Wide & 0xFFFF;
	}else{
		printf("no image width specified\n");
		ObjPtr->Kind = Unknown;
		return(1);
	}

/* LENGTH */
	while(ifd_counter < TifCount && fieldptr->tag < IMAGE_LENGTH_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag == IMAGE_LENGTH_TAG){
		ObjPtr->High = fieldptr->value;
		if(fieldptr->type == TIF_SHORT) ObjPtr->High = ObjPtr->High & 0xFFFF;
	}else{
		printf("no image length specified\n");
		ObjPtr->Kind = Unknown;
		return(1);
	}

/* BITS_PER_SAMPLE -- will be BITS_PER_PIX for greyscale image */
	while(ifd_counter < TifCount && fieldptr->tag < BITS_PER_SAMPLE_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag == BITS_PER_SAMPLE_TAG){
		if(fieldptr->length != 1){
			printf("We've got a color image here\n");
			ObjPtr->Kind = Unknown;
			return(1);
		}
		ObjPtr->Bpp = fieldptr->value;
		if(fieldptr->type == TIF_SHORT) ObjPtr->Bpp = ObjPtr->Bpp & 0xFFFF;
	}else{
		printf("no bit depth specified - default for field = 1\n");
		ObjPtr->Bpp = 1;
	}

/* Is data in compressed format ? */
	while(ifd_counter < TifCount && fieldptr->tag < DATA_COMPRESSION_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag == DATA_COMPRESSION_TAG){
		dp = fieldptr->value & 0xFFFF;
	 	if(dp == 1 || dp == 5 ){
			compression=dp;
		}else{
			printf("data is in compressed format number %u\n",dp);
			printf("terminate read\n");
			ObjPtr->Kind = Unknown;
			return(1);
		}
	}


	while(ifd_counter < TifCount && fieldptr->tag < PHOTOMETRIC_INTERPRETATION_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag == PHOTOMETRIC_INTERPRETATION_TAG){
	}

/* WE use this field to store image history  IM0=ime; etc */
	while(ifd_counter < TifCount && fieldptr->tag < IMAGE_DESCRIPTOR_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag == IMAGE_DESCRIPTOR_TAG){
		if(fieldptr->type == TIF_ASCII){
			descriptor_length = fieldptr->length;
			if(fieldptr->length < 5){
				descriptor_offset = ifd_ptr + 2 + (long)&fieldptr->value - (long)&TifField->tag;
			}else{
				descriptor_offset = fieldptr->value;
			}
		}
	}else descriptor_length = 0;

/* detector */
	while(ifd_counter < TifCount && fieldptr->tag < DETECTOR_MAKE_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag == DETECTOR_MAKE_TAG){
		if(fieldptr->type == TIF_ASCII){
			detector_length = fieldptr->length;
			if(fieldptr->length < 5){
				detector_offset = ifd_ptr + 2 + (long)&fieldptr->value-(long)&TifField->tag;
			}else{
				detector_offset = fieldptr->value;
			}
		}
		detector_length = min(detector_length,DETECT_LENGTH);
	}else detector_length = 0;

/* STRIP OFFSETS  -- This will point us to the data -- May have one or many strips */
	while(ifd_counter < TifCount && fieldptr->tag < STRIP_OFFSET_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag == STRIP_OFFSET_TAG){
		strip_offset_type = fieldptr->type;
		strip_offset_count = fieldptr->length;
		if(strip_offset_type == TIF_SHORT){
			if(strip_offset_count < 3){
				strip_offset = ifd_ptr + 2 + (long)&fieldptr->value - (long)&TifField->tag;
			}else{
				strip_offset = fieldptr->value & 0xFFFF;
			}
		}
		if(strip_offset_type == TIF_LONG){
			if(strip_offset_count == 1){
				strip_offset = ifd_ptr + 2 + (long)&fieldptr->value - (long)&TifField->tag;
			}else{
				strip_offset = fieldptr->value;
			}
		}
	}else{
		printf("no pointer to data given\n");
		return(1);
	}

/* SAMPLES_PER_PIXEL -- > 1 for color images */
	while(ifd_counter < TifCount && fieldptr->tag < SAMPLES_PER_PIX_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag == SAMPLES_PER_PIX_TAG){
	 if(fieldptr->length > 1){
		printf("color image - abort read\n");
		ObjPtr->Kind = Unknown;
		return(1);
	 }
	}

/* ROWS_PER_STRIP -- unecessay unless strip byte counts are missing */
	while(ifd_counter < TifCount && fieldptr->tag < ROWS_PER_STRIP_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag == ROWS_PER_STRIP_TAG){
		rows_per_strip=fieldptr->value;
		if(fieldptr->type==TIF_SHORT){
			rows_per_strip=rows_per_strip&0xFFFF;
		}
		rows_per_strip=min(ObjPtr->High,rows_per_strip);
	}else{
		rows_per_strip=ObjPtr->High/strip_offset_count;
		if(ObjPtr->High%strip_offset_count)rows_per_strip++;
	}

/* STRIP_BYTE_COUNTS -- number of bytes in each strip */
	while(ifd_counter < TifCount && fieldptr->tag<STRIP_BYTE_COUNT_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag==STRIP_BYTE_COUNT_TAG){
		strip_byte_count_type=fieldptr->type;
		strip_byte_count_count=fieldptr->length;
		if(strip_byte_count_type==TIF_SHORT){
			if(strip_offset_count<3){
				strip_byte_count_offset=ifd_ptr+2+(long)&fieldptr->value-(long)&TifField->tag;
			}else{
				strip_byte_count_offset=fieldptr->value&0xFFFF;
			}
		}
		if(strip_byte_count_type==TIF_LONG){
			if(strip_byte_count_count==1){
				strip_byte_count_offset=ifd_ptr+2+(long)&fieldptr->value-(long)&TifField->tag;
			}else{
				strip_byte_count_offset=fieldptr->value;
			}
		}
	}else strip_byte_count_count=0;

/* we don't care about these --- */
	while(ifd_counter < TifCount && fieldptr->tag<X_RESOLUTION_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag==X_RESOLUTION_TAG){
	}

	while(ifd_counter < TifCount && fieldptr->tag<Y_RESOLUTION_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag==Y_RESOLUTION_TAG){
	}

	while(ifd_counter < TifCount && fieldptr->tag<X_POSITION_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag==X_POSITION_TAG){
	}

	while(ifd_counter < TifCount && fieldptr->tag < Y_POSITION_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag==Y_POSITION_TAG){
	}

	while(ifd_counter < TifCount && fieldptr->tag < SOFTWARE_VERSION_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag==SOFTWARE_VERSION_TAG){
	}

/* picks up TIFF format date */
	while(ifd_counter < TifCount && fieldptr->tag < DATE_TIME_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag==DATE_TIME_TAG){
		if(fieldptr->type==TIF_ASCII){
			date_length=fieldptr->length;
			if(fieldptr->length<5){
				date_offset = ifd_ptr+2+(long)&fieldptr->value-(long)&TifField->tag;
			}else{
				date_offset = fieldptr->value;
			}
		}
		date_length=min(date_length,DATE_LENGTH);
	}else date_length=0;

/* OPERATOR */
	while(ifd_counter < TifCount && fieldptr->tag<OPERATOR_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag==OPERATOR_TAG){
		if(fieldptr->type==TIF_ASCII){
			operator_length=fieldptr->length;
			if(fieldptr->length<5){
				operator_offset = ifd_ptr+2+(long)&fieldptr->value-(long)&TifField->tag;
			}else{
				operator_offset = fieldptr->value;
			}
		}
		operator_length=min(operator_length,OP_LENGTH);
	}else operator_length=0;

	sample_format_defined=0;
	while(ifd_counter < TifCount && fieldptr->tag < SAMPLE_FORMAT_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag == SAMPLE_FORMAT_TAG){
		sample_format = fieldptr->value;
		if(fieldptr->type == TIF_SHORT)sample_format = (sample_format>>16) & 0xFFFF;
		if(fieldptr->length==2){
			if(sample_format==SF_float_data){
				ObjPtr->DataType=ComplexData;
				ObjPtr->SignedData=-1;
			}
			else if(sample_format==SF_signed_int_data){
				ObjPtr->DataType=DistortionData;
				ObjPtr->SignedData=-1;
			}
			else{
				ObjPtr->DataType=UnknownData;
				ObjPtr->SignedData=0;
			}
		}else{
			if(sample_format==SF_float_data){
				ObjPtr->DataType=FloatData;
				ObjPtr->SignedData=-1;
			}
			else if(sample_format==SF_signed_int_data){
				ObjPtr->DataType=IntegerData;
				ObjPtr->SignedData=-1;
			}
			else if(sample_format==SF_unsigned_int_data){
				ObjPtr->DataType=IntegerData;
				ObjPtr->SignedData=0;
			}
			else{
				ObjPtr->DataType=UnknownData;
				ObjPtr->SignedData=0;
			}
		sample_format_defined=1;
		}
	}else{
		ObjPtr->DataType=UnknownData;
		ObjPtr->SignedData=0;
	}



/* TITLE --- This is NOT a TIFF STANDARD TAG */
	while(ifd_counter < TifCount && fieldptr->tag < TITLE_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag == TITLE_TAG){
		title_length = fieldptr->length;
		title_offset = fieldptr->value;
		if(title_length < 5) title_offset = ifd_ptr+2+(long)&fieldptr->value-(long)&TifField->tag;
	}else title_length = 0;

/* NUM_EXPOSURES -- Not STANDARD */
	while(ifd_counter < TifCount && fieldptr->tag < NUM_EXPOSURE_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag == NUM_EXPOSURE_TAG){
	 	if(fieldptr->type == TIF_LONG){
			num_exposures = fieldptr->value;
		}else num_exposures = 0;
	}else num_exposures = 0;

/* NUM_BACKGROUNDS -- Not STANDARD */
	while(ifd_counter < TifCount && fieldptr->tag < NUM_BACKGROUND_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag == NUM_BACKGROUND_TAG){
	 	if(fieldptr->type == TIF_LONG){
			num_backgrounds = fieldptr->value;
		}else num_backgrounds = 0;
	}else num_backgrounds = 0;

/* EXPOSURE_TIME */
	while(ifd_counter < TifCount && fieldptr->tag < EXPOSURE_TIME_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag == EXPOSURE_TIME_TAG){
	 	if(fieldptr->type == TIF_LONG){
			exp_time = fieldptr->value;
		}else exp_time = 0;
	}else exp_time = 0;

/* BACKGROUND_TIME */
	while(ifd_counter < TifCount && fieldptr->tag < BACKGROUND_TIME_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag == BACKGROUND_TIME_TAG){
	 	if(fieldptr->type == TIF_LONG){
			bkg_time = fieldptr->value;
		}else bkg_time = 0;
	}else bkg_time = 0;

/* SIGNED/UNSIGNED IMAGE STATUS */
	while(ifd_counter < TifCount && fieldptr->tag < SIGN_STATUS_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(!sample_format_defined){
		if(fieldptr->tag == SIGN_STATUS_TAG){
		 	if(fieldptr->type == TIF_LONG){
				ObjPtr->SignedData = fieldptr->value;
			}else ObjPtr->SignedData = 0;
		}else ObjPtr->SignedData = 0;
	ObjPtr->DataType=IntegerData;
	}

/* TELEMETRY POINTER */
	while(ifd_counter < TifCount && fieldptr->tag < TELEMETRY_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag == TELEMETRY_TAG){
	 	if(fieldptr->type == TIF_ASCII){
			telemetry_length = fieldptr->length;
			if(telemetry_length < 5)telemetry_length = 0;
			telemetry_offset = fieldptr->value;
		}else telemetry_length = 0;
	}else telemetry_length = 0;

/* IMAGE HISTORY */

	while(ifd_counter < TifCount && fieldptr->tag<IMAGE_HISTORY_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag==IMAGE_HISTORY_TAG){
	}

/* SUBIMAGE BPP */
	while(ifd_counter < TifCount && fieldptr->tag < SUB_BPP_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag == SUB_BPP_TAG){
	 	if(fieldptr->type == TIF_LONG){
			sub_bpp = fieldptr->value;
		}else sub_bpp = ObjPtr->Bpp;
	}else sub_bpp = ObjPtr->Bpp;

/* SUBIMAGE WIDE */
	while(ifd_counter < TifCount && fieldptr->tag < SUB_WIDE_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag == SUB_WIDE_TAG){
	 	if(fieldptr->type == TIF_LONG){
			sub_wide = fieldptr->value;
		}else sub_wide = ObjPtr->Wide;
	}else sub_wide = ObjPtr->Wide;

/* SUBIMAGE HIGH */
	while(ifd_counter < TifCount && fieldptr->tag < SUB_HIGH_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag == SUB_HIGH_TAG){
	 	if(fieldptr->type == TIF_LONG){
			sub_high = fieldptr->value;
		}else sub_high = ObjPtr->High;
	}else sub_high = ObjPtr->High;

/* BLACK_LEVEL */
	while(ifd_counter < TifCount && fieldptr->tag < BLACK_LEVEL_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag == BLACK_LEVEL_TAG){
	 	if(fieldptr->type == TIF_FLOAT){
			memcpy(&black_level,&fieldptr->value,sizeof(float));
		}else black_level = 0.0;
	}else black_level = 0.0;

/* DARK CURRENT */
	while(ifd_counter < TifCount && fieldptr->tag < DARK_CURRENT_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag == DARK_CURRENT_TAG){
	 	if(fieldptr->type == TIF_FLOAT){
			memcpy(&dark_current,&fieldptr->value,sizeof(float));
		}else dark_current = 0.0;
	}else dark_current = 0.0;

/* READ_NOISE */
	while(ifd_counter < TifCount && fieldptr->tag < READ_NOISE_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag == READ_NOISE_TAG){
	 	if(fieldptr->type == TIF_FLOAT){
			memcpy(&read_noise,&fieldptr->value,sizeof(float));
		}else read_noise = 0.0;
	}else read_noise = 0.0;

/* DARK CURRENT NOISE */
	while(ifd_counter < TifCount && fieldptr->tag < DARK_CURRENT_NOISE_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag == DARK_CURRENT_NOISE_TAG){
	 	if(fieldptr->type == TIF_FLOAT){
			memcpy(&dark_current_noise,&fieldptr->value,sizeof(float));
		}else dark_current_noise = 0.0;
	}else dark_current_noise = 0.0;

/* BEAM MONITOR */
	while(ifd_counter < TifCount && fieldptr->tag < BEAM_MONITOR_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag == BEAM_MONITOR_TAG){
	 	if(fieldptr->type == TIF_FLOAT){
			memcpy(&beam_monitor,&fieldptr->value,sizeof(float));
		}else beam_monitor = -1.0;
	}else beam_monitor = -1.0;

/* ARRAY OF USER VARIABLES */
	while(ifd_counter < TifCount && fieldptr->tag < USER_VARIABLES_TAG){
		fieldptr++;
		ifd_counter++;
	}
	if(fieldptr->tag == USER_VARIABLES_TAG){
	 	if(fieldptr->type == TIF_LONG){
			user_var_length = fieldptr->length;
			if(user_var_length > NUM_USER_VARIABLES)user_var_length = NUM_USER_VARIABLES;
			user_var_offset = fieldptr->value;
			if(user_var_length < 2) user_var_offset =  ifd_ptr+2+(long)&fieldptr->value-(long)&TifField->tag;
		}else user_var_length = 0;
	}else user_var_length = 0;

/* Now we have the complete set of offsets to the fields and some of the data.
We have yet to fill these fields -- remember we have read in READSIZE bytes
at the beginning but we are not gauranteed these fields will be in this
buffer -- first we check if any of the fields are in the buffer - if so,
get the data - then read other fields from disk if necessary. We put this
info into a structure of type image_info which is allocated at this time
*/

	if( (info = (struct image_info *) malloc( sizeof(struct image_info))) == NULL){
		printf("GET_IM_HEAD memory allocation error\n");
		return(1);
	}
	ObjPtr->Header = (char *)info;
	memset(info,0,sizeof(struct image_info));	 // zero everything

// malloc space for strings and arrays
if(descriptor_length>0)
	if((info->descriptor=(char *)malloc(descriptor_length))==NULL) goto t_malloc_err;
if(telemetry_length>0)
	if((info->telemetry=(char *)malloc(telemetry_length))==NULL) goto t_malloc_err;
if(title_length>0)
	if((info->title=(char *)malloc(title_length))==NULL) goto t_malloc_err;
	goto no_t_malloc_err;
t_malloc_err:
	printf("get_im_head malloc error\n");
	return(1);
no_t_malloc_err:


/* IF WE STILL HAVE VALID DATA IN THE BUFFER */
	if(readflag == 1){

		if(descriptor_length > 0){		/* ASCII FIELD */
			if(descriptor_offset + descriptor_length <= read_count){
				info->descriptor_length = descriptor_length;
				memcpy(info->descriptor , &ObjPtr->Buffer[descriptor_offset] , descriptor_length);
			}else{
				readflag = 0;
				if(tapeflag) return(2);
			}
		}else info->descriptor_length = 0;

		if(detector_length > 0){			/* ASCII FIELD */
			if(detector_offset + detector_length <= read_count){
				memcpy(info->detector , &ObjPtr->Buffer[detector_offset] , detector_length);
			}else{
				readflag = 0;
				if(tapeflag) return(2);
			}
		}else info->detector[0] = 0;

		if(operator_length > 0){			/* ASCII FIELD */
			if(operator_offset + operator_length <= read_count){
				memcpy(info->operator , &ObjPtr->Buffer[operator_offset] , operator_length);
			}else{
				readflag = 0;
				if(tapeflag) return(2);
			}
		}else info->operator[0] = 0;

		if(date_length > 0){			/* ASCII FIELD */
			if(date_offset + date_length <= read_count){
				memcpy(info->date , &ObjPtr->Buffer[date_offset] , date_length);
			}else{
				readflag = 0;
				if(tapeflag) return(2);
			}
		}else info->date[0] = 0;

		k=sizeof(long);
		k = sizeof(long);
		if ( strip_offset_type == TIF_SHORT ) k = sizeof(short);
		kk = sizeof(long);
		if ( strip_byte_count_type == TIF_SHORT ) kk = sizeof(short);

		if(strip_offset + strip_offset_count*k <= read_count){
			info->num_strips = strip_offset_count;
			if( (info->strip_pointers = (long *)malloc( sizeof(long) * strip_offset_count) ) == NULL){
				printf("GET_IM_HEAD memory allocation error\n");
				return(1);
			}
			memcpy(info->strip_pointers , &ObjPtr->Buffer[strip_offset] , strip_offset_count*k);
			if( strip_offset_type == TIF_SHORT){		/* convert to type long */
				short_ptr = (unsigned short *) info->strip_pointers;
				if(big_endian && info->num_strips > 2)
					TIFFSwabArrayOfShort((unsigned short *)short_ptr,(int)info->num_strips);
				for(i = strip_offset_count - 1 ; i > -1 ; i--){
					info->strip_pointers[i] = (unsigned long)short_ptr[i];
				}
			}else{
				if(big_endian && info->num_strips > 1)
					TIFFSwabArrayOfLong((unsigned long *)info->strip_pointers,(int)info->num_strips);
			}
		}else{
			readflag = 0;
			if(tapeflag) return(2);
		}

		if(strip_byte_count_count){ /* some files may not have byte counts - reconstruct if thats the case */
		 if( strip_byte_count_offset + strip_offset_count*kk <= read_count){
		 	if( (info->strip_byte_counts = (long *)malloc(sizeof(long) * strip_offset_count)) == NULL){
				printf("GET_IM_HEAD memory allocation error\n");
				return(1);
			}
			memcpy(info->strip_byte_counts , &ObjPtr->Buffer[strip_byte_count_offset] , strip_offset_count*k);
			if(strip_byte_count_type == TIF_SHORT){		/* convert to type long */
				short_ptr = (unsigned short *)info->strip_byte_counts;
				if(big_endian && info->num_strips > 2)
					TIFFSwabArrayOfShort(short_ptr,(int)info->num_strips);
				for(i = strip_offset_count - 1 ; i > -1 ; i--){
					info->strip_byte_counts[i] = (unsigned long)short_ptr[i];
				}
			}else{
				if(big_endian && info->num_strips > 1)
					TIFFSwabArrayOfLong((unsigned long *)info->strip_byte_counts,(int)info->num_strips);
			}
			if(tapeflag){		/* check that tape file is sequential-- Tiff files don't have to be */
				if(strip_offset_count > 1){
					for(i = 0; i < strip_offset_count-1 ; i++){
						if(info->strip_pointers[i] + info->strip_byte_counts[i] != info->strip_pointers[i+1]){
							return(2);
						}
					}
				}
			}
		 }else{
			readflag = 0;
			if(tapeflag) return(2);
		 }
		}

		if(title_length > 0){
			if(title_offset + title_length <= read_count){
				memcpy(info->title , &ObjPtr->Buffer[title_offset] , title_length);
			}else{
				readflag = 0;
				if(tapeflag) return(2);
			}
		}

		if(telemetry_length > 0){
			if(telemetry_offset + telemetry_length <= read_count){
				memcpy(info->telemetry , &ObjPtr->Buffer[telemetry_offset] , telemetry_length);
			}else{
				readflag = 0;
				if(tapeflag) return(2);
			}
		}

		if(user_var_length > 0){
			if(user_var_offset + user_var_length * sizeof(long) <= read_count){
				memcpy(info->user_vars , &ObjPtr->Buffer[user_var_offset] , user_var_length * sizeof(long));
			}else{
				readflag = 0;
				if(tapeflag) return(2);
			}
		}else info->user_vars[0] = 0;

	}

	
/* COME HERE IF WE NEED OTHER DISK READS */
	if(readflag == 0){		/* all the information was not in the original read buffer */

		if(descriptor_length > 0){
			if(descriptor_offset + descriptor_length > read_count){
				info->descriptor_length = descriptor_length;
				lseek(ObjPtr->Handle , descriptor_offset , SEEK_SET);
				read(ObjPtr->Handle, info->descriptor , descriptor_length);
			}
		}else info->descriptor_length = 0;

		if(detector_length > 0){
			if(detector_offset + detector_length > read_count){
				lseek(ObjPtr->Handle , detector_offset , SEEK_SET);
				read(ObjPtr->Handle, info->detector , detector_length);
			}
		}else info->detector[0] = 0;

		if(operator_length > 0){
			if(operator_offset + operator_length > read_count){
				lseek(ObjPtr->Handle , operator_offset , SEEK_SET);
				read(ObjPtr->Handle, info->operator , operator_length);
			}
		}else info->operator[0] = 0;

		if(date_length > 0){
			if(date_offset + date_length > read_count){
				lseek(ObjPtr->Handle , date_offset , SEEK_SET);
				read(ObjPtr->Handle, info->date , date_length);
			}
		}else info->date[0] = 0;

		if(title_length > 0){
			if(title_offset + title_length > read_count){
				lseek(ObjPtr->Handle , title_offset , SEEK_SET);
				read(ObjPtr->Handle, info->title , title_length);
			}
		}

		if(telemetry_length > 0){
			if(telemetry_offset + telemetry_length > read_count){
				lseek(ObjPtr->Handle , telemetry_offset , SEEK_SET);
				read(ObjPtr->Handle, info->telemetry , telemetry_length);
			}
		}

		if(user_var_length > 0){
			if(user_var_offset + user_var_length * sizeof(long) > read_count){
				lseek(ObjPtr->Handle , user_var_offset , SEEK_SET);
				read(ObjPtr->Handle, info->user_vars , user_var_length * 4);
			}
		}else info->user_vars[0] = 0;

		k=sizeof(long);
		k = sizeof(long);
		if ( strip_offset_type == TIF_SHORT ) k = sizeof(short);
		kk = sizeof(long);
		if ( strip_byte_count_type == TIF_SHORT ) kk = sizeof(short);

		info->num_strips = strip_offset_count;
		if( (info->strip_pointers = (long *)malloc( sizeof(long) * strip_offset_count)) == NULL){
			printf("GET_IM_HEAD memory allocation error\n");
			return(1);
		}
		lseek( ObjPtr->Handle , strip_offset , SEEK_SET);
		read( ObjPtr->Handle , info->strip_pointers , k * strip_offset_count );
		if( strip_offset_type == TIF_SHORT){
			short_ptr = (unsigned short *) info->strip_pointers;
			if(big_endian)
				TIFFSwabArrayOfShort(short_ptr,(int)info->num_strips);
			for(i = strip_offset_count - 1 ; i > -1 ; i--){
				info->strip_pointers[i] = (unsigned long)short_ptr[i];
			}
		}else{
			if(big_endian)
				TIFFSwabArrayOfLong((unsigned long *)info->strip_pointers,(int)info->num_strips);
		}

		if(strip_byte_count_count){
			if( (info->strip_byte_counts = (long *)malloc(sizeof(long) * strip_offset_count)) == NULL){
				printf("GET_IM_HEAD memory allocation error\n");
				return(1);
			}
			lseek(ObjPtr->Handle , strip_byte_count_offset , SEEK_SET);
			read(ObjPtr->Handle , info->strip_byte_counts , kk * strip_offset_count);
			if(strip_byte_count_type == TIF_SHORT){
				short_ptr = (unsigned short *)info->strip_byte_counts;
				if(big_endian)
					TIFFSwabArrayOfShort(short_ptr,(int)info->num_strips);
				for(i = strip_offset_count - 1 ; i > -1 ; i--){
					info->strip_byte_counts[i] = (unsigned long)short_ptr[i];
				}
			}else{
				if(big_endian)
					TIFFSwabArrayOfLong((unsigned long *)info->strip_byte_counts,(int)info->num_strips);
			}
		}
	}


/* NOW WE HAVE ALL DATA FROM TIFF HEADER --- TRANSLATE AS NEEDED FOR TV6 */
	if(info->date[0]!=0){
		ObjPtr->TimeStamp = tif_date_to_int(info->date);
	}else{
		ObjPtr->TimeStamp = 0;
	}

	if(!user_var_length)for(i=0;i<NUM_USER_VARIABLES;i++)info->user_vars[i]=0;

	ObjPtr->Kind = Image;
	if(!tapeflag) ObjPtr->Type = Disk;

/* Beginning of row will be byte alligned - we fake it by changing Wide */
	if(ObjPtr->Bpp < 8) while(ObjPtr->Bpp * ObjPtr->Wide % 8)ObjPtr->Wide++;

	if(!strip_byte_count_count){			 /* if no byte counts have been defined */
		if( (info->strip_byte_counts = (long *)malloc(sizeof(long) * strip_offset_count)) == NULL){
			printf("GET_IM_HEAD memory allocation error\n");
			return(1);
		}
		for(i=0;i<strip_offset_count;i++){
			info->strip_byte_counts[i]=ObjPtr->Wide*ObjPtr->Bpp*rows_per_strip/8;
		}
		if(i=ObjPtr->High%rows_per_strip)
			info->strip_byte_counts[strip_offset_count-1]=i*ObjPtr->Wide*ObjPtr->Bpp/8;
	}
	


	ObjPtr->Pitch = ObjPtr->Wide;
	ObjPtr->Sbpp = sub_bpp;
	ObjPtr->Swide = sub_wide;
	ObjPtr->Shigh = sub_high;
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	// I believe these are global variables in TV6.  Consequently, we don't want to use them.
	// DefaultWide=ObjPtr->Wide;
	// DefaultHigh=ObjPtr->High;
	// DefaultBpp=ObjPtr->Bpp;
	// Instead, put them in the extra fields added to the image_info structure.
	((struct image_info *)(ObjPtr->Header))->image_width = ObjPtr->Wide;
	((struct image_info *)(ObjPtr->Header))->image_height = ObjPtr->High;
	((struct image_info *)(ObjPtr->Header))->DataType = ObjPtr->DataType;
        ((struct image_info *)(ObjPtr->Header))->SignedData = ObjPtr->SignedData;   
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	ObjPtr->Sx = 0;
	ObjPtr->Sy = 0;
	ObjPtr->NextByte = 0;			/* data could be anywhere */
	ObjPtr->NBytes = 0;			/* so we free up this end */
	free(ObjPtr->Buffer);
	ObjPtr->Buffer=NULL;
	info->num_exposures=num_exposures;
	info->num_backgrounds=num_backgrounds;
	info->exposure_time=exp_time;
	info->background_time=bkg_time;
	info->big_endian=big_endian;
	info->compression=compression;
	info->rows_per_strip=rows_per_strip;
	info->black_level=black_level;
	info->dark_current=dark_current;
	info->read_noise=read_noise;
	info->dark_current_noise=dark_current_noise;
	info->beam_monitor=beam_monitor;
	return(0);
}

/* *********************-------- tif_date_to_int ----------************** */
time_t tif_date_to_int(char *date)
{
struct tm time;
char year[5],
	month[3],
	day[3],
	hour[3],
	min[3],
	sec[3];
	memcpy(year,date,4);
	year[4]=0;
	memcpy(month,&date[5],2);
	month[2]=0;
	memcpy(day,&date[8],2);
	day[2]=0;
	memcpy(hour,&date[11],2);
	hour[2]=0;
	memcpy(min,&date[14],2);
	min[2]=0;
	memcpy(sec,&date[17],2);
	sec[2]=0;
	time.tm_year=atoi(year)-1900;
	time.tm_mon=atoi(month)-1;
	time.tm_mday=atoi(day);
	time.tm_hour=atoi(hour);
	time.tm_min=atoi(min);
	time.tm_sec=atoi(sec);
	return(mktime(&time));
}

/* *********************-------- TIFF_field_order ----------************** */
static TIFF_field_order(struct tif_field *fieldptr , unsigned short count)
{
struct tif_field temp;
struct tif_field *tptr;
struct tif_field *tptr2;
int maxfield,order,i,j;
	maxfield=0;
	order=1;
	tptr=fieldptr;
	for(i=0;i<count;i++){
		if(maxfield > tptr->tag)order=0;
		maxfield=tptr->tag;
		tptr++;
	}
	if(order)return;
	for(i=0;i<count;i++){		/* bubble sort entries */
		tptr=fieldptr;
		tptr2=tptr+1;
		for(j=0;j<count-1;j++){
			if(tptr->tag > tptr2->tag){
				memcpy(&temp,tptr,sizeof(struct tif_field));
				memcpy(tptr,tptr2,sizeof(struct tif_field));
				memcpy(tptr2,&temp,sizeof(struct tif_field));
			}
			tptr++;
			tptr2++;
		}
	}
}



/*
 * Copyright (c) 1988, 1989, 1990, 1991, 1992 Sam Leffler
 * Copyright (c) 1991, 1992 Silicon Graphics, Inc.
 *
 * Permission to use, copy, modify, distribute, and sell this software and
 * its documentation for any purpose is hereby granted without fee, provided
 * that (i) the above copyright notices and this permission notice appear in
 * all copies of the software and related documentation, and (ii) the names of
 * Sam Leffler and Silicon Graphics may not be used in any advertising or
 * publicity relating to the software without the specific, prior written
 * permission of Sam Leffler and Silicon Graphics.
 *
 * THE SOFTWARE IS PROVIDED "AS-IS" AND WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS, IMPLIED OR OTHERWISE, INCLUDING WITHOUT LIMITATION, ANY
 * WARRANTY OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.
 *
 * IN NO EVENT SHALL SAM LEFFLER OR SILICON GRAPHICS BE LIABLE FOR
 * ANY SPECIAL, INCIDENTAL, INDIRECT OR CONSEQUENTIAL DAMAGES OF ANY KIND,
 * OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
 * WHETHER OR NOT ADVISED OF THE POSSIBILITY OF DAMAGE, AND ON ANY THEORY OF
 * LIABILITY, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE
 * OF THIS SOFTWARE.
 */

/*
 * TIFF Library Bit & Byte Swapping Support.
 *
 * XXX We assume short = 16-bits and long = 32-bits XXX
 */

static TIFFSwabShort(wp)
    unsigned short *wp;
{
    register unsigned char *cp = (unsigned char *)wp;
    int t;

    t = cp[1]; cp[1] = cp[0]; cp[0] = t;
}

static TIFFSwabLong(lp)
    unsigned long *lp;
{
    register unsigned char *cp = (unsigned char *)lp;
    int t;

    t = cp[3]; cp[3] = cp[0]; cp[0] = t;
    t = cp[2]; cp[2] = cp[1]; cp[1] = t;
}

static TIFFSwabArrayOfShort(wp, n)
    unsigned short *wp;
    register int n;
{
    register unsigned char *cp;
    register int t;

    /* XXX unroll loop some */
    while (n-- > 0) {
        cp = (unsigned char *)wp;
        t = cp[1]; cp[1] = cp[0]; cp[0] = t;
        wp++;
    }
}

static TIFFSwabArrayOfLong(lp, n)
    register unsigned long *lp;
    register int n;
{
    register unsigned char *cp;
    register int t;

    /* XXX unroll loop some */
    while (n-- > 0) {
        cp = (unsigned char *)lp;
        t = cp[3]; cp[3] = cp[0]; cp[0] = t;
        t = cp[2]; cp[2] = cp[1]; cp[1] = t;
        lp++;
    }
}

/*
 * Bit reversal tables.  TIFFBitRevTable[<byte>] gives
 * the bit reversed value of <byte>.  Used in various
 * places in the library when the FillOrder requires
 * bit reversal of byte values (e.g. CCITT Fax 3
 * encoding/decoding).  TIFFNoBitRevTable is provided
 * for algorithms that want an equivalent table that
 * do not reverse bit values.
 */
const unsigned char TIFFBitRevTable[256] = {
    0x00, 0x80, 0x40, 0xc0, 0x20, 0xa0, 0x60, 0xe0,
    0x10, 0x90, 0x50, 0xd0, 0x30, 0xb0, 0x70, 0xf0,
    0x08, 0x88, 0x48, 0xc8, 0x28, 0xa8, 0x68, 0xe8,
    0x18, 0x98, 0x58, 0xd8, 0x38, 0xb8, 0x78, 0xf8,
    0x04, 0x84, 0x44, 0xc4, 0x24, 0xa4, 0x64, 0xe4,
    0x14, 0x94, 0x54, 0xd4, 0x34, 0xb4, 0x74, 0xf4,
    0x0c, 0x8c, 0x4c, 0xcc, 0x2c, 0xac, 0x6c, 0xec,
    0x1c, 0x9c, 0x5c, 0xdc, 0x3c, 0xbc, 0x7c, 0xfc,
    0x02, 0x82, 0x42, 0xc2, 0x22, 0xa2, 0x62, 0xe2,
    0x12, 0x92, 0x52, 0xd2, 0x32, 0xb2, 0x72, 0xf2,
    0x0a, 0x8a, 0x4a, 0xca, 0x2a, 0xaa, 0x6a, 0xea,
    0x1a, 0x9a, 0x5a, 0xda, 0x3a, 0xba, 0x7a, 0xfa,
    0x06, 0x86, 0x46, 0xc6, 0x26, 0xa6, 0x66, 0xe6,
    0x16, 0x96, 0x56, 0xd6, 0x36, 0xb6, 0x76, 0xf6,
    0x0e, 0x8e, 0x4e, 0xce, 0x2e, 0xae, 0x6e, 0xee,
    0x1e, 0x9e, 0x5e, 0xde, 0x3e, 0xbe, 0x7e, 0xfe,
    0x01, 0x81, 0x41, 0xc1, 0x21, 0xa1, 0x61, 0xe1,
    0x11, 0x91, 0x51, 0xd1, 0x31, 0xb1, 0x71, 0xf1,
    0x09, 0x89, 0x49, 0xc9, 0x29, 0xa9, 0x69, 0xe9,
    0x19, 0x99, 0x59, 0xd9, 0x39, 0xb9, 0x79, 0xf9,
    0x05, 0x85, 0x45, 0xc5, 0x25, 0xa5, 0x65, 0xe5,
    0x15, 0x95, 0x55, 0xd5, 0x35, 0xb5, 0x75, 0xf5,
    0x0d, 0x8d, 0x4d, 0xcd, 0x2d, 0xad, 0x6d, 0xed,
    0x1d, 0x9d, 0x5d, 0xdd, 0x3d, 0xbd, 0x7d, 0xfd,
    0x03, 0x83, 0x43, 0xc3, 0x23, 0xa3, 0x63, 0xe3,
    0x13, 0x93, 0x53, 0xd3, 0x33, 0xb3, 0x73, 0xf3,
    0x0b, 0x8b, 0x4b, 0xcb, 0x2b, 0xab, 0x6b, 0xeb,
    0x1b, 0x9b, 0x5b, 0xdb, 0x3b, 0xbb, 0x7b, 0xfb,
    0x07, 0x87, 0x47, 0xc7, 0x27, 0xa7, 0x67, 0xe7,
    0x17, 0x97, 0x57, 0xd7, 0x37, 0xb7, 0x77, 0xf7,
    0x0f, 0x8f, 0x4f, 0xcf, 0x2f, 0xaf, 0x6f, 0xef,
    0x1f, 0x9f, 0x5f, 0xdf, 0x3f, 0xbf, 0x7f, 0xff
};
const unsigned char TIFFNoBitRevTable[256] = {
    0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
    0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
    0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17,
    0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f,
    0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27,
    0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f,
    0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37,
    0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f,
    0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47,
    0x48, 0x49, 0x4a, 0x4b, 0x4c, 0x4d, 0x4e, 0x4f,
    0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57,
    0x58, 0x59, 0x5a, 0x5b, 0x5c, 0x5d, 0x5e, 0x5f,
    0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67,
    0x68, 0x69, 0x6a, 0x6b, 0x6c, 0x6d, 0x6e, 0x6f,
    0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77,
    0x78, 0x79, 0x7a, 0x7b, 0x7c, 0x7d, 0x7e, 0x7f,
    0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87,
    0x88, 0x89, 0x8a, 0x8b, 0x8c, 0x8d, 0x8e, 0x8f,
    0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97,
    0x98, 0x99, 0x9a, 0x9b, 0x9c, 0x9d, 0x9e, 0x9f,
    0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7,
    0xa8, 0xa9, 0xaa, 0xab, 0xac, 0xad, 0xae, 0xaf,
    0xb0, 0xb1, 0xb2, 0xb3, 0xb4, 0xb5, 0xb6, 0xb7,
    0xb8, 0xb9, 0xba, 0xbb, 0xbc, 0xbd, 0xbe, 0xbf,
    0xc0, 0xc1, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7,
    0xc8, 0xc9, 0xca, 0xcb, 0xcc, 0xcd, 0xce, 0xcf,
    0xd0, 0xd1, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7,
    0xd8, 0xd9, 0xda, 0xdb, 0xdc, 0xdd, 0xde, 0xdf,
    0xe0, 0xe1, 0xe2, 0xe3, 0xe4, 0xe5, 0xe6, 0xe7,
    0xe8, 0xe9, 0xea, 0xeb, 0xec, 0xed, 0xee, 0xef,
    0xf0, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf6, 0xf7,
    0xf8, 0xf9, 0xfa, 0xfb, 0xfc, 0xfd, 0xfe, 0xff,
};

static TIFFReverseBits(cp, n)
    register unsigned char *cp;
    register int n;
{
    for (; n > 8; n -= 8) {
        cp[0] = TIFFBitRevTable[cp[0]];
        cp[1] = TIFFBitRevTable[cp[1]];
        cp[2] = TIFFBitRevTable[cp[2]];
        cp[3] = TIFFBitRevTable[cp[3]];
        cp[4] = TIFFBitRevTable[cp[4]];
        cp[5] = TIFFBitRevTable[cp[5]];
        cp[6] = TIFFBitRevTable[cp[6]];
        cp[7] = TIFFBitRevTable[cp[7]];
        cp += 8;
    }
    while (n-- > 0)
        *cp = TIFFBitRevTable[*cp], cp++;
}

/* *********************-------- TIFFSwabIFD ----------************** */
/* MWT -- 3/20/92 */
static TIFFSwabIFD(struct tif_field *fields,unsigned short count)
{
unsigned short *short_ptr;
	while(count--){
		TIFFSwabShort(&fields->tag);
		TIFFSwabShort(&fields->type);
		TIFFSwabLong(&fields->length);
		switch(fields->type){
			case 1:
			case 2:
				if(fields->length > 4)TIFFSwabLong(&fields->value);
				break;
			case 3:
				if(fields->length > 2)TIFFSwabLong(&fields->value);
				else{
					short_ptr=(unsigned short *)&fields->value;
					TIFFSwabShort(short_ptr);
					short_ptr++;
					TIFFSwabShort(short_ptr);
				}
				break;
			case 4:
				TIFFSwabLong(&fields->value);
				break;
			case 5:
				TIFFSwabLong(&fields->value);
				break;
			default:
				break;
			}
		fields++;
	}
}



