/*Fake_Integrate.c is written to substitute Integrate.c code invoked by radial_integral.c while I'm debugging it so that I can figure out why it crashes (either segfaulting, or bringing down MATLAB entirely).*/

typedef unsigned char uint8;

void fake_radial_integral( double * image,
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

void fake_radial_integral( double * image,
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
  Intensity[0]=9;
  Intensity[1]=10;
  Intensity[2]=11;
  Intensity[3]=12;
  Intensity[4]=11;
  Intensity[5]=10000;
  Intensity[6]=11000;
  Intensity[7]=500000;
  Intensity[8]=12;
  Intensity[9]=11;
  

  q[0]=0;
  q[1]=1;
  q[2]=2;
  q[3]=3;
  q[4]=4;
  q[5]=0;
  q[6]=1;
  q[7]=2;
  q[8]=3;
  q[9]=4;

}
