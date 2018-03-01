%  The portal to correct_intensity() in CCD_Correction.c
%  Written on 22 June, 2000.
%  dest = correct_distortion(image, intensity_map);
%  image is a M*N image of doubles. 
%  dest is a M*N image of doubles and the output.
%  intensity_map is a M*N single arrays.
%  For the i,j-th pixel, the corrected intensity is 
%      image(i,j)*intensity(i,j)
%  Normal image processing should be,
%	  a) dezingering   b)  intensity correction  c)  distortion correction

function dest = correct_intensity(image, intensity_map)
   
	dest = double(image) .* double(intensity_map);
        