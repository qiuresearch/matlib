/* Last editted June 21, 2000.*/
/* Statistical Dezingering Code.*/

#include "string.h"
#include "math.h"

int remove_zingers(
                   int num_images,
                   uint16 **data_ptrs,
                   double *dest,
                   int width,
                   int height,
                   long int bkg,
                   double sigma,
                   double sigma_cut,
                   double gain,
		   long int * num_zingers);
/* Performs statistical dezingering on the num_images images in data_ptrs.*/
/* For each pixel it finds the lower median of the images, Im.*/
/* The intensity should have a standard deviation about that of */
/*   sigma_point = sqrt(sigma*sigma+gain*max((Im-bkg),0))*/
/* remove_zingers excludes all points more than sigma_cut standard deviations*/
/* from the median and calculates the average of the remaining points.*/
/* In dest, it places the average*num_images (ie. the sum as if no zingers were*/
/* present).  */
/*  It also returns the number of zingers found in num_zing.*/
/*  Dependencies : compare_integers, max*/
/*  Preconditions :  1.  memory allocated to dest and images in data_ptrs.*/
/*                   2.  num_images >= 2.*/
/*                   3.  sigma, sigma_cut and gain > 0.*/
/*  Return value  :  0 if successful, -1 if not.*/

int get_noise_stats(
                   int num_images,
                   uint16 **data_ptrs,
                   int width,
                   int height,
                   long * bkg,
                   double * sigma,
                   double * gain,
		   int * condition);
/* Our error model says that noise is due to normal statistical sources, */
/* and zingers.  The normal noise for a pixel with mean intensity I is,*/
/*   sigma_point = sqrt( max((I-bkg),0)*gain +sigma*sigma )*/
/* This routine estimates bkg, sigma and gain.  To do so, it uses a heuristic */
/* set of initial conditions.  These may fail to converge to a sensible */
/* answer, or the error model may be inappropriate.  If get_noise_stats knows it*/
/* is in trouble, it will change the condition flag from zero.*/
/* To learn about the method of get_noise_stats read the tex file.*/
/* In particular, you may want to alter the guess parameters.*/

/* To estimage, bkg, sigma and gain, it uses the num_images in data_ptrs.*/
/* These images are of size width*height.*/
/* The result is returned in bkg, sigma, gain and condition.*/

/* Dependencies : get_noise_data(), compare_integers, compare_doubles, max, string.h*/
/* Preconditions :  1.  num_images>=2 and images in data_ptrs.*/
/* Return value :   0 if success.  -1 if failure.*/
/*                  condition flag = 0   ! get_noise_stats thinks things are okay.*/
/*                                   1  initial sigma estimate way off.*/
/*                                   2  refinement of sigma bad.*/
/*                                   3  gain way off.*/

/*  To tell zingers from the rest, we need to know bkg, gain and sigma.*/

/*  This is a heuristic algorithm to try to estimate these model parameters.*/
/*  It uses the num_images images in data_ptrs, each of size width*height. */

/*  Step 1 - Use generate_noise_data to make a sampling of intensity versus*/
/* variance.  Heuristic parameters.  */
/*   EXCLUDE_WIDTH = (def 0.05) ( Exclude pixels within 2.5% of vertical edges)*/
/*   EXCLUDE_HEIGHT = (def 0.05) (Dump pixels within 2.5% of horizontal edges) */
/*   SAMPLE_FRACTION = (def 0.1) (Only sample 10% of data points)*/

/*  Step 2 - Make a rough estimate of sigma and bkg.*/
/*  In most X-ray images, the signal near the beam is bright but the total */
/* area is dominated either by diffuse uniform scatter or no signal at all.*/
/*  Therefore the median of the Intensity should make a good approximation to */
/*  bak.*/
/*  Similarly, going out to the 64.3 percentile of the variance data should */
/*  give a reasonable approximation of sigma*sigma.  This presumes that the*/
/*  zingers and X-ray signal are a small part of total data.  If we exceed*/
/*  our reasonable parameters for these then condition flag is set to 1. */
/*  Heuristic parameters.*/
/*  SIGMA_MAX = (def 40)  Upper limit allowed on sigma estimate.  */
/*  SIGMA_MIN = (def 1) Minimum bound allowed on sigma estimate.*/

