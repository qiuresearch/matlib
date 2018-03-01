%    convert_int16.m 
% Corrects a signed 16-bit TIFF image that was loaded into Matlab as an 
% unsigned 16-bit TIFF image.
% Returns the correct image as an array of doubles.
% Note, is not robust and must be given a uint16 input to work.

% Last editted 25 June, 2000 by Gil Toombes.

function val = convert_int16(x)

y = floor(double(x) ./ 32768);
val = double(x).* (1-y) + y .* (65536 - double(x));
