function xyzline = line_gen(xyz0, xyz1, num_points)
% --- Usage:
%        xyline = line_gen(xy0, xy1, num_points)
% --- Purpose:
%
% --- Parameter(s):
%
% --- Return(s):
%        results -
%
% --- Example(s):
%
% $Id: line_gen.m,v 1.1 2013/08/17 17:00:50 xqiu Exp $
%

% 1) Simple check on input parameters
xyzline = [];

if nargin < 3
   help line_gen
   return
end

num_dims = length(xyz0);
if (num_dims ~= length(xyz1)) 
   disp('ERROR:: the two points given have DIFFERENT dimensions!')
   return
end
if (length(num_points) ~= 1)
   disp('ERROR:: number of points MUST be a scalar!');
   return
end

% 2)

xyzline = zeros(num_dims, num_points);

for idim=1:num_dims
   xyzline(idim, :) = linspace(xyz0(idim), xyz1(idim), num_points);
end