/*  Step 3 - Improve the estimate of sigma.  */
/*  Sigma is best estimated from pixels close to the background level.*/
/*  Take all values for which I is within SIGMA_BOUND*sigma of bkg and where*/
/*  sigma_point < SIGMA_CUT * sigma (ie.  not zingers).  Take the average*/
/*  variance of these points.  This should give a good estimate of sigma.*/
/*  If our first and second estimates of sigma differ by more than a factor*/
/*  of two then the condition flag is set to 2.*/
/*  Heuristic parameters.*/
/*  SIGMA_BOUND = (def 1.0) Range around bkg sampled.*/
/*  SIGMA_CUT = (def 5.0) Cutoff level to exclude zingers.*/
/*  Again, if sigma goes out of range it is pulled back to the defaults. */

/*  Step 4 - Estimate gain if possible.*/
/*  Pixels for which the median intensity is greater than */
/*  bkg+SIGMA_GAIN_LOW*sigma should have been the result of X-rays.  */
/*  We can again exclude points for with a variance bigger than SIGMA_CUT*/
/*  and start with an assumed gain of GAIN_MAX.  */
/*  A linear regression of variance versus Intensity to figure out the gain. */
/*  The gain should lie between GAIN_MIN and GAIN_MAX and will be forced into*/
/*  that range if the gain if regression fails, setting the conditon flag to*/
/*  3.  It is also possible that there will not be enough signal points to do*/
/*  a regression.  To do a regression requires at least MIN_DATA_FOR_REG points*/
/* In the case of a failure, the gain is ste to GAIN_MEAN.*/
/*  Heuristic parameters.*/
/*  SIGMA_GAIN_LOW = (def 2.0) (minimal Intensity that is caused by Xrays).*/
/*  GAIN_MIN = (def 0.1) (minimal value of gain.)*/
/*  GAIN_MAX = (def 1.0) (maximal value of gain.)*/
/*  GAIN_MEAN = (def 0.5) (mean value of gain.)*/
/*  MIN_DATA_FOR_REG = (def 10) (number of points for a linear regression.*/

/*  At this point, the routine is done as it has estimated bkg, sigma and gain.*/

int get_noise_data(
	           int num_images,
		   uint16 **data_ptrs,
		   int width,
		   int height,
		   double exclude_width,
		   double exclude_height,
		   double sample_fraction,
		   double ** Intensity,
		   double ** Variance,
		   long int * NPoints);

/* Analyses a sequence of num_images images stored in data_ptrs.  */
/* Each image is of size width*height.*/
/* The images are of the same object, so differences are due to noise.*/
/* Because of zingers, the average intensity is well calculated by taking*/
/* the lower median of values at that point.  These values are returned in*/
/* Intensity.*/
/* The variance of each point may be calculated from the multiple values */
/* measured there.  These values are returned in Variance.*/
/* All up, Npoints pixels are sampled.*/
/* The region to be sampled is defined as follows.*/
/* Any pixel to the left of x= exclude_width*0.5*width or to the right of*/
/* x=width*(1-0.5*exclude_width) is excluded.*/
/* Any pixel below y=exclude_height*0.5*height or above */
/* y=height*(1-0.5*exclude_height) is excluded.*/
/* Within this region, only a fraction sample_fraction of points will be counted.    */
/* Dependencies : None*/
/* Preconditions : 1.  num_images >=2*/
/*                 2.  0 <= exclude_width < 1.0*/
/*                 3.  0 <= exclude_height < 1.0*/
/*                 4.  0 <= sample_fraction*/
/* Return value :  0 if successful, -1 if failure.*/
  
/*  Compares two integers */
int compare_integers( const void *a, const void *b)
{
  int c;
  c= *((int *)a) - *((int *)b);
  return c;
}

/* Compares two doubles.*/
int compare_double( const void *a, const void *b)
{
  if ( *((double *)a) > *((double *)b) ) return 1;
  else if ( *((double *)b) > *((double *)a) ) return -1;
  else  return 0;
}

