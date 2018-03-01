%  function [mean, minimum, maximum] = roi(imag, range)
%
%  lets the user pick a polygon of the imag and returns maximum, minimum and mean values
%  in that polygon.
%  recursively does this until the right mouse button is pressed.
%  If range is specified then each time the image is displayed range is used.
%  On exiting returns the mean, minimum and maximum for each polygon selected.
%
%  Dependencies - axes2pix.m, intline.m, roipoly_mod1.m, show.m

function [mean, minimum, maximum] = roi(imag, range)

% Set the range by hand if no range given.
if (nargin==1) 
   range = 0;
   range(1)=double(min(min(imag)));
   range(2)=double(max(max(imag)));
end

% Initialize and tell the user what to do
fprintf(1,'\nPick a polygon using the left mouse button.\n');
fprintf(1,'When a polygon is finished click with the right button.\n');
fprintf(1,'To exit roi(), on a fresh imag just click the right button.\n\n');
Region = double(roipoly_mod1(imag,range));
pixels_in = sum(sum(double(Region)));
bottom = min(min(imag));
top = max(max(imag));
k=1;

% Keep going_until user stops selecting polygons.
while( pixels_in > 0)
   
   % Save the maximum, minimum and mean of that polygon and report it.
   max_imag = imag .* Region + (1-Region) * bottom;
   min_imag = imag .* Region + (1-Region) * top;
   sum_imag = imag .* Region;   
   maximum(k)=max(max(max_imag));
   minimum(k)=min(min(min_imag));
   mean(k)= sum(sum(sum_imag))/ pixels_in;
   fprintf(1,'Mean = %f, Maximum = %f, Minimum = %f\n', mean(k), maximum(k), minimum(k)); 
   k=k+1;
   
   % Get the next polygon
   Region = double(roipoly_mod1(imag,range));
   pixels_in = sum(sum(double(Region)));
   
end
