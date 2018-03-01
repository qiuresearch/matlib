function specdata = specdata_savefile(specdata, specfile, format)
% --- Usage:
%        specdata = specdata_savefile(specdata, specfile, format)
% --- Purpose:
%        read a SPEC format file to an array of structures
%
% --- Parameter(s):
%     
% --- Return(s): 
%        results - 
%
% --- Example(s):
%
% $Id: specdata_savefile.m,v 1.6 2014/03/19 05:07:04 xqiu Exp $
%
verbose = 1;
if (nargin < 1)
   help specdata_savefile
   return
end

if ~exist('format', 'var') || isempty(format)
   format = '%0.4E';
end

fid = fopen(specfile, 'w');
for i=1:length(specdata)
   if ~isfield(specdata(i), 'scannum')
      fprintf(fid, '#S 1 %s\n', specdata(i).title);
   else
      fprintf(fid, '#S %i %s\n', specdata(i).scannum, specdata(i).title);
   end      
   if ~isfield(specdata(i), 'time') || isempty(specdata(i).time)
      fprintf(fid, '#D created on %s\n', datestr(now));
   else
      fprintf(fid, '#D created on %s\n', num2str(specdata(i).time));
   end
   
   % any other extra fields (only support char and numeric now)

   % setdiff sorts the field names, which is undesired!!!
   % extra_fields = setdiff(fieldnames(specdata(i)), {'scannum', ...
   %                    'title', 'time', 'columnnames', 'data'});

   field_names = fieldnames(specdata(i));
   for j=1:length(field_names)
      % why not saving "datadir" "prefix"...?
      % 'datadir', 'prefix', 'suffix', 'filename'}
      if ismember(field_names{j}, {'scannum', 'title', 'time', ...
                             'columnnames', 'data',}); continue; end
      
      if length(specdata(i).(field_names{j})) < 1000;
         value = specdata(i).(field_names{j});
      else
         value = [];
         showinfo(['Field <' field_names{j} ['> has over 1000 elements, ' ...
                             'not saved!']]);
      end
      fprintf(fid, '#V %s=%s;\n', field_names{j}, value2commandstr(value));
      
   end

   % write column names and data
   fprintf(fid, '#L %s\n', strjoin(specdata(i).columnnames, ' '));
   [num_rows, num_cols] = size(specdata(i).data);
   fprintf(fid, [repmat([format ' '], 1, num_cols-1) format '\n'], specdata(i).data');
end
fclose(fid);

showinfo(sprintf('data [%1ix%1i] saved into file: %s', num_rows, ...
                 num_cols, specfile));