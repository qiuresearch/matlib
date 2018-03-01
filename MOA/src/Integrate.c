/* 10/31/2005, modified by Xiangyun Qiu.  

   I added one more returned varible: Num_Pixels, for future error
   propagation. The previous variable Nbins was replaced.

   12/10/2005, modified by Xiangyun Qiu again to add the uncertainty
   of each integrated point.

   11/06/2006, checked by Xiangyun. Modified a little the calculation
   of the uncertainties.

*/

#include <math.h>
typedef unsigned char uint8;

/*int radial_integral( double * image, */  
       /*change int to void to prevent crashes*/
void radial_integral( double * image,
		      uint8 * mask,
		      int width,
		      int height,
		      double xcen,
		      double ycen,
		      double * q,
		      double * Intensity,
		      double * Num_Pixels,
		      double * Delta_Int,
		      double r_min,
		      double r_max,
		      int Num_Bins,
		      int mode);
/* Takes the image in *image of size width*height and does a radial
   integral about the point (xcen, ycen).  Only pixels in the image
   for which *mask are non-zero are included.  The integral goes to in
   Num_Bin bins on the range r_min to r_max, stored in *q and
   *Intensity.  There are three modes of normalization.  mode=0 gives
   per pixel normalization.  mode=1 gives a circular normalization and
   mode=2 gives no normalization.  Returns 0 if everything goes as
   planned.  Returns -1 otherwise

   Preconditions :  
          1.  q and Intensity must both have been allocated memory.
          2.  r_max > r_min > 0.
          3.  Num_Bins >= 1. */

/*int radial_integral( double * image,*/
       /*change int to void to prevent crashes*/
void radial_integral( double * image,
		      uint8 * mask,
		      int width,
		      int height,
		      double xcen,
		      double ycen,
		      double * q,
		      double * Intensity,
		      double * Num_Pixels,
		      double * Delta_Int,
		      double r_min,
		      double r_max,
		      int Num_Bins,
		      int mode )
{
  /* Note that r_min, r_max, etc.. are in unit of number of pixels */
  double Weight; /* Fraction of a pixel lying in a particular bin. */
  double Bin_Size; /*  Width in pixels of each bin. */
  int NWeights; /* Size of Weighting array. */
  double pi=3.14159265;
  
  long int index, index_s; /* Image array indicies. */  
  double radius ; /* Distance of each point from centre. */
  int start_index, finish_index , iw; /* Weighting indicies. */
  double rbot, rtop; /* Temporary calculation variables for Weighting */

  Bin_Size=(r_max-r_min)/((double)Num_Bins);
  NWeights= (int)(1.0/Bin_Size) + 2; /* A pixel could overlap this many bins.*/
  
  /* INITIALIZE Q AND INTENSITY MATRICES */
  for (index=0;index<Num_Bins;index++) {
    q[index]= ((index+0.5)*Bin_Size) + r_min; 
    Intensity[index]=0.0;
    Num_Pixels[index]=0.0;
    Delta_Int[index]=0.0;
  }
  
  /* SCAN IMAGE PIXEL BY PIXEL AND ADD TO BINS */
  index_s=width*height;
  for(index=0;index<index_s;index++) {
    if (mask[index]>0) { /* pixel is inside desired region. */
      /* Figure out bins pixel may contribute to. */
      radius = sqrt( (index%width+0.5-xcen)*(index%width+0.5-xcen)
		     +(index/width+0.5-ycen)*(index/width+0.5-ycen) );
      start_index = (int)( (radius-0.5-r_min)/Bin_Size );
      finish_index = start_index + NWeights;
      if (start_index<0) start_index=0;
      if (finish_index>Num_Bins) finish_index=Num_Bins;
      
      /* Run through the bins */
      for(iw=start_index;iw<finish_index;iw++) {
	/* Figure out the part of the pixel lying in bin (iw). */
	rbot=iw*Bin_Size+r_min-radius;
	rtop=rbot+Bin_Size;
	if (rbot<-0.5) rbot= -0.5; else if (rbot>0.5) rbot=0.5;
	if (rtop<-0.5) rtop= -0.5; else if (rtop>0.5) rtop=0.5;
	Weight = rtop-rbot;
	
	Intensity[iw] += Weight*image[index];
	Num_Pixels[iw] += Weight;
	Delta_Int[iw] += Weight*image[index]*image[index];
      }  
    }
  }
  
  /* Calculate the biased weighted standard deviation (on-the-fly method)*/
  /* Following: http://en.wikipedia.org/wiki/Mean_square_weighted_deviation*/
  for (index=0;index<Num_Bins;index++) {
    if (Num_Pixels[index] == 0) continue;
    if (Num_Pixels[index] == 1) {
      Delta_Int[index] = sqrt(Delta_Int[index]-Intensity[index]*Intensity[index]);
      continue;
    }
    Delta_Int[index] = sqrt(Delta_Int[index]*Num_Pixels[index]-Intensity[index]*Intensity[index])/Num_Pixels[index];
  }

  /* PERFORM NORMALIZATION */
  if (mode==0) { /* Per Pixel Normalization */
    for (iw=0;iw<Num_Bins;iw++) { 
      if (Num_Pixels[iw]>0.5*Bin_Size) {
	Intensity[iw]=Intensity[iw]/Num_Pixels[iw];
	Delta_Int[iw]=Delta_Int[iw]/Num_Pixels[iw]; 
      }
      else {
	Intensity[iw] = 0.0;
	Delta_Int[iw] = 0.0;
      }
    }      
  }
  
  if (mode==1) { /* Absolute Normalization. */ /* I don't understand this */
    for (iw=0;iw<Num_Bins;iw++) {
      if (Num_Pixels[iw]>0.5*Bin_Size)
	Intensity[iw]=Intensity[iw]*2.0*pi*q[iw]/Num_Pixels[iw];
      else Intensity[iw]=0.0;
    }   
  }
  
  /* All other modes produce no normalization. */
  
  /*return 0;*/ /*remove return when changing function to return void*/
}

