function area = nint(x,y,lo,hi)
%NINT        trapezoid rule integration of an [X,Y] curve
%  AREA = NINT(X, Y, LO, HI)  optional arguments LO, HI specify the
%    integration interval for X, the default values are LO=-INF, HI=INF

%  $Id: nint.m 26 2007-02-27 22:45:38Z juhas $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 3
    lo = -Inf;
end
if nargin < 4
    hi = +Inf;
end

x = x(:);
y = y(:).';
i = find( lo<=x & x<=hi );
x = x(i);
y = y(i);

dx = [ x(2)-x(1);  x(3:end)-x(1:end-2);  x(end)-x(end-1) ] / 2;
area = y*dx;
