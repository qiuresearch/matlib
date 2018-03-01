// Last edited 19 June, 2000 by Gil Toombes.

// CCD correction routines for Tate-Gruner CCD Detectors.
// The intensity and spatial distortion of the CCD must be corrected for on a given
// image.

// Intensity correction.
//      The efficiency of each pixel on the detector differs.
//      These efficiencies can be measured and recorded in an array of M*N floating
//      point numbers where M*N is the size of the image.
//      correct_intensity() uses this array to remove intensity errors from images.
//      You pass it the correction file of intensities, intensity_map,  
//      along with the image you want to correct, image.  For each point (i,j) on 
//      the image, result(i,j) = image(i,j)*intensity_map(i,j).

// Spatial correction.
//      Each pixel on the detector, i,j, is located in real space at 
//      x_map(i,j), y_map(i,j) where x_map and y_map are matrices storing the 
//      distortion of the detector.  
//      Correcting for this is more arbitrary.
//      The accepted trick is as follows.
//      Figure out the nearest pixel in the final image.  Work out weighting
//      functions for the 9 pixels in its immediate neighbourhood so they add to 1.
//      Distribute the value of the point to those pixels.

// Distortion files.
//      Distortion files for the Gruner CCD Detectors consist of M*N arrays of 
//      real numbers.  These are stored in tiff format as floating numbers.  

// Original Code
//      TV6 file CORRECT.C file. June, 2000.
 
int correct_intensity(double *result, double *image, float *intensity_map, 
                      int width, int length);
// Takes the image in "image" and intensity correction map in "intensity_map", both of width
// "width" and length "length".
// Each pixel in "image" is multiplied by the scale factor in "intensity_map" and stored in 
// result.
// If successful returns 0 and returns -1 otherwise.

int correct_distortion(double * result, double * image, float *x_map, float *y_map,
		       int width, int length);
// Takes the image in "image" of size width*length.  
// The point i,j in the raw image is mapped to the point x_map[i][j],y_map[i][j]
// The value of the pixel i,j is shared amongst the 9 neighbours in the final
// image, "result".
// returns 0 on success.

int correct_distortion(double * result, double * image, float *x_map, float *y_map
		       , int width, int length)
// Takes the image in "image" of size width*length.  
// The point i,j in the image is mapped to the point x_map[i][j],y_map[i][j]
// The value of the pixel i,j is shared amongst the 9 neighbours in the final
// image, "result".

{  int i, j ;  // Pixel position.
   double x,y ;  // Location Pixel i,j is mapped to.
   int x1, y1 ; // Nearest Integer point to x,y 
   double xwid, ywid ; // Area of Pixel is xwid*ywid.
   double col[3], row[3]; // Weighting of neighbouring pixels. 
   int k,l ; // loop variables   

   // Initialize result to zero.
   for(i=0;i<width;i++)for(j=0;j<length;j++) result[j*width+i]=0.0; 

	   // Scan over all pixels.
   // The memory location of the pixel at (x,y)=(i,j) is j*width+i.   
   for(i=0;i<width;i++)for(j=0;j<length;j++)
     {

                // Locate pixel
                x = x_map[j*width+i];
                y = y_map[j*width+i];
                x1= (int)(x+0.5);
                y1= (int)(y+0.5);

		if (x>-1000.0) // This is a valid pixel
                {
 
                // Determine size of pixel
                if (i>0) xwid = x-x_map[j*width+i-1];
                else xwid = x_map[j*width+i+1]-x;
                if (j>0) ywid = y-y_map[(j-1)*width+i];
                else ywid = y_map[(j+1)*width+i]-y;
		if (ywid>5.0 || xwid >5.0 ) {xwid=1.0;ywid=1.0;}
		xwid=1.0/xwid; ywid=1.0/ywid;

                // Assign the weighting functions for neighbouring pixels.
		if ((col[0]=0.5-(x-x1+0.5)*xwid)<0) col[0]=0.0;	
		if ((col[2]=0.5+(x-x1-0.5)*xwid)<0) col[2]=0.0;
		col[1]=1.0-col[0]-col[2];
		if ((row[0]=0.5-(y-y1+0.5)*ywid)<0) row[0]=0.0;
                if ((row[2]=0.5+(y-y1-0.5)*ywid)<0) row[2]=0.0;
		row[1]=1.0-row[0]-row[2];
		
		// Put contributions into neighbouring pixels.
		for(k=0;k<3;k++)for(l=0;l<3;l++)
		 if (  ((x1+k-1) >= 0) && ((x1+k-1) <= width) &&
                       ((y1+l-1) >=0) && ((y1+l-1) <= length) )                     
                  {
		    // The pixel is inside bounds.
                      result[ (y1+l-1)*width + (x1+k-1)] += 
                            image[j*width+i]*row[l]*col[k];
		  }
		}
     }
  return 0;
}

int correct_intensity(double *result, double *image, float *intensity_map, 
                      int width, int length)
// Takes the image in "image" and intensity correction map in "intensity_map", both of width
// "width" and length "length".
// Each pixel in "image" is multiplied by the scale factor in "intensity_map" and stored in 
// result.
// If successful returns 0 and returns -1 otherwise.
{
  int i; long int range; 
  range = width*length;

  for(i=0;i<range;i++) result[i] = image[i]*intensity_map[i]; 
  return 0;
}
























