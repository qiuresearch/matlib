/***********************************************************************
 *
 * Program: readmar 	Read an image in mar345 format.
 *
 * Copyright by:        Zhouhao Zeng
 *
 *
 * Version:     	1.0
 *
 *
 *
 *
 *
 *
 ***********************************************************************/

#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <math.h>
#include <ctype.h>
#include <string.h>
#include <time.h>
#include "mar300_header.h"
#include "mar345_header.h"
#include "mex.h"          /* -->This one is required for matlab */
#include "matrix.h"

#define VERSION 	3.0
#define FPOS(a) 	( (int)( a/8. + 0.875 )*64)
#define N		65535

char 			str		[1024];
char			byteswap	= 0;

FILE 			*fp;

int			nx, ny, no;
int            		*i4_image=NULL;

MAR300_HEADER		h300;
MAR345_HEADER		h345;

extern MAR345_HEADER    Getmar345Header();
extern MAR300_HEADER    Getmar300Header();
extern void readmar(char*);

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  char *fname = malloc(sizeof(char) * (mxGetN(prhs[0]) + 1));
  mxGetString(prhs[0], fname, mxGetN(prhs[0]) + 1);
  readmar(fname);
  plhs[0] = mxCreateNumericMatrix(1, nx*ny, mxINT32_CLASS, mxREAL);
  memcpy(mxGetPr(plhs[0]), i4_image, nx*ny*sizeof(int));
  free(i4_image);
}

/*==================================================================*/
void readmar(char *infile)
{
int 		i,j;
int		h1,iadd;
int		headi[2];
char		mar345=1;
double		avg=0.0, sig=0.0;
extern void	get_pck		();
extern void	    swapint32	();
extern void 	swapint16	();
int		*i4;
unsigned short	*i2_image, *i2;



	/* Open file */
	fp  = fopen(  infile,  "r" );

	/* Check if byte_swapping is necessary */
	fread( &h1, sizeof( int ), 1, fp);
	if ( h1 == 1234 ) {
		mar345   = 1;
		byteswap = 0;
	}
	else if ( h1 > 0 && h1<8000 ) {
		mar345 = 0;
		byteswap = 0;
	}
	else {
		byteswap = 1;
		swapint32( (char *)&h1, 1*sizeof(int) );
	}
	if ( byteswap ) {
		if ( h1 == 1234 ) {
			mar345 	= 1;
		}
		else if ( h1 > 10 && h1 <  5000  ) 
			mar345 = 0;
		else {
			printf("ERROR: Cannot swap first byte in header\n");
			exit(-1);
		}
	}

	if ( mar345 ) {
		h345 = Getmar345Header( fp );
		nx = h345.size;
		no = h345.high;
		if ( h345.pixels != nx*nx && h345.pixels > 0 ) {
			ny   = h345.pixels/nx;
		}
		else {
			ny = h345.size;
		}

	}
	else {
		h300 = Getmar300Header( fp );
		nx = h300.pixels_x;
		ny = h300.pixels_y;
		no = h300.high_pixels;
	}

	/* Allocate memory */
	i4_image = (int *)malloc( nx*ny*sizeof(int));
	memset( (char *)i4_image, 0, sizeof(int)*nx*ny );

	/* Read core of image into second half of i4_image array */
	i2_image= (unsigned short *)(i4_image+nx*ny/2);
	/* Go to first record */

	if ( mar345 ) {
		fseek( fp, 4096+FPOS(no), SEEK_SET );
		get_pck( fp, i2_image);
	}
	else {
		fseek( fp, nx+ny, SEEK_SET );
		i = fread( i2_image, sizeof( short ), nx*ny, fp );
		if ( i != nx*ny ) 
                       ;
		if (byteswap ) 
			swapint16(i2_image, nx*ny*sizeof(unsigned short));
	}

	/* Transform i2 array into i4 array */
	i4 = i4_image;
	i2 = i2_image;
	for ( i=0; i<nx*ny; i++, i2++, i4++ ) {
		*i4 = (int)*i2;
	}

	/* There are some high intensity values stored in the image */
	if ( no ) {
		/* Go to start of overflow record */
		i = fseek( fp, 4096,   SEEK_SET );

		/* 
		 * Read overflows. Read a pair of values ( strong ), where
		 * first  value = address of pixel in i4_image array
		 * second value = intensity of pixel (32-bit) 
		 * In order to save memory, we don't allocate a 32-bit array
		 * for all data, but a 16-bit array and an 8-bit array.
		 * The final intensity 24-bit intensity is stored as:
		 * 24-bit-value = 16-bit-value + (8-bit-value)*65535;
		 * Note: the maximum intensity the scanner may produce is 250.000
		 *       Beyond the saturation of the ADC, all saturated pixels
		 *       get an intensity of 999.999 !
		 */ 
		for(i=0;i<no; i++ ) {
			j = fread( headi, sizeof(int), 2, fp);

			if ( byteswap) 
				swapint32( headi, sizeof(int)*2 );

			iadd = headi[0];
			if ( iadd >= (nx*ny) || iadd < 0 ) continue;

			i4_image[iadd] = headi[1];
		}
	}

	/* Close input file */
	fclose( fp );
	i4 = i4_image;
	avg = sig = 0.0;
	for ( i=j=0; i<nx*ny; i++, i4++ ) {
		if ( *i4 < 1 || *i4 > 250000 ) continue;
		avg+=(*i4);
		sig+=((*i4)*(*i4) );
		j++;
	}
	if ( j > 1 ) {
		avg /= (float)j;
		sig = sqrt( ( sig - j*(avg*avg) ) / (double)(j-1) );
	}
}
