function value = get_inrange(value, lower_bound, upper_bound)
%
%        value = get_inrange(value, lower_bound, upper_bound)
%
% return the closest value to "value", and within the range of
% "lower_bound" and "upper_bound"
%

if (value > upper_bound)
   value = upper_bound;
end

if (value < lower_bound)
   value = lower_bound;
end
