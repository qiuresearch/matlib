// Last editted July 15, 2000 by Gil Toombes

// Clunky little test package to try out read_tiff_header() in tiff_reading.c

#include "fcntl.h"
#include "tiff_reading.c"

void main(void)
{
  char filename[100]="Float.tif";
  struct image_info header;
  int fpointer;
  
  fpointer=open(filename,O_RDONLY);
  read_tiff_header(fpointer, &header);  
  print_tiff_header(stdout,header);

  close(fpointer);

}
