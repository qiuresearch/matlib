function xydata = xypro_filename(xydata, varargin)
% --- Usage:
%        xydata = xypro_filename(xydata, varargin)
% --- Purpose:
%
% --- Parameter(s):
%
% --- Return(s):
%        results -
%
% --- Example(s):
%
% $Id: xypro_fitfunc.m,v 1.2 2013/08/29 04:12:49 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

