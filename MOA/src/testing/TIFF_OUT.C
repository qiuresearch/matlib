/* tiff_out.c
 routines for writing tiff images to disk


3-9-93 MWT -- fill info->strip_pointers with valid information as we go
	out the door.

9-21-93 MWT -- fix float data storage (black_level,etc.) -- was storing
	as truncated unsigned longs.

*/

#include <io.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <dos.h>
#include <malloc.h>
#include "tiff2.h"
#include "object.h"
#include "tv6sys.pro"

/*
strip_calc(struct object_descriptor *);
write_compress_image(struct object_descriptor *,char *);
int writ_diskimage(struct object_descriptor *,unsigned long,unsigned long,char *);
char * make_im_head(struct object_descriptor *,long *);
char * make_tif_header(struct object_descriptor *,long *);
tif_date(char *);
*/

/******************--------- strip_calc ------------**************/
/* calculate the needed strip_byte_counts for an image.  Calculates
16 rows per strip for LZW compression and 1 strip_per_image for non-compressed
data -- this is the place to change the strip size in the future.
In writing a compressed image 
	1. set info->compression=5
	2. call make_im_head which calls strip_calc to set
		 up a nominal set of strip pointers and counts -- the fake header
		 should then be written to disk.
	3. call write_compress_image, this will compress each strip and modify
		info->strip_byte_counts and sequentially write the strips to disk.
		This calls make_im_head again with the updated strip_byte_counts-
		this creates a real header (of the same size as the fake header)
		which overwrites the fake header at the beginning of the file.

In writing an uncompressed image
	1. set info->compression=1
	2. call make_im_head -- write header to file
	3. call write_diskimage to write out all image data sequentially

Note a call to move_image performs each of these steps 
 */

int rows_per_strip=0;

strip_calc(struct object_descriptor *ObjPtr)
{
struct image_info *info;
int i;
unsigned long laststrip,numbytes,a;
	info=(struct image_info *)ObjPtr->Header;
	if(!ObjPtr->Pitch)ObjPtr->Pitch=ObjPtr->Wide;
	switch(info->compression){
		case 5:
			numbytes= ObjPtr->Pitch*16*ObjPtr->Bpp/8;
			laststrip = numbytes;
			info->rows_per_strip=16;
			info->num_strips=ObjPtr->High/info->rows_per_strip;
			if(a=ObjPtr->High%info->rows_per_strip){
				info->num_strips++;
				laststrip=a*ObjPtr->Pitch*ObjPtr->Bpp/8;
			}
			if((info->strip_pointers = (long *)malloc(sizeof(long)*info->num_strips))==NULL){
				printf("malloc error /n");
				return(1);
			}
			if((info->strip_byte_counts = (long *)malloc(sizeof(long)*info->num_strips))==NULL){
				printf("malloc error /n");
				return(1);
			}
			for(i=0;i<info->num_strips-1;i++){
				info->strip_byte_counts[i]=numbytes;
			}
			info->strip_byte_counts[info->num_strips-1]=laststrip;
			break;
		default:
			info->compression=1;
			if(!rows_per_strip){		//rows_per_strip==0 use only one strip
				info->rows_per_strip=ObjPtr->High;
				info->num_strips=1;
				if((info->strip_pointers = (long *)malloc(sizeof(long)))==NULL){
					printf("malloc error /n");
					return(1);
				}
				if((info->strip_byte_counts = (long *)malloc(sizeof(long)))==NULL){
					printf("malloc error /n");
					return(1);
				}
				*info->strip_byte_counts = ObjPtr->Pitch*ObjPtr->High*ObjPtr->Bpp/8;
			}else{
				info->rows_per_strip=min(max(1,rows_per_strip),ObjPtr->High);
				info->num_strips=(ObjPtr->High+info->rows_per_strip-1)/info->rows_per_strip;
				if((info->strip_pointers = (long *)malloc(sizeof(long)*info->num_strips))==NULL){
					printf("malloc error /n");
					return(1);
				}
				if((info->strip_byte_counts = (long *)malloc(sizeof(long)*info->num_strips))==NULL){
					printf("malloc error /n");
					return(1);
				}
				for(i=0;i<info->num_strips;i++)
					info->strip_byte_counts[i] = (ObjPtr->Pitch*ObjPtr->Bpp/8)*info->rows_per_strip;
				if(ObjPtr->High%info->rows_per_strip)
					info->strip_byte_counts[info->num_strips-1] = (ObjPtr->Pitch*ObjPtr->Bpp/8)*(ObjPtr->High%info->rows_per_strip);
			}					
			break;
		}
}
/* *************-------- write_compress_image -------***************** */
write_compress_image(struct object_descriptor *ObjPtr,char *uncompressed_data)
{
struct image_info *info;
char *head;
long headsize;
long numbytes;
char *c_ptr;
int i;
	c_ptr=uncompressed_data;
	info=(struct image_info *)ObjPtr->Header;
	info->compression=5;
	info->strip_pointers=NULL;
	info->strip_byte_counts=NULL;
	head = make_im_head(ObjPtr,&headsize);
	lseek(ObjPtr->Handle,0,SEEK_SET);
	write(ObjPtr->Handle,head,headsize);
	if(!ObjPtr->Pitch)ObjPtr->Pitch=ObjPtr->Wide;
	if((ObjPtr->Buffer=(char *)malloc(ObjPtr->Pitch*info->rows_per_strip*ObjPtr->Bpp/8))==NULL){
		printf("malloc error\n");
		return(1);
	}
	for(i=0;i<info->num_strips;i++){
		LZWPreEncode(ObjPtr,info->strip_byte_counts[i]);
		LZWEncode(ObjPtr,c_ptr,info->strip_byte_counts[i]);
		LZWPostEncode(ObjPtr,&numbytes);
		c_ptr+=info->strip_byte_counts[i];
		info->strip_byte_counts[i]=numbytes;
		write(ObjPtr->Handle,ObjPtr->Buffer,numbytes);
	}	
	LZWCleanup(ObjPtr);
	head = make_im_head(ObjPtr,&headsize);
	lseek(ObjPtr->Handle,0,SEEK_SET);
	write(ObjPtr->Handle,head,headsize);
}
	