/* Return maximum of two values.*/
double max( double a, double b)
{  if (a>b) return a; else return b;}

int remove_zingers(
                   int num_images,
                   uint16 **data_ptrs,
                   double *dest,
                   int width,
                   int height,
                   long bkg,
                   double sigma,
                   double sigma_cut,
                   double gain,
		   long int * num_zingers)
{

  int * values; /* Sorting array.*/
  int median_index, index,ix,iy,i; /* Array indexes.*/
  int numerator; int  num_good; double weight; /* Averaging variables*/
  double highcut, lowcut ; /* cutoffs.*/
  double offset; /* Difference between median and mean.*/

  /* INITIALIZE MEMORY*/
  values = (int *)malloc(num_images*sizeof(int)); /* sorting array*/
  if (values == NULL) {                                                
   fprintf(stderr, "could not allocate memory for `values'\n");
   fprintf(stderr, "Error occured in function, remove_zingers\n");
   return(-1);
  }
  *num_zingers = 0;                    /* zinger count*/
  median_index = (num_images-1)/2;     /* index of median point*/
  if (num_images%2==0) { offset = 1.0/ (num_images-1.0);}
  else { offset = 0.0;} /* Figure out if median is low.*/

  /*  ANALYSE THE IMAGE POINT BY POINT*/
  for (iy=0;iy<height;iy++) {
    for (ix=0;ix<width;ix++) {
     
      /* Sort all the values at a given pixel.*/
      index = iy*width+ix; 
      for (i=0; i<num_images; i++)
        values[i] = (int)data_ptrs[i][index];
      qsort(values, num_images, sizeof(int), compare_integers);
         
      /* Set high and low cut-offs for zingers.*/
      lowcut = sqrt( sigma*sigma+ gain * max(values[median_index]-bkg,0) );
      highcut=values[median_index]+(sigma_cut+offset)*lowcut;
      lowcut=values[median_index]-(sigma_cut-offset)*lowcut;

      /* Average all non-zingers and count zingers.*/
      numerator=0;
      num_good=0;
      for(i=0; i<num_images; i++)
	{ if ((values[i]>lowcut)&&(values[i]<highcut))
            {
	      numerator += values[i];
              num_good++;  /* Not a zinger*/
            }
	  else
              *num_zingers = *num_zingers+1; /* Die zinger scum!*/
	}

      /* Correct average.*/
      weight = ((double) num_images) / num_good;
      dest[index] = (double) (numerator * weight);

    }   /* ..ix*/
  }     /* ..iy*/

  free(values);
  return 0;
}

