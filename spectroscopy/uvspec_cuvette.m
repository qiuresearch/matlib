function uvspec = uvspec_cuvette(datafile)
% --- Usage:
%        [adsorpdata, refdata] = uvspec_cuvette(datafile)
% --- Purpose:
%        read the data output from UV photospectrometer
% --- Parameter(s):
%        datafile - data file name as a string
% --- Return(s):
%        specdata    - a structure with all data in the fields
% --- Example(s):
%
% $Id: uvspec_cuvette.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $
%

% 1) check how is called
verbose = 1;

if nargin < 1
   help uvspec_cuvette
   return
end

% 2) read the spec file, and remove useless lines

runit = fopen(datafile, 'r');
speclines = fread(runit);
fclose(runit);

speclines = strtrim(strsplit(char(speclines'), sprintf('\n')));
if ischar(speclines)  || (numel(speclines) == 1)
   showinfo('no NEW LINE found, try CARRIAGE RETURN ...');
   speclines = strtrim(strsplit(char(speclines), sprintf('\r')));
end
speclines = strrep(speclines, sprintf('\t'), ' '); % replace TAB

% 3) get the number of rows and columns of the data block

i_start = strmatch('Cuvette:', speclines);
if (length(i_start) ~= 1) 
   disp(['ERROR:: there are more than one CuvetteSets, only ONE supported!']);
   return
end

uvspec.format = 'Cuvette';
uvspec.title = strsplit(speclines{i_start}, ' ');
uvspec.num_rows = str2num(uvspec.title{9});
uvspec.num_cols = str2num(uvspec.title{15}) + 2;  % plus "wavelength" and "temperature"

% 4) read the data and check the wavelengh equality

uvspec.rawdata = zeros(uvspec.num_rows, uvspec.num_cols);
uvspec.bkgdata = zeros(uvspec.num_rows, uvspec.num_cols);
uvspec.column_names = strsplit(speclines{i_start+1},' ');

for i1=1:uvspec.num_rows
   uvspec.rawdata(i1,:) = str2num(speclines{i_start+1+i1});
   uvspec.bkgdata(i1,:) = str2num(speclines{i_start+1+i1+uvspec.num_rows});
end

if ~isequal(uvspec.rawdata(:,1), uvspec.bkgdata(:,1))
   showinfo(['Wavelengths for raw and bkg data are not equal, please ' ...
             'check!!!' ]);
end

% 5) subtract the reference data
uvspec.data = uvspec.rawdata;
uvspec.data(:,3:end) = uvspec.data(:,3:end) - uvspec.bkgdata(:,3:end);

% 6) get the well labels if available

i_start = strmatch('Group: Controls', speclines);
if isempty(i_start)
   showinfo('there is no group information in the data!', 'error');
   return
end
i_start = i_start(end) + 1; % next line is the column description
num_cols = length(strsplit(speclines{i_start}, ' '));
end_isa = 0; i=0;
while (end_isa ~= 1)
   i_start = i_start + 1; i=i+1;
   tokens = strsplit(speclines{i_start}, ' ');
   if (length(tokens) ~= num_cols) || ~ isempty(strmatch('Outlier', ...
                                                        speclines{i_start}))
   end_isa=1;
   continue
   end
   uvspec.sam_names{i}=tokens{1};
   uvspec.well_ids{i} = tokens{2};
end
return
