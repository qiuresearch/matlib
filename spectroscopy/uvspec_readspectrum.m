function uvspec = uvspec_readspectrum(datafile, varargin)
% --- Usage:
%        [adsorpdata, refdata] = uvspec_cuvette(csvfile)
% --- Purpose:
%        read the data output from UV photospectrometer
% --- Parameter(s):
%        csvfile - data file name as a string
% --- Return(s):
%        specdata    - a structure with all data in the fields
% --- Example(s):
%
% $Id: uvspec_readspectrum.m,v 1.15 2013/11/20 04:14:17 xqiu Exp $
%

% 1) check how is called
verbose = 1;
subbkg = 0;
dataformat = [];
parse_varargin(varargin);

if nargin < 1
   help uvspec_readspectrum
   return
end

% 2) read the spec file, and determine the dataformat

speclines = strtrim(cellarr_readascii(datafile, 'replace_tab'));

%  i_end = strmatch('', speclines, 'EXACT');
%  if (length(i_end) == 0)
%     disp(['ERROR:: there are more than one CuvetteSets, only ONE supported!']);
%     return
%  end
%  
%  speclines = speclines(1:i_end-1);

% Guess the dataformat if not passed
[pathstr, name, ext] = fileparts(datafile);
if isempty(dataformat)
   uvspec.dataformat = 'Unknown';
   
   if strcmpi(ext,'.txt')
      uvspec.dataformat = 'NanoVUE';
   end
   
   if strcmpi(ext,'.sp')
      uvspec.dataformat = 'PE Scan';
   end
else
   uvspec.dataformat = dataformat;
end
uvspec.title = datafile;

% 3) read the spectrum file

% Format #1) NanoVUE wavescan or multi wave
if strcmpi(uvspec.dataformat, 'NanoVUE');
   % change ">" to blank; remove empty lines
   speclines = strrep(speclines, '>', '');
   speclines = cellempty(speclines, 'removeall');
   % remove the last line
   speclines = speclines(1:end-1);
   
   uvspec.method = speclines{1};
   uvspec.instrument = speclines{2};
   uvspec.date = speclines{3};
   i=4;
   while ~isempty(speclines{i})
      tokens = strsplit(speclines{i}, ' ', 'reserve_null');
      i=i+1;
      switch tokens{1}
         case 'Pathlength'
            uvspec.pathlength = str2num(tokens{2});
         % specific to wavescan
         case 'Start'
            uvspec.wavelength(1) = str2num(tokens{3});
         case 'End'
            uvspec.wavelength(2) = str2num(tokens{3});
         % start each sample
         case 'Sample'
            if isempty(str2num(tokens{2}));
               continue; % not a real sample
            else
               break;
            end
         otherwise
      end
   end

   i = i -1; % back up 1 line to the start of sample data
   % find all "Sample #" and "Wavelength (nm)" positions
   isam = find(strncmp('Sample', speclines(i:end), 6) == 1)+i-1;
   iwav = find(strncmp('Wavelength (nm)', speclines(i:end), 15) == 1)+i-1;
       %   while (length(isam) ~= length(iwav))
       %      showinfo(['The numbers of Samples and Wavelengths do not ' 'match!']);
       %      if (length(iwav) > length(isam))
       %         % remove the first wavelength index as the spectrum was probably
       %         % printed twice
       %         idouble = find(isam-iwav(1:length(isam)) > 0);
       %         if isempty(idouble);
       %            idouble = length(isam)+1;
       %         end
       %         iwav(idouble(1)-1) = [];
       %      end
       %   end
   isam = [isam, length(speclines)+1];
   uvspec = repmat(uvspec, 1, length(isam)-1);
   for j=1:length(isam)-1
      uvspec(j).samname = str2varname(strrep(speclines{isam(j)}, ' ', ''));
      uvspec(j).title = [uvspec(j).title '-' uvspec(j).samname];
      while ~isempty(iwav) && (iwav(1) < isam(j+1)) % it is data for this sample 
         i = iwav(1)+1;
         if (length(iwav) > 1)
            num_points = min([isam(j+1), iwav(2)])-iwav(1)-1;
         else
            num_points = isam(j+1)- iwav(1)-1;
         end
         showinfo(sprintf('reading %0.0f lines for <%s>', num_points, ...
                          uvspec(j).samname));
         tmpdata =  str2num(strvcat(speclines{i:i+1}));
         uvspec(j).data = str2num(strvcat(speclines{i+2:i+num_points-1}));
         uvspec(j).data = [tmpdata(:,1:length(uvspec(j).data(1,:))); uvspec(j).data];
         % uvspec.(uvspec.samname{j}) = uvspec.data;
         iwav(1) = [];
      end
      if ~isfield(uvspec(j), 'data') || isempty(uvspec(j).data) % if forgot to save wavelength scan!
         i = isam(j)+4;
         uvspec(j).data = str2num(strvcat(speclines{i:isam(j+1)-1}));
         showinfo(sprintf('reading %0.0f lines for <%s>', isam(j+1)-i, ...
                          uvspec(j).samname));
         % uvspec.(uvspec.samname{j}) = uvspec.data;
      end
      uvspec(j).columnnames = {'wavelength(nm)', 'OD'};
   end
end

% PE scan from NIH spectrophotometer
if strcmpi(uvspec(1).dataformat, 'PE Scan')
   % the 3rd line is the file name
   idot = strfind(speclines{3}, '.');
   uvspec.samname{1} = speclines{3}(1:idot(end)-1);
   uvspec.note = speclines{9};
   idata = strmatch('#DATA', speclines);
   if isempty(idata) || (length(idata) > 1)
      showinfo('no or more than one #DATA exists!', 'warning');
      idata = idata(end);
   end
   uvspec.data = str2num(strvcat(speclines{idata+1:end}));
   %   uvspec.(uvspec.samname{1}) = uvspec.data; % for compatibility issues
   
end

% Jasco v-570 from Chemistry dept at GW
if strcmpi(uvspec(1).dataformat, 'jascov570')
   uvspec.title = datafile;
   uvspec.date = strtrim(speclines{5}(6:end));
   idata = strmatch('XYDATA', speclines);
   if isempty(idata) || (length(idata) > 1)
      showinfo('no or more than one #DATA exists!', 'warning');
      idata = idata(end);
   end
   uvspec.data = str2num(strvcat(speclines{idata+1:end}));
   %   uvspec.(uvspec.samname{1}) = uvspec.data; % for compatibility issues
end

% Cary scan dataformat
if strcmpi(uvspec(1).dataformat, 'Cary')
   uvspec.title = datafile;
   uvspec.samname = speclines{1};
   iemptylines = find(strcmp(speclines, '') == 1);
   if isempty(iemptylines)
      iemptylines = length(speclines)+1;
   end
   uvspec.data = str2num(str2mat(speclines(3:iemptylines-1))); % from 3rd line
   % uvspec.(uvspec.samname{1}) = uvspec.data;
end

% 4) post-processing after reading the data
% sort the data to have ascending wavelength

for i=1:length(uvspec)
   uvspec(i).data = sortrows(uvspec(i).data,1);
   %uvspec.(uvspec.samname{1}) = uvspec.data;
end
% subtract the background which is obtained at wavelength "subbkg"
if (subbkg ~= 0)
   for i=1:length(uvspec.samname)
      data = uvspec.data;
      ibkg = locate(data(:,1), subbkg);
      data(:,2) = data(:,2) - data(ibkg,2);
      uvspec.data = data;
   end
end

return
