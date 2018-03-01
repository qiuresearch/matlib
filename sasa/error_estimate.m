function err = error_estimate(data, npoly, width)
% --- Usage:
%        err = error_estimate(data, npoly, width)
% --- Purpose:
%        estimate the error of each point of a curve by polynomial
%        fitting to its neighboring points. The standard deviation of
%        the difference is taken as the error estimate.
% --- Parameter(s):
%        data -
%        npoly - the order of the polynomial to fit
%        width - the number of neighboring points to fit (ODD number)
% --- Return(s):
%        err -
%
% --- Example(s):
%
% $Id: error_estimate.m,v 1.1 2013/08/18 04:10:55 xqiu Exp $
%

if (nargin < 1)
   help error_estimate
   return
end

% set default values
if ~exist('npoly', 'var')
   npoly = 2;
end
if ~exist('width', 'var')
   width = 13;
end

% do the polynomial fit and find error
[num_rows, num_columns] = size(data);

istart = ceil(width/2);
iend = num_rows - istart;
ispan = floor(width/2);

for i=istart:iend
   err(i) = std(data(i-ispan:i+ispan,2) - polyval(polyfit(data(i- ...
                                                     ispan:i+ispan,1), ...
                                                     data(i-ispan: ...
                                                     i+ispan,2), ...
                                                     npoly), ...
                                                    data(i-ispan:i+ispan,1)));
end
err(1:istart-1) = err(istart);
err(iend+1:num_rows) = err(iend);
