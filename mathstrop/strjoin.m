function string = strjoin(strcell, delimiter)
% --- Usage:
%        string = strjoin(strcell, delimiter)
% --- Purpose:
%        join together string arrays or cell array of strings
% --- Parameter(s):
%        strcell - either a string array or cell arrary of strings
%        delimiter - the delimiter inbetween elements
% --- Return(s):
%        results -
%
% --- Example(s):
%
% $Id: strjoin.m,v 1.1 2013/08/17 13:52:29 xqiu Exp $
%

if ~exist('delimiter', 'var')
   delimiter = '';
end

% convert to cell if it's a string (array)
if ischar(strcell)
   strcell = cellstr(strcell);
end

%
if strmatch(delimiter, '')
   string = [strcell{:}];
else
   string = '';
   for i=1:(length(strcell)-1)
      string = [string, strcell{i}, delimiter];
   end
   string = [string, strcell{end}];
end

