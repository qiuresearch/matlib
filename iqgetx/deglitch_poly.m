function [result, index, count] = deglitch_poly(data, threshold, npoly)
% --- Usage:
%        [result, index, count] = deglitch_sas(data, threshold, npoly)
%
% --- Purpose:
%        remove the short span glitches in the data. The program
%        simply checks whether one value is more than "threshold"
%        folds deviating from its BOTH left and right neighbors within
%        "width". linear interpolation is used then.
%
% --- Parameter(s):
%        data   - one dimensional array, the data to deglitch
%        threshold - set the outlier lower limit 
%        npoly  - the number of polynomials to fit
%
% --- Return(s): 
%        result - the deglitched data
%        index  - the index of found glitches
%        count  - number of glitches
%
% --- Example(s):
%
% $Id: deglitch_poly.m,v 1.1 2013/01/02 04:06:52 xqiu Exp $
%

if nargin < 1
   help deglitch_poly
   return
end
if nargin < 2
   threshold = 3;
end
if nargin < 3
   npoly = 6;
end

num_points = length(data);
i_used = 1:ceil(num_points/150):num_points;

p = polyfit(data(i_used,1), data(i_used,2), npoly);
yfit = polyval(p, data(:,1));

ydelta = abs(data(:,2) - yfit);
i_noyes = ydelta > threshold*mean(ydelta);
index = find(i_noyes);
count = length(index);
disp([int2str(count) ' glitches found!']);
if count == 0
   result = data;
   return
end

delta = fix(npoly*2);
i_noyes(:) = ~i_noyes;
for i=1:count
   i_start = max(1, index(i)-delta);
   i_end = min(num_points, index(i)+delta);
   fitarr = data(i_start:i_end,2);
   fitarr = fitarr(i_noyes(i_start:i_end));
   if ~isempty(fitarr)
      data(index(i),2) = mean(fitarr);
   end
end
result = data;

