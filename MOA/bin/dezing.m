% dezing.m - multiple image automatic dezingerer.
%  function [z, Nzing] = dezing(image)
% image is a set of notionally identical images so that image(:,:,1) is the 
% first image, imag(:,:,2) is the second image, image(:,:,3) is the third and
% so on.  Each image must be of data type, uint16.
% These images are added together and placed in z, a matrix of doubles.
% Zingers are excluded using get_noise_stats and remove_zingers.
% The number of zingers is reported in Nzing

function [z, Nzing] = dezing(image)
sigma_cut=5.0; % Exclude zingers 5 standard deviations from the median.

[bkg,sigma,gain]=get_noise_stats(image);
[z,Nzing] = remove_zingers(image,bkg,sigma,sigma_cut,gain);
