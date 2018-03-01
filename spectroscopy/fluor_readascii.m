function specdata = fluor_readascii(datafile)
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
% $Id: fluor_readascii.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $
%
verbose = 1;
% 1) check the specfile
if nargin < 1
   error('at least one parameter is required, please see the usage! ')
   help  fluor_readascii
   return
end

if ~exist(datafile, 'file')
   error(['data file: ' datafile ' does not exist!'])
   return
end

% 2) read the spec file, and remove useless lines
speclines = strtrim(cellarr_readascii(datafile, 'replace_tab',0));

% Judge by first line: numbers -> just ascii file.
if (speclines{1}(1) >= '0') && (speclines{1}(1) <='9')
   cwa_isa = 0;
else
   cwa_isa = 1;
end

% 3) parse the fields
if (cwa_isa == 1) % in case of a cwa file
   specdata.title = speclines{1};
   specdata.columnnames = {};

   icol = 1;
   for i = 4:length(speclines);
      iblank = strfind(speclines{i}, sprintf('\t'));
      if isempty(iblank)
         showinfo(['No data in this line: (#' num2str(i) ')']);
         continue;
      end
      
      name = speclines{i}(1:iblank(1)-1);
      specdata.columnnames = {specdata.columnnames{:}, name};
      data = str2num(speclines{i}(iblank(1):end));
      if ~isfield(specdata, 'data') || (numel(data) == ...
                                        numel(specdata.data(:,1)))
         specdata.data(:,icol) = data(:);
      else
         showinfo('number of columns does not match!');
         if (numel(data) > numel(specdata.data(:,1)))
            specdata.data(:,icol) = data(1:numel(specdata.data(:, 1)));
         else
            specdata.data(1:numel(data),icol) = data(:)
         end
      end
      icol = icol+1;
   end
end

if (cwa_isa ~= 1) % just a two column ASCII XY data
   specdata.title = 'ASCII Export';
   specdata.columnnames = {'Wavelength (nm)', 'Intensity (cps)'};
   specdata.data = str2num(strvcat(speclines{:}));
   specdata.title = [specdata.title sprintf(': [%i, %i]', ...
                                            specdata.data(1,1), ...
                                            specdata.data(end,1))];
end
