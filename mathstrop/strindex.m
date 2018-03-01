function index = strindex(todostr, setstr, mode)
% --- Usage:
%        index = strindex(todostr, setstr, mode)
% --- Purpose:
%
% --- Parameter(s):
%        mode - either "exact" or empty
%
% --- Return(s):
%        results -
%
% --- Example(s):
%
% $Id: strindex.m,v 1.1 2013/08/17 13:52:29 xqiu Exp $
%

if (nargin < 2)
   help strindex
   return
end
if ~exist('mode', 'var')
   mode = 'exact';
end

if strcmpi(mode, 'exact') % comparision direction doesn't matter
   if ischar(todostr)
      [num_todos, dummy] = size(todostr);
   else
      num_todos = length(todostr);
   end
   if ischar(setstr)
      [num_sets, dummy] = size(setstr);
   else
      num_sets = length(setstr);
   end
   
   index = zeros(1, num_todos);
   if (num_sets > num_todos)
      if ischar(todostr); todostr = cellstr(todostr); end
      for i=1:num_todos
         k =  strmatch(todostr{i}, setstr, 'exact');
         if ~isempty(k); index(i) = k(1); end % use the first match
      end
   else
      if ischar(setstr); setstr = cellstr(setstr); end
      for i=1:num_sets
         index(strmatch(setstr{i}, todostr, 'exact')) = i;
      end
   end
else  % only one way comparison possible
      if ischar(todostr) % convert to cell if a string array
         todostr = cellstr(todostr);
   end
   num_todos = length(todostr);
   
   index = zeros(1, num_todos);
   for i=1:num_todos
      k =  strmatch(todostr{i}, setstr);
      if ~isempty(k); index(i) = k(1); end % use the first match
   end
end
