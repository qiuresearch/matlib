%  The portal to radial_integral() in Integral.c
%  Written on 21 June, 2000.
%  [q,I]=radial_integral(image,mask,x,r_min,r_max,Num_Bins,mode)
%  image is a M*N image of doubles.
%  mask is a uint8, M*N image.  
%  Where mask is zero, no integral is performed.
%  An integral is performed centred on the point x.
%  x need not lie within the image.
%  The integral can be performed in 3 modes.
%  No normalization, per pixel normalization and radial.
%  These are specified with 'none', 'pixel', 'radial'
%  If the mode is left out the default is per pixel.
%  The image is integrated to give Intensity, I versus radius, q.
%  The radii range from r_min to r_max with Num_Bins values.

% compiling is straightforward
%
% mex radial_integral.c

