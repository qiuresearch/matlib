// A really hacky way to convert floating point tiffs into arrays of floating 
// point numbers for import into matlab.

// Written 22 June, 2000.  Not extensively tested.

#include "load_float_tiff.c"

int main(void)
{
  char input[100];
  char output[100];

  float *image; int width, height; int i, j;
  FILE *out;

  printf("Welcome to Gil's hacky Floating-Point tiff to Ascii file convertor\n");
  printf("First please give me the filename of the Floating Point tiff\n");
  fscanf(stdin,"%99s",input);
  printf("Next give me the filename you want me to write the Floating Point tiff to.\n");
  fscanf(stdin,"%99s", output);
  
  printf("Okay.  Because I like you, I'll convert %s", input);
  printf(", which is a floating point tiff\n");
  printf("written by TV6 into an ascii file of numbers in %s.\n",output);
  printf("The rows of the image will become the rows of the text file.\n");

  // Load it in.
  load_float_tiff(input, &image, &width, &height);
 
  // Print it out
  out = fopen(output,"w");
  if (out==NULL) { printf("\n I HATE LIFE AND YOUR OUTPUT FILENAME STINKS.");
                   return -1;}
  for (i=0;i<width;i++)
    {
      for (j=0;j<height;j++) 
	fprintf(out,"%10lf  ", (double)image[i+j*width]);
      fprintf(out,"\n");      
    }

  // Close up
  fclose(out);
  free(image);

}


