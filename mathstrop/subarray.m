function data =subarray(data, dmin, dmax, column)
% --- Usage:
%        data =subarray(data, dmin, dmax, column)
%
% --- Purpose:
%        extract a subset of an array based on the "min" and "max"
%        values of the "column"
%
% --- Parameter(s):
%        var   - 
%
% --- Return(s): 
%
% --- Example(s):
%
% $Id: subarray.m,v 1.1 2013/08/17 17:05:36 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   error('at least one parameter is required, please see the usage! ')
end

if ~exist('column', 'var') || isempty(column)
   column = 1;
end
if ~exist('dmax', 'var') || isempty(dmax)
   dmax = data(end,column);
end
if ~exist('dmin', 'var') || isempty(dmin)
   dmin = data(1,column);
end

imin = locate(data(:,column), dmin);
imax = locate(data(:,column), dmax);

data = data(imin:imax,:);
