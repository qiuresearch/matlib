#include "fcntl.h"
#include "tiff_reading.c"

void main(void)
{
  char filename[100] = "Float.tif" ;
  float * data ;
  int fpointer;
  int i, j;
  FILE *out;

  fpointer=open(filename,O_RDONLY);
  read_tiff_data(fpointer, &data);  
 
  close(fpointer);
  

  out = fopen("crud.txt", "w");
  for (i=0;i<384;i++)
    {
      for(j=0;j<542;j++) fprintf(out," %f ", *(data+ i*542 + j));
      
      fprintf(out,"\n");
    }

  fclose(out);
}
