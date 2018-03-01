function y = gauss(x,x0,sigma)
% --- Usage:
%        y = gauss(x,x0,sigma)
% --- Purpose:
%        calculate a simple Gaussian function
% --- Parameter(s):
%        x - the x coordinates to compute y
%        x0 - the center of the Gaussian
%        sigma - width
% --- Return(s):
%        y - returned in vector form as x
%
% --- Example(s):
%
% $Id: gauss.m,v 1.1 2013/08/17 13:52:28 xqiu Exp $
%

% 1) Simple check on input parameters
if (nargin < 1)
   help gauss
   return
end

if ~exist('x0', 'var')
   x0 = 0;
end
if ~exist('sigma', 'var')
   sigma = 1;
end

y = 1/sigma/sqrt(2*pi)*exp(-0.5/sigma/sigma*(x-x0).^2);

return
