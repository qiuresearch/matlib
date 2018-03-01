function diameter = cnt_diameter(n, m, varargin)
% --- Usage:
%        diameter = cnt_diameter(n, m, varargin)
%
% --- Purpose:
%
% --- Return(s): 
%
% --- Parameter(s):
%        var   - 
%
% --- Example(s):
%
% $Id: cnt_diameter.m,v 1.1 2012/07/05 03:09:04 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

a = 2.46; % Angstrom
parse_varargin(varargin);

diameter = a/pi*sqrt(n*n+n*m+m*m);
