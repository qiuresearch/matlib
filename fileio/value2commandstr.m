function comstr = value2commandstr(value, varargin)
% --- Usage:
%        comstr = value2commandstr(value, varargin)
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
% $Id: value2commandstr.m,v 1.4 2014/02/06 23:13:04 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

format = '%0.8g';
parse_varargin(varargin);

comstr = '[]; % Unrecognized by value2commandstr.m';

%if isstruct(value)
%   value = value(1);
%   comstr='struct(';
%   field_names = fieldnames(value);
%   for i=1:(length(field_names)-1)
%      field_names{i}
%      comstr = [comstr '''' field_names{i} '''' ',' ...
%                value2commandstr(value.(field_names{i})) ','];
%   end
%   comstr = [comstr '''' field_names{end} '''' ',' ...
%             value2commandstr(value.(field_names{end})) ')'];
%end

if ischar(value)
   comstr = '[';
   if ~isempty(value)
      for i=1:length(value(:,1))
         comstr = [comstr '''' value(i,:) '''' ';'];
      end
   else
      comstr = [comstr '''' '''' ';'];
   end
   comstr=[comstr(1:end-1), ']'];
end

if iscellstr(value)
   [num_rows, num_cols] = size(value);
   format_all = repmat([repmat('''%s'',',1,num_cols-1), ['''%s'';']], ...
                       1, num_rows);
   format_all = ['{', format_all(1:end-1), '}'];
   comstr = sprintf(format_all, value{:});
end

if ~iscellstr(value) && iscell(value)
   [num_rows, num_cols] = size(value);
   comstr='{';
   for ir=1:num_rows
      for ic=1:num_cols-1
         comstr = [comstr, value2commandstr(value{ir,ic}) ','];
      end
      comstr = [comstr, value2commandstr(value{ir,end}) ';'];
   end
   comstr = [comstr(1:end-1), '}'];
end

if isnumeric(value)
   [num_rows, num_cols] = size(value);
   format_all = repmat([repmat([format,','],1,num_cols-1), [format,';']], ...
                       1, num_rows);
   format_all = ['[', format_all(1:end-1), ']'];
   comstr = sprintf(format_all, value');
end
