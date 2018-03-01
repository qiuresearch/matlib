function ok = showpeak(data, varargin)

range = [data(1,1), data(end,1)];
format = '[%0.0f, %0.2f]';
valley = 0;
parse_varargin(varargin);

imin = locate(data(:,1), range(1));
imax = locate(data(:,1), range(2));
data = data(min([imin,imax]):max([imin,imax]),:);
if (valley == 0)
   [y, imax] = max(data(:,2));
else
   [y, imax] = min(data(:,2));
end
showcoord([data(imax,1), y], format);
