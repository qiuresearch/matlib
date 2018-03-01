function [x,y] = ionpairing_calc(x0, y0, kd, varargin)
% --- Usage:
%        [x,y] = ionpairing_calc(x0, y0, kd, varargin)
%
% --- Purpose:
%        Assume a simple ion pairing: x+y=xy, kd=[x][y]/[xy].
%        Input parameters are x+xy=x0, y+xy=y0   
%   
% --- Return(s): 
%
% --- Parameter(s):
%        var   - 
%
% --- Example(s):
%
% $Id: ionpairing_calc.m,v 1.1 2012/07/24 13:48:48 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

% equation is: sol = solve('x*(y0-x0+x)/(x0-x)=kd', 'x');
% it can be expanded to: x^2+(y0+kd-x0)x-kd*x0=0

a=1;
b=y0+kd-x0;
c=-kd.*x0;

% there are two solutions, we only need the positive solution

x=(-b+sqrt(b.^2-4*a.*c))./a/2;