/* **********--------- write_diskimage --------*********** */
int writ_diskimage(struct object_descriptor *ObjPtr ,unsigned long byteoffset ,unsigned long numbytes ,char *data)
{
/*	this routine assumes that the file has been opened and that the header has
been written
*/
int		nerr;
struct image_info *info;
	info = (struct image_info *)ObjPtr->Header;
	if(info->compression==5){
		if(byteoffset!=0||numbytes!=ObjPtr->Pitch*ObjPtr->High*ObjPtr->Bpp/8){
			printf("compression of images requires whole image to be written\n");
			return(1);
		}
		write_compress_image(ObjPtr,data);
	}
	nerr=lseek(ObjPtr->Handle , byteoffset + info->tif_head_length , SEEK_SET);
	if(nerr == -1) return(nerr);
	nerr = write(ObjPtr->Handle , data , numbytes);
	if(nerr != numbytes){
		nerr = -1;
	}else nerr = 0;
	return(nerr);
}

/****************** make_im_head *************************************/
char * make_im_head(struct object_descriptor *ObjPtr , long *head_length)
{
/* This routine makes a header template for writing to disk or tape.
*/
char *head;
struct image_info *info;
	info = (struct image_info *)ObjPtr->Header;
	tif_date(info->date);
	head = make_tif_header(ObjPtr, head_length);
	return(head);
}

