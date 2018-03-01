function specdata = jasco_readascii(datafile)
% --- Usage:
%        specdata = fluor_readascii(datafile)
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
% $Id: jasco_readascii.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $
%
verbose = 1;
% 1) check the specfile
if nargin < 1
   error('at least one parameter is required, please see the usage! ')
   help  jasco_readascii
   return
end

if ~exist(datafile, 'file')
   error(['data file: ' datafile ' does not exist!'])
   return
end

% 2) read the spec file, and remove useless lines
speclines = cellarr_readascii(datafile, 'replace_tab',0);


% 3) parse the fields

for i=1:length(speclines)
   
   tokens = strtrim(strsplit(speclines{i}, sprintf('\t'), 'preserve_null'));
   
   % data in column format
   if strcmpi(tokens{1}, 'XYDATA')
      specdata.data = str2num(strvcat(speclines{i+1:end}));
      break;
   end
   
   % handle meta data
   if strcmpi(tokens{1}, 'XUNITS')
      specdata.columnnames{1} = tokens{2};
      continue
   end
   if strcmpi(tokens{1}, 'YUNITS')
      specdata.columnnames{2} = tokens{2};
      continue
   end

   if isempty(tokens{1}) % assume to be Y units
      specdata.columnnames{end+1} = tokens{2};
      continue
   end
   
   if (length(tokens) < 2)
      specdata.(lower(str2varname(tokens{1}))) = '';
   else
      specdata.(lower(str2varname(tokens{1}))) = tokens{2};
   end
end

% Judge by first line: numbers -> just ascii file.
%if (speclines{1}(1) >= '0') && (speclines{1}(1) <='9')
%end
