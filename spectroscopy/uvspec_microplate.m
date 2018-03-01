function [uvspec, speclines] = uvspec_microplate(datafile, varargin)
% --- Usage:
%        uvspec = uvspec_microplate(datafile)
% --- Purpose:
%        read the data output from UV photospectrometer
% --- Parameter(s):
%        datafile - data file name as a string
% --- Return(s):
%        uvspec    - a structure containing the data fields
% --- Example(s):
%
% $Id: uvspec_microplate.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $
%

% 1) check how is called
verbose = 1;
parse_varargin(varargin);
if (nargin < 1)
   help uvspec_microplate
   return
end

% 2) read the spec file, and remove useless lines
runit = fopen(datafile, 'r');
speclines = fread(runit);
fclose(runit);

speclines= strtrim(strsplit(char(speclines'), sprintf('\n')));
if ischar(speclines) || (numel(speclines) == 1)
   showinfo('no NEW LINE found, try CARRIAGE RETURN ...');
   speclines = strsplit(char(speclines), sprintf('\r'));
end
speclines = strrep(speclines, sprintf('\t'), ' '); % replace TAB

% 3) get the number of rows and columns of the data block

i_start = strmatch('Group: Samples', speclines);
if isempty(i_start)
   showinfo('there is no group information in the data!', 'error');
   return
end

uvspec.format = 'Microplate';
uvspec.title = strsplit(speclines{i_start}, ' ');
i_start = i_start(end) + 1; % next line is the column description
uvspec.column_names = strsplit(speclines{i_start}, ' ');
uvspec.num_cols = length(uvspec.column_names);

% 4) read the data
end_isa = 0; i=0;
while (end_isa ~= 1)
   i_start = i_start + 1; i=i+1;
   tokens = strsplit(speclines{i_start}, ' ');
   if (length(tokens) ~= uvspec.num_cols) || ~ isempty(strmatch('Outlier', ...
                                                        speclines{i_start}))
      end_isa=1;
      continue
   end
   uvspec.sam_names{i}=tokens{1};
   uvspec.well_ids{i} = tokens{2};
   uvspec.data(i,:) = str2double(tokens(3:uvspec.num_cols));
end
uvspec.column_names = uvspec.column_names(3:end);
uvspec.num_cols = uvspec.num_cols - 2;
uvspec.num_sams = length(uvspec.sam_names);
return
