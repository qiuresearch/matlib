function [index, deviation] = locate(x, value)
%        [index, deviation] = locate(x, value)
% find the nearest match of "value" in array "x". The difference is
% "deviation". 
%
for i=1:length(value)
   [deviation(i), index(i)] = min( abs(x-value(i)) );
end