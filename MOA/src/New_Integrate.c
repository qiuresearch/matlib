#include <math.h>
typedef unsigned char uint8;

/*int radial_integral( double * image, */  
       /*change int to void to prevent crashes*/
void working_radial_integral( double * image,
		     uint8 * mask,
		     int width,
		     int height,
		     double xcen,
		     double ycen,
		     double * q,
		     double * Intensity,
		     double r_min,
		     double r_max,
		     int Num_Bins,
		     int mode);
/* Takes the image in *image of size width*height and does a radial integral
   about the point (xcen, ycen).  Only pixels in the image for which *mask are
   non-zero are included.  The integral goes to in Num_Bin bins on the range 
   r_min to r_max, stored in *q and *Intensity.  There are three modes of 
   integration.  mode=0 gives per pixel normalization.  mode=1 gives a circular
   normalization and mode=2 gives no normalization.
  Returns 0 if everything goes as planned.  Returns -1 otherwise

   Preconditions :  
          1.  q and Intensity must both have been allocated memory.
          2.  r_max > r_min > 0.
          3.  Num_Bins >= 1. */

/*int radial_integral( double * image,*/
       /*change int to void to prevent crashes*/
void working_radial_integral( double * image,
		     uint8 * mask,
		     int width,
		     int height,
		     double xcen,
		     double ycen,
		     double * q,
		     double * Intensity,
		     double r_min,
		     double r_max,
		     int Num_Bins,
		     int mode)
{
 
    double * Ncounts = NULL ; /* number of counts in each bin. */
    double Weight; /* Fraction of a pixel lying in a particular bin. */
    double Bin_Size; /*  Width in pixels of each bin.*/
    int NWeights; /* Size of Weighting array.*/
  double pi=3.14159265;

  long int index, index_s; /* Image array indicies. */  
  double radius ; /* Distance of each point from centre. */
  int start_index, finish_index , iw; /* Weighting indicies. */
  double rbot, rtop; /* Temporary calculation variables for Weighting */

  /* INITIALIZE BINSIZE AND MEMORY FOR BINNING. */
  Ncounts = (double *)calloc(Num_Bins, sizeof(double));
  if (Ncounts==NULL) 
    {fprintf(stderr,"Memory allocation problem in radial_integral().\n");
     fprintf(stderr,"This is a problem in Integrate.c\n.");
     fprintf(stderr,"Exciting function without completing work.\n");
     /*return -1;}*/
    }  /*remove return when changing function to return void*/
  Bin_Size=(r_max-r_min)/((double)Num_Bins);
  NWeights= (int)(1.0/Bin_Size) + 2; /* A pixel could overlap this many bins. */

  /* INITIALIZE Q AND INTENSITY MATRICES */
  for (index=0;index<Num_Bins;index++)
  {
    q[index]= ((index+0.5)*Bin_Size) + r_min; 
    Intensity[index]=0.0;
  }

  /* SCAN IMAGE PIXEL BY PIXEL AND ADD TO BINS */
  index_s=width*height;for(index=0;index<index_s;index++)
  {if (mask[index]>0) /* pixel is inside desired region. */
      {
	  /* Figure out bins pixel may contribute to. */
        radius = sqrt( (index%width+0.5-xcen)*(index%width+0.5-xcen)
                       +(index/width+0.5-ycen)*(index/width+0.5-ycen) );	 
        start_index = (int)( (radius-0.5-r_min)/Bin_Size);
        finish_index = start_index + NWeights;
	if (start_index<0) start_index=0; 
	if (finish_index>Num_Bins) finish_index=Num_Bins;

	/* Run through the bins */
        for(iw=start_index;iw<finish_index;iw++) 
            {
		/* Figure out the part of the pixel lying in bin (iw). */
	      rbot=iw*Bin_Size+r_min-radius;
	      rtop=rbot+Bin_Size;
	      if (rbot<-0.5) rbot= -0.5; else if (rbot>0.5) rbot=0.5;
	      if (rtop<-0.5) rtop= -0.5; else if (rtop>0.5) rtop=0.5;
	      Weight = rtop-rbot;

	      Intensity[iw] += Weight*image[index];
	      Ncounts[iw] += Weight;
	    }  
      }
  }

  /* PERFORM NORMALIZATION */
  if (mode==0)  /* Per Pixel Normalization */
    { 
      for (iw=0;iw<Num_Bins;iw++) 
	     { if (Ncounts[iw]>0.5*Bin_Size) 
                      Intensity[iw]=Intensity[iw]/Ncounts[iw];
	       else Intensity[iw] = 0.0;}        
    }
 
  if (mode==1) /* Absolute Normalization. */
    {
      for (iw=0;iw<Num_Bins;iw++)
	     { if (Ncounts[iw]>0.5*Bin_Size)
	       Intensity[iw]=Intensity[iw]*2.0*pi*q[iw]/Ncounts[iw];
	       else Intensity[iw]=0.0;
             }   
    }

  /* All other modes produce no normalization. */

  /* CLEAN UP AND RETURN */
  free(Ncounts); 
  /*return 0;*/ /*remove return when changing function to return void*/
}





