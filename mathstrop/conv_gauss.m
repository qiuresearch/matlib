function result = conv_gauss(y, width_gauss)
%        result = conv_gauss(y, width_gauss)
% --- Purpose:
%    convolute the data (the x values are assumed to start from
%    zero) with a zero-centered Gaussian curve.
%
% --- Parameter(s):
%              y - the data y values (assume the x starting from
%                  0!!!).
%    width_gauss - FWHM of the Gaussin in unit of number of
%                  points. It is set up this way because x values
%                  are not passed into the parameter. 
%
% --- Return(s): 
%        results - the convoluted y values of the SAME size.
%
% --- Calling Method(s):
%
% --- Example(s):
%
% $Id: conv_gauss.m,v 1.1 2013/08/17 13:52:28 xqiu Exp $
%

% 1) Simple check on input parameters

if (nargin < 1)
  error('an array must be passed for convolution!');
  help conv_gauss
  return
end
num_ys = length(y);  % calculated only once to save time

if (nargin < 2)
  width_gauss = num_ys/10.0;
end

% 2) Calculate the Gaussian vector

num_points = 5.0*width_gauss;
gauss_vect = exp(-0.5/width_gauss/width_gauss*(0:num_points).^2);
gauss_vect(:) = gauss_vect/(2.0*sum(gauss_vect)); % normalize it to 0.5

% 3) Convolute the data. 
%    note: the conv() can only do backward convolutio, thus we have
%    to do it twice, and then average them. 

result = conv(y, gauss_vect);
dummy = conv(y(num_ys:-1:1), gauss_vect);

result = result(1:num_ys) + dummy(num_ys:-1:1);
