// Last editted July 15, 2000 by Gil Toombes
// Small subsection of TV6SYS.pro which includes only tiff loading routines.



/********************************* TIFF_IN.C *********************************/

read_compress_image(struct object_descriptor *, char *);
		// read_compress_image() ---- decompresses entire LZW tiff image into memory

int read_diskimage(struct object_descriptor *,unsigned long,unsigned long,char *);
		// read_diskimage() ---- reads arbitrary portion of uncompressed tiff image into memory

int get_im_head(struct object_descriptor *);
		// get_im_head() ---- resolves disk file tiff header and fills object_descriptor and memory header

time_t tif_date_to_int(char *);
		// tif_date_to_int() ---- converts tiff ascii date yyyy:mm:dd hh:mm:ss to integer

/********************************* LZW3.C ************************************/

int LZWPreDecode(struct object_descriptor *,long);
		// LZWPreDecode() ---- sets up decompression routines

int LZWDecode(struct object_descriptor *,char *,char *,long);
		// LZWDecode() ---- handles the main part of image decompression

void LZWCleanup(struct object_descriptor *);
		// LZWCleanup() ---- frees temporary space use by LZW routines

int LZWPreEncode(struct object_descriptor *,long);
		// LZWPreEncode() ---- sets up LZW compression

int LZWEncode(struct object_descriptor *,char *,long);
		// LZWEncode() ---- main part of compression routines

int LZWPostEncode(struct object_descriptor *,long *);
		// LZWPostEncode() ---- finishes up LZW compression