int get_noise_stats(
                   int num_images,
                   uint16 **data_ptrs,
                   int width,
                   int height,
                   long * bkg,
                   double * sigma,
                   double * gain,
		   int * condition)
{

     /* Heuristic defaults*/
     double EXCLUDE_WIDTH = 0.05; /* Exclude points by 2.5% of vertical edges*/
     double EXCLUDE_HEIGHT = 0.05; /* Dump anything by 2.5% of horizontal edge */
     double SAMPLE_FRACTION = 0.1; /* Only sample 10% of data points*/

     double SIGMA_MAX = 40.0; /* Upper limit allowed on sigma estimate.  */
     double SIGMA_MIN = 1.0; /* Minimum bound allowed on sigma estimate.*/
     double SIGMA_BOUND = 1.0; /* Range around bkg sampled to guess sigma.*/
     double SIGMA_CUT = 5.0; /* Cutoff level to exclude zingers.*/
     double SIGMA_GAIN_LOW = 2.0; /* bkg+ this*sigma is an X-ray signal.*/

     double GAIN_MIN = 0.1; /* Minimum bound on gain*/
     double GAIN_MAX = 1.0; /* Maximal value of gain.*/
     double GAIN_MEAN = 0.5; /* Mean value of gain.*/
     long int MIN_DATA_FOR_REG = 10; /* number of datum for a linear regression.*/
   
     /* Calculation variables.*/
     double * Intensity=NULL; 
     double * Variance=NULL; 
     double *Temp=NULL;
     long int NPoints;
     long int Num,i;  /* loop variables*/
     int Ilower, Iupper; double variance_t; /* Used in step three*/
     double sum_xx, sum_x, sum_xy; /* Used in step four.*/
     
     *condition = 0; /* Nothing wrong yet.*/

     /* STEP ONE : SAMPLE IMAGES*/
     get_noise_data(num_images, data_ptrs, width, height, 
		    EXCLUDE_WIDTH, EXCLUDE_HEIGHT, SAMPLE_FRACTION,
		    &Intensity, &Variance, &NPoints);

     /* STEP TWO - ESTIMATE bkg AND sigma BY SORTING Intensity AND Variance.*/
     Temp = (double *)malloc(NPoints * sizeof(double));
     if (Temp==NULL) 
       {fprintf(stderr,"Error in get_noise_stats().\n");
        fprintf(stderr,"Couldn't allocate Temp.\n");
        *condition =0;
	free(Intensity); free(Variance);
        return -1;}

          /*  Do bkg first*/
          memcpy(Temp,Intensity,NPoints*sizeof(double));  	
          qsort(Temp,NPoints,sizeof(double),compare_double);     
	  *bkg = (long int)Temp[NPoints/2]; /* Pick of median intensity*/
   
	  /* Do sigma next*/
	  memcpy(Temp,Variance,NPoints*sizeof(double));  	
          qsort(Temp,NPoints,sizeof(double),compare_double);     
	  *sigma = (double)Temp[(int)(NPoints*0.6827)]; /* Go out to first std.*/
	  *sigma= sqrt(*sigma);
	  if (*sigma>SIGMA_MAX) {*sigma=SIGMA_MAX ; *condition = 1;}
	  if (*sigma<SIGMA_MIN) {*sigma=SIGMA_MIN ; *condition = 1;}
	
     /* STEP THREE - IMPROVE sigma estimate by only sampling background points.*/
	  Num=0; 
          Ilower = (int)(*bkg-*sigma - 1); Iupper= (int)(*bkg+ *sigma+ 1);
	  variance_t = SIGMA_CUT*SIGMA_CUT* (*sigma)* (*sigma);
 
       for(i=0;i<NPoints;i++) /* Find all legitimate background points*/
       if ( (Intensity[i]<Iupper) && (Intensity[i]>Ilower)
            && (Variance[i]<variance_t) )
	  { Temp[Num]=Variance[i]; Num++;}

       if (Num>0)  /* Get the average of the legitimate points*/
        {variance_t=0.0;for(i=0;i<Num;i++)variance_t+=Temp[i];
	variance_t=sqrt(variance_t/((double)Num));}
       else variance_t= 0.0 ;

       /* Check result is within bounds and consistent with rough estimate.*/
       if ( (variance_t>SIGMA_MAX)||(variance_t<SIGMA_MIN) )
         { variance_t = *sigma; if (*condition==0) *condition=2;}
       if (((2.0*variance_t< *sigma)||(variance_t > 2 * *sigma))&&(*condition==0)) *condition=2;

       /* Settle on sigma.*/
       *sigma = variance_t;

     /* STEP FOUR - IMPROVE GAIN ESTIMATE BY REGRESSION OF SIGNAL POINTS. */
       Num=0; sum_xx=sum_xy=sum_x=0;
	 Ilower=(int)((double)(*bkg)+ (*sigma) * SIGMA_GAIN_LOW);
	 for(i=0;i<NPoints;i++) /* Find legitimate signal points*/
	    if (Intensity[i]>Ilower) 
	      {
		variance_t = (*sigma)*(*sigma)+ GAIN_MEAN*(Intensity[i]-*bkg+*sigma);
		variance_t = SIGMA_CUT*SIGMA_CUT*variance_t;
		/* Make a rough estimate of maximum variance not by a zinger.*/
		/* Assume gain and that Intensity[i] is the mean (not true)*/
		
		if (Variance[i]<variance_t)  /* Valid point*/
		  { Num++;
		    sum_x+=Intensity[i];
		    sum_xx+=(Intensity[i]*Intensity[i]);
		    sum_xy+=(Variance[i]*Intensity[i]);
		  }  
	      }	 

	 /* Check we can do a regression*/
	 if ( (Num >= MIN_DATA_FOR_REG) && (sum_xx > ((*bkg) *sum_x) ) )
	   {
	     *gain = sum_xy - (*sigma) * (*sigma);
	     *gain = *gain / (sum_xx - *bkg * sum_x);
	   }
	 else
	   { if (*condition==0) *condition = 3; *gain = GAIN_MEAN;}

	 /* Make sure we didn't go outside bounds*/
	 if (*gain<GAIN_MIN) 
	   { if (*condition==0) *condition = 3; *gain=GAIN_MEAN; }
	 if (*gain>GAIN_MAX)
	   { if (*condition==0) *condition = 3; *gain=GAIN_MEAN; }

    /* CLEAN UP.*/
	 free(Intensity); free(Variance); free(Temp);
	 return 0;
}


