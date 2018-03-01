function [mask] = automask_mar(im, xycen, varargin)
% --- Usage:
%        [avgdata, imgdata] = template(var)
%
% --- Purpose:
%
% --- Return(s): 
%
% --- Parameter(s):
%        var   - 
%
% --- Example(s):
%
% $Id: automask_mar.m,v 1.3 2014/06/17 18:14:49 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

pmargin = 1;

dead_center_radius = 15;   % in pixels
beam_stop_radius = 25;  % in pixels
[num_rows,num_cols] = size(im);
detector_radius = num_rows/2;
mask = ones(num_rows, num_cols, 'uint8');

parse_varargin(varargin);

% distances to detector center
[x, y] = meshgrid(1:num_cols, 1:num_rows);
x0=round(num_rows/2);
y0=round(num_cols/2);
radius = sqrt((x-x0).^2+(y-y0).^2);

% remove the small circle around detector center
mask(find(radius <= dead_center_radius)) = 0;

% remove the area beyond the image plate
mask(find(radius >= detector_radius-pmargin)) = 0;

if exist('xycen', 'var')
   % remove the area covered by beam stop
   radius = sqrt((x-xycen(1)).^2+(y-xycen(2)).^2);
   mask(find(radius <= beam_stop_radius)) = 0;
   
   % remove the bar holding the beam stop
   %   for i=linspace(0,1,100)*max(radius(:))
      % filter the image to minimize data noise effects
      % im = medfilt2(im, [3,3]);
      % my current idea is to first discretize all radius and theta
      % (e.g, 100 radius, 100 theata points), and then find the
      % theta at each constant radius with minnium intenstiy, then
      % mask out the pixels close to the theta value
      %   end
end

