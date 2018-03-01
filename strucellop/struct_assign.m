function stru_to = struct_assign(stru_from, stru_to, varargin)
% --- Usage:
%        stru_to = struct_assign(stru_from, stru_to, varargin)
%
% --- Purpose:
%        copy fields of one structure to another
%
% --- Parameter(s):
%        varargin - 'append' default: 0; 'suffix' default: ''. 
%
% --- Return(s):
%        results -
%
% --- Example(s):
%
% $Id: struct_assign.m,v 1.3 2013/09/18 00:33:59 xqiu Exp $
%

verbose = 1;
if (nargin < 2)
   error('at least two structures should be passed!')
   help struct_assign
   return
end
append = 0;
copyempty = 0;
suffix = '';
prefix = '';
parse_varargin(varargin);

assign_names = fieldnames(stru_from);
if (append == 0) % only copy fields with common names
   assign_names = intersect(fieldnames(stru_from(1)), fieldnames(stru_to));
end

for ifield = 1:length(assign_names)
   if (copyempty==0) && isempty(stru_from.(assign_names{ifield}));
      continue;
   end
   stru_to = setfield(stru_to, [prefix assign_names{ifield} suffix], ...
                               getfield(stru_from, assign_names{ifield}));
end
