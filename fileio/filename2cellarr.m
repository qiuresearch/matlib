function result = filename2cellarr(filepattern)
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

filelist = dir(filepattern);
if isempty(filelist)
    showinfo(['No file found with pattern: ' filepattern]);
    return
end

filenames = {'{ ...'};
for i=1:length(filelist)
    filenames = 
end
