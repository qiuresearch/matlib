function [Y_cen, X_cen] = imageplate_guess_center(im, varargin);

% based on the fact that it is mostly isotropic

verbose = 1;
deviation = 0.15;
parse_varargin(varargin);

% 1) look for the maximum

[intensity, index] = max(im(:));
[numofx, numofy] =  size(im);

[Y_cen X_cen] = ind2sub([numofx, numofy], index);

% check whether it's too far away from the image center

if ((X_cen-numofx/2)/numofx > 0.1) || ((Y_cen-numofy/2)/numofy > 0.1)
   showinfo('beam center is too far from the middle, use middle instead');
   X_cen = round(numofx/2);
   Y_cen = round(numofy/2);
end