/* ---------------------  make_tif_header --------------------- */
char * make_tif_header(struct object_descriptor *ObjPtr,long *header_size)
{
struct image_info *info;
struct tif_header *TiffHeader;
unsigned long	strip_offset,
			telemetry_offset,
			telemetry_length,
			last_offset,
			title_offset,
			title_length,
			user_var_offset,
			xres_offset,
			yres_offset,
			operator_offset,
			detector_offset,
			descriptor_offset,
			descriptor_length,
			date_offset,
			software_ver_offset,
			strip_size_offset,
			start_offset,
			num_samples,
			sample_values,
			bytes;
short		i;
long 		rows_per_strip,
			num_strips,
			length,
			width,
			bits_per_pix;
char 		*head,
			*c_ptr;

	if(ObjPtr==NULL){
		printf("make_tif_header error -- ObjPtr is NULL\n");
		*header_size=0;
		return(NULL);
	}
	info = (struct image_info *)ObjPtr->Header;
	if(info==NULL){
		printf("make_tif_header error -- ObjPtr->Header is NULL\n");
		*header_size=0;
		return(NULL);
	}
	if(info->telemetry==NULL)
		telemetry_length=0;
	else
		telemetry_length=((strlen(info->telemetry)+4)/4)*4;
	if(info->descriptor==NULL)
		descriptor_length=0;
	else
		descriptor_length=((strlen(info->descriptor)+4)/4)*4;
	if(info->title==NULL)
		title_length=0;
	else
		title_length=((strlen(info->title)+4)/4)*4;
	if(info->strip_pointers==NULL) strip_calc(ObjPtr);
	*header_size = max( sizeof(struct tif_header) + descriptor_length 
		+ info->num_strips * 8 + title_length + telemetry_length, 4096);
	head = (char *)malloc(*header_size);
	if (head==NULL){
		printf("make_tif_header malloc error\n");
		*header_size=0;
		return(head);
	}
	info->tif_head_length = *header_size;
	memset(head , 0 , *header_size);
	TiffHeader = (struct tif_header *)head;
/* We assume this is a little-endian machine */
	TiffHeader->tiff = 0x4949;
	TiffHeader->version = 0x2A;
	TiffHeader->ifd_count = NUM_FIELDS;
	TiffHeader->next_ifd = 0;

	length = ObjPtr->High;
	if(!ObjPtr->Pitch)ObjPtr->Pitch=ObjPtr->Wide;
	width = ObjPtr->Pitch;
	bits_per_pix = ObjPtr->Bpp;
	if(ObjPtr->DataType==ComplexData||ObjPtr->DataType==DistortionData)
		num_samples=2;
	else
		num_samples=1;
	if(ObjPtr->DataType==ComplexData||ObjPtr->DataType==FloatData)
		sample_values=SF_float_data;
	else if(ObjPtr->DataType==IntegerData){
		if(ObjPtr->SignedData)
			sample_values=SF_signed_int_data;
		else
			sample_values=SF_unsigned_int_data;
		}
	else if(ObjPtr->DataType==DistortionData)
		sample_values=SF_signed_int_data;
	else sample_values=SF_undefined_data;
	sample_values+=sample_values<<16;
/* --- generate offsets to various fields from header structure --- */
	last_offset=sizeof(struct tif_header);
	if(title_length>4){
		title_offset=last_offset;
		last_offset+=title_length;
	}
	else memcpy(&title_offset,info->title,title_length);
	if(telemetry_length>4){
		telemetry_offset=last_offset;
		last_offset+=telemetry_length;
	}
	else memcpy(&telemetry_offset,info->telemetry,telemetry_length);
	if(descriptor_length>4){
		descriptor_offset=last_offset;
		last_offset+=descriptor_length;
	}
	else memcpy(&descriptor_offset,info->descriptor,descriptor_length);
	if(info->num_strips>1){	/* pointers to two lists of pointers */
		strip_offset=last_offset;
		strip_size_offset=strip_offset+info->num_strips*4;
	}else{	/* no double indirection in the case of a list of one pointer*/
		strip_offset=*header_size;
		strip_size_offset=*info->strip_byte_counts;
		if(info->strip_pointers==NULL){
			printf("no space allocated for strip pointer\n");
			if((info->strip_pointers=(long *)malloc(sizeof(long)))==NULL){
				printf("make_tif_header malloc error\n");
				*header_size=0;
				free(head);
				return(NULL);
			}
		}
		*info->strip_pointers=strip_offset; // stored for possible future reads
	}
	rows_per_strip = info->rows_per_strip;
	num_strips = info->num_strips;
	start_offset = (long)TiffHeader;
	TiffHeader->ifd_pointer = (long)&TiffHeader->ifd_count - start_offset;
	xres_offset = (long)&TiffHeader->xres[0] - start_offset;
	yres_offset = (long)&TiffHeader->yres[0] - start_offset;
	operator_offset = (long)&TiffHeader->operator[0] - start_offset;
	detector_offset = (long)&TiffHeader->detector[0] - start_offset;
	date_offset = (long)&TiffHeader->date[0] - start_offset;
	software_ver_offset = (long)&TiffHeader->software_ver[0] - start_offset;
	user_var_offset =  (long)&TiffHeader->user_variables[0] - start_offset;

/* fill the IFD fields -- .tags should be written in ascending order */
	i=0;								/* field counter */
	TiffHeader->fields[i].tag = NEW_SUB_FILE_TAG;		/* 0xFE */
	TiffHeader->fields[i].type = TIF_LONG;
	TiffHeader->fields[i].length = 1;
	TiffHeader->fields[i++].value = 0;

	TiffHeader->fields[i].tag = IMAGE_WIDTH_TAG;			/* 0x0100 */
	TiffHeader->fields[i].type = TIF_LONG;
	TiffHeader->fields[i].length = 1;
	TiffHeader->fields[i++].value = ObjPtr->Pitch;

	TiffHeader->fields[i].tag = IMAGE_LENGTH_TAG;		/* 0x101 */
	TiffHeader->fields[i].type = TIF_LONG;
	TiffHeader->fields[i].length = 1;
	TiffHeader->fields[i++].value = ObjPtr->High;

	TiffHeader->fields[i].tag = BITS_PER_SAMPLE_TAG;		/* 0x102 */
	TiffHeader->fields[i].type = TIF_SHORT;
	TiffHeader->fields[i].length = 1;
	TiffHeader->fields[i++].value = ObjPtr->Bpp;

	TiffHeader->fields[i].tag = DATA_COMPRESSION_TAG;		/* 0x103 */
	TiffHeader->fields[i].type = TIF_SHORT;
	TiffHeader->fields[i].length = 1;
	TiffHeader->fields[i++].value = info->compression;

	TiffHeader->fields[i].tag = PHOTOMETRIC_INTERPRETATION_TAG; /* 0X106 */
	TiffHeader->fields[i].type = TIF_SHORT;
	TiffHeader->fields[i].length = 1;
	TiffHeader->fields[i++].value = 1;

	TiffHeader->fields[i].tag = IMAGE_DESCRIPTOR_TAG;		/* 0x10E */
	TiffHeader->fields[i].type = TIF_ASCII;
	TiffHeader->fields[i].length = descriptor_length;
	TiffHeader->fields[i++].value = descriptor_offset;

	TiffHeader->fields[i].tag = DETECTOR_MAKE_TAG;		/* 0x110 */
	TiffHeader->fields[i].type = TIF_ASCII;
	TiffHeader->fields[i].length = DETECT_LENGTH;
	TiffHeader->fields[i++].value = detector_offset;

	TiffHeader->fields[i].tag = STRIP_OFFSET_TAG;		/* 0x111 */
	TiffHeader->fields[i].type = TIF_LONG;
	TiffHeader->fields[i].length = num_strips;
	TiffHeader->fields[i++].value = strip_offset;

	TiffHeader->fields[i].tag = ROWS_PER_STRIP_TAG;		/* 0x116 */
	TiffHeader->fields[i].type = TIF_LONG;
	TiffHeader->fields[i].length = 1;
	TiffHeader->fields[i++].value = rows_per_strip;

	TiffHeader->fields[i].tag = STRIP_BYTE_COUNT_TAG;		/* 0x117 */
	TiffHeader->fields[i].type = TIF_LONG;
	TiffHeader->fields[i].length = num_strips;
	TiffHeader->fields[i++].value = strip_size_offset;

	TiffHeader->fields[i].tag = X_RESOLUTION_TAG;		/* 0x11A */
	TiffHeader->fields[i].type = TIF_RATIONAL;
	TiffHeader->fields[i].length = 1;
	TiffHeader->fields[i++].value = xres_offset;

	TiffHeader->fields[i].tag = Y_RESOLUTION_TAG;		/* 0x11B */
	TiffHeader->fields[i].type = TIF_RATIONAL;
	TiffHeader->fields[i].length = 1;
	TiffHeader->fields[i++].value = yres_offset;

	TiffHeader->fields[i].tag = SOFTWARE_VERSION_TAG;		/* 0x131 */
	TiffHeader->fields[i].type = TIF_ASCII;
	TiffHeader->fields[i].length = SOFT_LENGTH;
	TiffHeader->fields[i++].value = software_ver_offset;

	TiffHeader->fields[i].tag = DATE_TIME_TAG;			/* 0x132 */
	TiffHeader->fields[i].type = TIF_ASCII;
	TiffHeader->fields[i].length = DATE_LENGTH;
	TiffHeader->fields[i++].value = date_offset;

	TiffHeader->fields[i].tag = OPERATOR_TAG;			/* 0x13B */
	TiffHeader->fields[i].type = TIF_ASCII;
	TiffHeader->fields[i].length = OP_LENGTH;
	TiffHeader->fields[i++].value = operator_offset;

	TiffHeader->fields[i].tag = SAMPLE_FORMAT_TAG;			/* 0x13B */
	TiffHeader->fields[i].type = TIF_SHORT;
	TiffHeader->fields[i].length = num_samples;
	TiffHeader->fields[i++].value = sample_values;

	TiffHeader->fields[i].tag = TITLE_TAG;				/* 0x9000 */
	TiffHeader->fields[i].type = TIF_ASCII;
	TiffHeader->fields[i].length = title_length;
	TiffHeader->fields[i++].value = title_offset;

	TiffHeader->fields[i].tag = NUM_EXPOSURE_TAG;		/* 0x9001 */
	TiffHeader->fields[i].type = TIF_LONG;
	TiffHeader->fields[i].length = 1;
	TiffHeader->fields[i++].value = info->num_exposures;

	TiffHeader->fields[i].tag = NUM_BACKGROUND_TAG;		/* 0x9002 */
	TiffHeader->fields[i].type = TIF_LONG;
	TiffHeader->fields[i].length = 1;
	TiffHeader->fields[i++].value = info->num_backgrounds;

	TiffHeader->fields[i].tag = EXPOSURE_TIME_TAG;		/* 0x9003 */
	TiffHeader->fields[i].type = TIF_LONG;
	TiffHeader->fields[i].length = 1;
	TiffHeader->fields[i++].value = info->exposure_time;

	TiffHeader->fields[i].tag = BACKGROUND_TIME_TAG;		/* 0x9004 */
	TiffHeader->fields[i].type = TIF_LONG;
	TiffHeader->fields[i].length = 1;
	TiffHeader->fields[i++].value = info->background_time;

//	TiffHeader->fields[i].tag = SIGN_STATUS_TAG;			/* 0x9005 */
//	TiffHeader->fields[i].type = TIF_LONG;
//	TiffHeader->fields[i].length = 1;
//	TiffHeader->fields[i++].value = ObjPtr->SignedData;

	TiffHeader->fields[i].tag = TELEMETRY_TAG;			/* 0x9006 */
	TiffHeader->fields[i].type = TIF_ASCII;
	TiffHeader->fields[i].length = telemetry_length;
	TiffHeader->fields[i++].value = telemetry_offset;

//	TiffHeader->fields[i].tag = DATA_TYPE_TAG;			/* 0x9008 */
//	TiffHeader->fields[i].type = TIF_ASCII;
//	TiffHeader->fields[i].length = DATA_TYPE_LENGTH;
//	TiffHeader->fields[i++].value = data_type_offset;

	TiffHeader->fields[i].tag = SUB_BPP_TAG;			/* 0x9009 */
	TiffHeader->fields[i].type = TIF_LONG;
	TiffHeader->fields[i].length = 1;
	TiffHeader->fields[i++].value = ObjPtr->Sbpp;

	TiffHeader->fields[i].tag = SUB_WIDE_TAG;			/* 0x900a */
	TiffHeader->fields[i].type = TIF_LONG;
	TiffHeader->fields[i].length = 1;
	TiffHeader->fields[i++].value = ObjPtr->Swide;

	TiffHeader->fields[i].tag = SUB_HIGH_TAG;			/* 0x900b */
	TiffHeader->fields[i].type = TIF_LONG;
	TiffHeader->fields[i].length = 1;
	TiffHeader->fields[i++].value = ObjPtr->Shigh;

	TiffHeader->fields[i].tag = BLACK_LEVEL_TAG;			/* 0x900c */
	TiffHeader->fields[i].type = TIF_FLOAT;
	TiffHeader->fields[i].length = 1;
	memcpy(&TiffHeader->fields[i++].value,&info->black_level,sizeof(float));

	TiffHeader->fields[i].tag = DARK_CURRENT_TAG;			/* 0x900d */
	TiffHeader->fields[i].type = TIF_FLOAT;
	TiffHeader->fields[i].length = 1;
	memcpy(&TiffHeader->fields[i++].value,&info->dark_current,sizeof(float));

	TiffHeader->fields[i].tag = READ_NOISE_TAG;			/* 0x900e */
	TiffHeader->fields[i].type = TIF_FLOAT;
	TiffHeader->fields[i].length = 1;
	memcpy(&TiffHeader->fields[i++].value,&info->read_noise,sizeof(float));

	TiffHeader->fields[i].tag = DARK_CURRENT_NOISE_TAG;			/* 0x900f */
	TiffHeader->fields[i].type = TIF_FLOAT;
	TiffHeader->fields[i].length = 1;
	memcpy(&TiffHeader->fields[i++].value,&info->dark_current_noise,sizeof(float));

	TiffHeader->fields[i].tag = BEAM_MONITOR_TAG;			/* 0x9010 */
	TiffHeader->fields[i].type = TIF_FLOAT;
	TiffHeader->fields[i].length = 1;
	memcpy(&TiffHeader->fields[i++].value,&info->beam_monitor,sizeof(float));

	TiffHeader->fields[i].tag = USER_VARIABLES_TAG;		/* 0x9100 */
	TiffHeader->fields[i].type = TIF_LONG;
	TiffHeader->fields[i].length = NUM_USER_VARIABLES;
	TiffHeader->fields[i++].value = user_var_offset;

	if(i!=NUM_FIELDS){
		printf("Number if IFD fields does not match NUM_FIELDS");
		*header_size=-1;
		return(head);
	}

/* ----- x and y resolutions - it is recommended to set these even
though they are arbitrary */
	TiffHeader->xres[1] = 7;
	TiffHeader->yres[1] = 7;
	if(width>length){
		TiffHeader->xres[0] = width;
		TiffHeader->yres[0] = width;
	}else{
		TiffHeader->xres[0] = length;
		TiffHeader->yres[0] = length;
	}
		

	strcpy(TiffHeader->operator , info->operator);
	strcpy(TiffHeader->software_ver , SOFTWARE_VERSION);
	strcpy(TiffHeader->detector , info->detector);
	strcpy(TiffHeader->date , info->date);
//	if(ObjPtr->DataType==FloatData)			sprintf(TiffHeader->data_type_array,"FloatData");
//	else if(ObjPtr->DataType==ComplexData)		sprintf(TiffHeader->data_type_array,"ComplexData");
//	else if(ObjPtr->DataType==DistortionData)	sprintf(TiffHeader->data_type_array,"DistortionData");
//	else if(ObjPtr->DataType==IntensityData)	sprintf(TiffHeader->data_type_array,"IntensityData");
//	else									sprintf(TiffHeader->data_type_array,"IntegerData");
	memcpy(TiffHeader->user_variables , info->user_vars , NUM_USER_VARIABLES * 4 );
	if(descriptor_length>4){
		c_ptr = (char *)TiffHeader;
		c_ptr+= descriptor_offset;
		memcpy(c_ptr , info->descriptor , descriptor_length);
	}
	if(telemetry_length>4){
		c_ptr = (char *)TiffHeader;
		c_ptr+= telemetry_offset;
		memcpy(c_ptr , info->telemetry , telemetry_length);
	}
	if(title_length>4){
		c_ptr = (char *)TiffHeader;
		c_ptr+= title_offset;
		memcpy(c_ptr , info->title , title_length);
	}
	if(num_strips>1){
		bytes=0;
		for(i=0;i<num_strips;i++){
			info->strip_pointers[i]=*header_size+bytes;
			bytes+=info->strip_byte_counts[i];
		}
		c_ptr = (char *)TiffHeader;
		c_ptr+= strip_offset;
		memcpy(c_ptr , info->strip_pointers,info->num_strips*4);
		c_ptr = (char *)TiffHeader;
		c_ptr+= strip_size_offset;
		memcpy(c_ptr,info->strip_byte_counts,info->num_strips*4);
	}
	
	return(head);
}


tif_date(char *date)		/* produce tiff format date and time */
{
struct dosdate_t dateptr;
struct dostime_t timeptr;
	_dos_getdate(&dateptr);
	_dos_gettime(&timeptr);
	sprintf(date,"%4d:%2d:%2d %2d:%2d:%2d",
			dateptr.year,
			dateptr.month,
			dateptr.day,
			timeptr.hour,
			timeptr.minute,
			timeptr.second);
}
