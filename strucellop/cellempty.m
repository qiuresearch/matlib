function [result, index_empty] = cellempty(cell_in, option)
%        [result, index_empty] = cellempty(cell_in, option)
% --- Purpose:
%        remove or keep the empty cell(s) of a cell array
%
% --- Parameter(s):
%    cell_in - the input cell array "victim"
%     option - how to remove the empty cells, possible values are:
%              'removeall'(default), 'removelast', 'removefirst',
%              'removeleading', and 'removetrailing'
%
% --- Return(s):
%        result - a cell array with the according empty cells removed
%        index_empty - the index to empty cells
%
% --- Calling Method(s):
%
% --- Example(s):
%
% $Id: cellempty.m,v 1.1 2013/08/17 17:05:36 xqiu Exp $
%

% 1) Simple check on input parameters

if (nargin < 1)
  error('one cell array has to be supplied!');
  return
end
if (nargin < 2)  % the default option is to remove all
  option = 'removeall';
else
  option = lower(option);
end

% 2) Do the job

index_empty = cellfun('isempty', cell_in);
result = cell_in;

switch option
 case {'removeall', 'remove'}
  result(index_empty) = [];
 case 'removelast'      % find the last occurence
  result(find(index_empty,1,'last')) = [];
 case 'removefirst'     % find the first occurance
  result(find(index_empty,1,'first')) = [];
 case 'removeleading'   % find the first nonzero occurence
  result(1:find(bitxor(index_emtpy,1),1,'first')) = [];
 case 'removetrailing'  % find the last nonzero occurence
  result(find(bitxor(index_emtpy,1),1,'last'):end) = [];
 otherwise
  result = cell_in;
end
