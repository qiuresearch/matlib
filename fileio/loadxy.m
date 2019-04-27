function data = loadxy(fname, varargin)
% --- Usage:
%        data = loadxy(fname, varargin)
%
% --- Purpose:
%        Simply remove the comment fields (starting with #) and read
%        it into an array
%
%--- Parameter(s):
%        varargin   - 'comment' = '#'; 'nskip'=n
%
% --- Return(s): 
%
% --- Example(s):
%
% $Id: loadxy.m,v 1.7 2013/08/23 18:52:47 xqiu Exp $
%

if exist(fname,'file') == 0
    help loadxy
    disp('                    ');
    disp(['Specified file: ', fname, ' does not exist!']);
    disp('Please review input.');
    disp('                    ');
    return
end

nskip = 0;
parse_varargin(varargin);

if ~exist('comment', 'var') || isempty(comment)
   comment = '#';
end

% read in data file as cell array of strings
datastr = strtrim(cellarr_readascii(fname));

% check for "chi" files from fit2d, skip four lines
if strcmpi(fname(end-2:end), 'chi')
    nskip = 4;
end
    
% skip lines
if (nskip > 0)
   datastr(1:nskip) = [];
end

% remove comments
if (length(comment) ~= 0)
   icomments = strmatch('#', datastr);
   if ~isempty(icomments)
      datastr(icomments) = [];
   end
end

%SH: added this because some nsls files had :# on one comment line
if (length(comment) ~= 0)
   icomments = strmatch(':', datastr);
   if ~isempty(icomments)
      datastr(icomments) = [];
   end
end

% remove any line that starts with a letter
datastr = char(datastr);
data = str2num(datastr((datastr(:,1) == 43) | (datastr(:,1) == 45) ...
                       | ((datastr(:,1)>=48) & (datastr(:,1)<=57)),:));
