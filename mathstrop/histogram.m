function [index, result] = histogram(x, x_range, num_bins)
% --- Usage:
%        [index, result] = histogram(x, x_range, num_bins)
% --- Purpose:
%        quantize the value of "x" into "num_bins" of grids. The
%        index of each element is returned. 
%
% --- Parameter(s):
%        x   - one dimensional data array
%        x_range - two element array to specify the bin limits
%        num_bins - specify number of bins
%
% --- Return(s): 
%        index - the index to the bins of each element in "x"
%        result - the number of elements in each bin
%
% --- Example(s):
%
% $Id: histogram.m,v 1.1 2013/08/17 17:00:50 xqiu Exp $
%

% 1) Simple check on input parameters

num_points = length(x(:));
if (nargin <=1)
  x_range = [min(x), max(x)];
end

if (nargin <=2)
  num_bins = 700;
end

% 2) Find out the width of each bin, use it to quantize the array

width_bin = (x_range(2)-x_range(1))/num_bins;
index = ceil((width_bin*0.5 - x_range(1) + x(:))/width_bin);
index(index(:) < 1) = 1;     % handle special cases: out of range!!!
index(index(:) > num_bins) = num_bins;

% 3) Head count if necessary
if (nargout == 2)
  result = zeros(num_bins,1);
  for i_point=1:num_points
    result(index(i_point)) = result(index(i_point)) + 1;
  end
end
