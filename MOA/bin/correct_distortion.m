%  The portal to correct_distortion() in CCD_Correction.c
%  Written on 22 June, 2000.
%  dest = correct_distortion(image, x_map, y_map);
%  image is a M*N image of doubles. 
%  dest is a M*N image of doubles and the output.
%  x_map and y_map are M*N single arrays.
%  For the i,j-th pixel, the actual location is (x_map(i,j),y_map(i,j))
%  correct_distortion redistributes all the intensities to straighten
%  out the image.
%  Normal image processing should be,
%	  a) dezingering   b)  intensity correction  c)  distortion correction
%  Note algorithm is lossy.  

function dest = correct_distortion(image,x_map, y_map)

  dest = correct_displacement_double(double(image),double(x_map),double(y_map));
