% pixel_to_q.m - converts integration range.
%  function [q]=pixel_to_q(r,s, lambda);
%  r is a vector of radii in pixels.
%  s is the Spec_to_Phos in pixels.
%  lambda is the optional X-ray wavelength in Angstrom.
%  q is the q-value for each radii.

function [q] = pixel_to_q(r,s,lambda)

 q = (4*pi/lambda)*sin (0.5 * atan(r / s));
 
