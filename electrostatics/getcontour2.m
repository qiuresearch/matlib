function [xy_u, xy_l] = getcontour2(x, y, x_grid, varargin)
% --- Usage:
%        [xy_u, xy_l] = getcontour1(x, y, x_grid, varargin)
% --- Purpose:
%        this routine aims to find the contour of a 2D data with the x
%        resolution of x_grid. For example, at a given x, what is the
%        highest y (xy_u) and lowest y (xy_l).
% --- Parameter(s):
%        x - a vector giving the x coordinates, needs to be
%            sorted, e.g., 1 1 1 2 2 3 3 3 3 
%        y - the corresponding y values to x
%        x_grid - x values must be grouped into finite number of
%                 grid. This is the width.
% --- Return(s):
%        xy_u - the (x,y) coordinates of the upper contour
%        xy_l - the (x,y) coordinates of the lower contour
% --- Example(s):
%
% $Id: getcontour2.m,v 1.1 2013/08/17 17:00:50 xqiu Exp $
%

if ~exist('x_grid', 'var')
   x_grid = (x(end) - x(1))/100;
end

% find the index in the discretized array
index = fix((x-x(1))/x_grid) + 1;
i_newentry = [1,find((index(2:end)-index(1:end-1)) ~= 0)+1, length(index)+1];

% get the upper and lower boundaries
i_bd=0;
for i=1:length(i_newentry)-1;
   i_bd = i_bd+1;
   [xy_u(i_bd,2), i_max] = max(y(i_newentry(i): i_newentry(i+1)-1));
   xy_u(i_bd,1) = x(i_newentry(i)+i_max-1);
   [xy_l(i_bd,2), i_min] = min(y(i_newentry(i): i_newentry(i+1)-1));
   xy_l(i_bd,1) = x(i_newentry(i)+i_min-1);
end
