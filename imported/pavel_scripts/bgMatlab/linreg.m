function [a,b,sa,sb,D]=linreg(x,y)
%LINREG      least squares fitting of a line
%  [a,b,sa,sb,ss] = LINREG(X,Y)  fits the line Y = aX + b
%  sa, sb  are standard deviations of the coefficients a, b
%  ss      is the sum of squares divided by n-2

%  $Id: linreg.m 26 2007-02-27 22:45:38Z juhas $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

x=x(:); y=y(:);
n = length(x);
sxy=sum(x.*y);sx= sum(x);sy=sum(y);sxx=sum(x.^2);
m = n*sxx-(sx)^2;
a = (n*sxy-sx*sy)/m;
b = (sxx*sy - sx*sxy)/m;
if n>2
   D  = sum((y-(a*x+b)).^2) / (n-2);
   sa = sqrt( D*n / m );
   sb = sqrt( D*sxx / m );
else
   sa=0;sb=0;
end
