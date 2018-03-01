function data = gcd2()
% --- Usage:
%        data = gcd2()
% --- Purpose:
%        get the 2D data off current active object.
%

xdata = get(gco, 'xdata');
ydata = get(gco, 'ydata');

num_points = length(xdata);

data = zeros(num_points, 2);
data(:,1) = xdata(:);
data(:,2) = ydata(:);
