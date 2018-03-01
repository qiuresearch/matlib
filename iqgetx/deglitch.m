function [result, index, count] = deglitch(data, width, threshold)
% --- Usage:
%        [result, index, count] = deglitch(data, width, threshold)
%
% --- Purpose:
%        remove the short span glitches in the data. The program
%        simply checks whether one value is more than "threshold"
%        folds deviating from its BOTH left and right neighbors within
%        "width". linear interpolation is used then.
%
% --- Parameter(s):
%        data   - one dimensional array, the data to deglitch
%        width  - the number of data points for average behavior
%        threshold - set the outlier lower limit 
%
% --- Return(s): 
%        result - the deglitched data
%        index  - the index of found glitches
%        count  - number of glitches
%
% --- Example(s):
%
% $Id: deglitch.m,v 1.1 2013/01/02 04:06:52 xqiu Exp $
%

if nargin < 1
   help deglitch
   return
end
if nargin < 2
   width = 7;
end
if nargin < 3
   threshold = 2.6;  % the glitch should be three times large than
                   % the mean difference
end

num_points = length(data);
smoothdata = smooth(data, width);

delta = width*2;  % the box width will be large than glitch width
diff_left = data - circshift(smoothdata,delta);
diff_left(1:delta+1)=0;
diff_right = data - circshift(smoothdata, -delta);
diff_right(num_points-delta-2:end) = 0;
threshold = threshold * mean(abs(data - smoothdata));

i_noyes = (abs(diff_right) > threshold) & (abs(diff_left) > threshold) ...
          & sign(diff_right) == sign(diff_left) ;
index = find(i_noyes);
count = length(index);
disp([int2str(count) ' glitches found!']);
if count == 0
   result = data;
   return
end

delta = fix(width);
i_noyes(:) = ~i_noyes;
for i=1:count
   i_start = max(1, index(i)-delta);
   i_end = min(num_points, index(i)+delta);
   fitarr = data(i_start:i_end);
   data(index(i)) = mean(fitarr(i_noyes(i_start:i_end)));
end
result = data;
