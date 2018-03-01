function [xc,yc,R,a] = circfit(x,y)
% --- Usage:
%        [xc,yc,R,a] = circfit(x,y)
% --- Purpose:
%        fits a circle in x,y plane in a more accurate (less prone
%  to ill condition ) procedure than circfit2 but using more memory
%  x,y are column vector where (x(i),y(i)) is a measured point.
%  Adapted from a script by Izhak bucher 25/oct /1991.
% --- Parameter(s):
%
% --- Return(s):
%        (xc,yc) - the center point
%         R - radius
%         a - an optional output is the vector of coeficient a
%             describing the circle's equation
%                      x^2+y^2+a(1)*x+a(2)*y+a(3)=0
% --- Example(s):
%
% $Id: circfit.m,v 1.1 2011-10-08 14:56:08 xqiu Exp $
%

if (nargin < 2)
   help circfit
   return
end

x=x(:); y=y(:);
a=[x y ones(size(x))]\[-(x.^2+y.^2)];
xc = -.5*a(1);
yc = -.5*a(2);
R  =  sqrt((a(1)^2+a(2)^2)/4-a(3));
