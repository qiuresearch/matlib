function result = file_newer(filea, fileb)
% --- Usage:
%        [avgdata, imgdata] = template(var)
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
% $Id: file_newer.m,v 1.1 2013/01/15 02:03:31 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

infoa = dir(filea);
infob = dir(fileb);

result = infoa.datenum > infob.datenum;