int get_noise_data(
	           int num_images,
		   uint16 **data_ptrs,
		   int width,
		   int height,
		   double exclude_width,
		   double exclude_height,
		   double sample_fraction,
		   double ** Intensity,
		   double ** Variance,
                   long int * NPoints)
				  
{

  int * values; /* Sorting array.*/
  int median_index, index,i, j; /* Array indexes.*/
  int minx, rangex, miny, rangey; /* range of image sampling.*/
  int step_size  ; double temp;

  /* PREPARE MEMORY*/
  values = (int *)malloc(num_images*sizeof(int)); /* sorting array*/
  if (values == NULL) {                                                
   fprintf(stderr, "could not allocate memory for `values'\n");
   fprintf(stderr, "Error occured in function, get_noise_data()\n");
   return(-1);
  }
  median_index = (num_images-1)/2;     /* index of median point*/

  /* DEFINE THE SAMPLE SPACE AND MEMORY FOR SAMPLE.*/
  minx = (int)(width * 0.5 * exclude_width) ;
  rangex = width - 2*minx;
  miny = (int)(height * 0.5 * exclude_height);
  rangey = height - 2*miny;
  *NPoints = rangex * rangey;
  if ((sample_fraction<=1.0)&&(sample_fraction>0.0))
  step_size = (int)(1.0/sample_fraction);
  else step_size = 1;
  *NPoints= *NPoints/step_size;
  if (*NPoints<0) *NPoints = 0;
  *Intensity = (double *)malloc( *NPoints*sizeof(double));
       if (*Intensity == NULL) {                                               
             fprintf(stderr, "could not allocate memory for `Intensity'\n");
             fprintf(stderr, "Error occured in function, get_noise_data\n");
             free(values); return(-1);
             }
  *Variance = (double *)malloc( *NPoints*sizeof(double));
  if (*Variance == NULL) {                                                
             fprintf(stderr, "could not allocate memory for `Variance'\n");
             fprintf(stderr, "Error occured in function, get_noise_data\n");
             free(values); return(-1);
             }
 
 
  /*  SCAN SAMPLE SPACE*/
  for (i=0;i< *NPoints;i=i++)
    {
        index= ((i*step_size)%rangex+minx) + width*((i*step_size)/rangex + miny);

	/* Find the median value.*/
        for (j=0;j<num_images;j++)
	values[j] = (int)data_ptrs[j][index];
        qsort(values, num_images, sizeof(int), compare_integers);
	(*Intensity)[i]=(double)values[median_index];
	
	/* Find the variance.*/
	(*Variance)[i] = 0; temp=0;
	for (j=0;j<num_images;j++) temp+=data_ptrs[j][index];
        temp=temp/num_images;
	for (j=0;j<num_images;j++) 
         (*Variance)[i]+=(data_ptrs[j][index]-temp)*(data_ptrs[j][index]-temp);
	(*Variance)[i]=(*Variance)[i]/(num_images-1.0);  
    }    
 

  /* CLEAN UP AND GO HOME.*/
  free(values); return 0;
}














