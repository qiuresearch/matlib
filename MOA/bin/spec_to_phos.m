%  function s = spec_to_phos( ring_order, radii, d_spacing, lambda)
% 
%  Hacky function for find the specimen to phosphorous distance from a spherical
%  calibrant.
%  You use a laminar calibrant to find the image centre and measured the 
%  radii of the rings as a function of ring_order.
%  ring_order is a column vector of the order of each of the N rings you measured.
%  radii is a column vector of the N radii.
%  d_spacing is d-spacing of your laminar calibrant in Angstroms.
%  lambda is the X-ray wavelength used.
%
%  The function returns in s, the value for the specimen to phosphorous distance
% calculated from each ring.
%
%  Note, you can fit the rings on your I versus q plot using the function, Find_Peak

function s = spec_to_phos( ring_order, radii, d_spacing, lambda)

s = radii ./ tan( 2.0* asin( 0.5*ring_order*lambda/d_spacing ) );



