function dlsdata = dls_read(dlsfile, varargin)
% --- Usage:
%        dlsdata = dls_read(dlsfile, varargin)
% --- Purpose:
%
% --- Parameter(s):
%
% --- Return(s):
%        results -
%
% --- Example(s):
%
% $Id: dls_read.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $
%

if (nargin < 1)
   help dls_read
   return
end
verbose =1 ;
delimiter = sprintf('\t');
parse_varargin(varargin);

dlslines = cellarr_readascii(dlsfile);

% remove all ", "
dlslines{1} = strrep(dlslines{1}, '"', '');

column_names = strsplit(dlslines{1}, delimiter);
column_names = strrep(column_names, '-', '_');
column_names = strrep(column_names, '/', '_');
column_names = strrep(column_names, '.', '_');
num_cols = length(column_names);
showinfo(['number of initial columns: ' num2str(num_cols)]);

% remove the description of unit
ilp = strfind(column_names, '(');
irp = strfind(column_names, ')');
ilb = strfind(column_names, '[');
irb = strfind(column_names, ']');

column_index(1:num_cols)=1;
for i=1:num_cols
   column_unit = [];
   % remove the unit tag, assuming in the end
   if ~isempty(ilp{i}) && ~isempty(irp{i})
      column_unit = column_names{i}(ilp{i}+1:irp{i}-1);
      column_names{i}= column_names{i}(1:ilp{i}-1);
   end
   
   % remove the array index
   if ~isempty(ilb{i}) && ~isempty(irb{i})
      column_index(i) = str2num(column_names{i}(ilb{i}+1:irb{i}- 1));
      column_names{i} = column_names{i}(1:ilb{i}-1);
   end

   % remove the blanks in the column names
   column_names{i} = strrep(strtrim(column_names{i}), ' ', '_');

   % assign the unit
   if ~isempty(column_unit)
      dlsdata.([column_names{i} '_unit']) = column_unit;
   end
end

% find the unique columns (index of columns belonging to an array
% diff by 1).
I = find((column_index - [1,column_index(1:end-1)]) ~= 1);
num_uniques = length(I);
unique_columns = column_names(I);
showinfo(['number of unique columns: ' num2str(num_uniques)]);

for i=2:length(dlslines)

   if strcmp(dlslines{i}(1), '"')  % each field is enclosed by ""
      index_fields = strfind(dlslines{i}, '"');
      if (mod(length(index_fields),2) == 1)
         showinfo('counts of " should be an even number!', 'warning')
      end
      index_fields = [index_fields(1:2:end)-1, length(dlslines{i})+1];
      % replace the ", " by blank
      dlslines{i} = strrep(dlslines{i}, '"', ' ');
   else % use the same delimiter (e.g. TAB)
      index_fields = strfind(dlslines{i}, delimiter);
      
      index_fields = [0, index_fields(I(2:end)-1), length(dlslines{i})+1];
   end
   if ((length(index_fields) - num_uniques) ~= 1)
      showinfo(['numbers of fields (=' num2str(length(index_fields)) ...
                ') and columns (=' num2str(num_uniques) ') not match!'], ...
           'warning') ;
   end
   
   dlsdata(i)=dlsdata(1);
   for k=1:num_uniques

      %      disp(['Line: ' num2str(i) ' Column:' unique_columns{k}])
      string_field =  strtrim(dlslines{i}(index_fields(k)+1:index_fields(k+1)-1));

      
      % try numeric first, then string (empty matrix will not
      % trigger error)
      
      dlsdata(i).(unique_columns{k}) = str2num(string_field);
      if isempty(dlsdata(i).(unique_columns{k}))
         dlsdata(i).(unique_columns{k}) = string_field;
      end
   end
   %
   if isnumeric(dlsdata(i).Sample_Name)
      dlsdata(i).Sample_Name = num2str(dlsdata(i).Sample_Name);
   end
end

% return: remove the first 
dlsdata = dlsdata(2:end);
showinfo(['number of records: ' num2str(length(dlsdata))]);
