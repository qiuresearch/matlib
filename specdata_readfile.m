function specdata = specdata_readfile(specfile, varargin)
% --- Usage:
%        specdata = specdata_readfile(specfile, varargin)
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
% $Id: specdata_readfile.m,v 1.3 2013/09/21 03:32:46 xqiu Exp $
%
verbose = 1;
% 1) check the specfile
if nargin < 1
   error('at least one parameter is required, please see the usage! ')
   help specdata_readfile
   return
end
parse_varargin(varargin);

% 2) read the spec file, and remove useless lines
if ~ exist(specfile, 'file')
   error(['spec file: ' specfile ' does not exist!'])
   return
end

runit = fopen(specfile, 'r');
speclines = fread(runit);
fclose(runit);

speclines = strsplit(char(speclines'), sprintf('\n'));
speclines = strrep(speclines, sprintf('\t'), ' ');
speclines = strtrim(speclines);

% only used after "##### start data" IF it exists
istartdata = strmatch('##### START DATA', speclines);
if ~isempty(istartdata)
   speclines = speclines(istartdata(end):end);
end
% remove "#" comment lines
%ihashlines = strmatch('#', speclines);
%speclines(ihashlines(~(strncmp(speclines(ihashlines), '#L', 2) | ...
%                       strncmp(speclines(ihashlines), '#S', 2)))) = [];
% remove empty lines
speclines = speclines(~strcmp(speclines, ''));

% 3) parse the left lines and save to a structure

iS = strmatch('#S', speclines);
iL = strmatch('#L', speclines);
if (length(iS) ~= length(iL))
   showinfo(['WARNING:: numbers of #S and #L do not match for ' specfile]);
elseif (length(iS) > 0)
   showinfo(['reading ' num2str(length(iS)) ' scan(s) from ' specfile]);
end

num_scans = length(iS);
specdata = repmat(struct('scannum', 0.0, 'title', '', 'columnnames', ...
                    [], 'data', []), 1, num_scans);

iS = [iS; length(speclines)+1]; % artifical addition to get the
                                % last data easily
for i=1:num_scans
   % #S line
   tokens = strsplit(speclines{iS(i)}, ' ');
   if (length(tokens) > 2)
      specdata(i).scannum = str2num(tokens{2});
      itmp = strfind(speclines{iS(i)}, tokens{3});
      specdata(i).title = speclines{iS(i)}(itmp(1):end);
   end
   
   % remove iL appearing before iS
   while (iL(1) <= iS(i)) && (numel(iL)>1)
      iL(1) = [];
   end
   
   if (iL(1) > iS(i+1)) % no #L line for S(i), still can read variables
      showinfo(['no #L exists for scan# ' num2str(specdata(i).scannum) ...
                num2str(i,'(i=%0d)')]);
      iL = [iS(i+1); iL];
   else   % #L line exists
      tokens = strsplit(speclines{iL(1)}, ' ');
      num_cols = length(tokens)-1;
      if (num_cols < 1)
         showinfo(['Warning:: no column information found for scan# ' ...
                   int2str(specdata(i).scannum) num2str(i,'(i=%0d)')]);
         continue
      end
      specdata(i).columnnames = tokens(2:end);
   
      % data lines
      num_rows = iS(i+1) - iL(1)-1;
      if (num_rows < 1)
         showinfo(['Warning:: no data found for scan # ', ...
                   int2str(specdata(i).scannum) num2str(i,'(i=%0d)')]);
      else
         ilines = (iL(1)+1):(iL(1)+num_rows);
         % remove comments in the data region
         icomment = strmatch('#', speclines(ilines));
         ilines(icomment) = [];
         try
            specdata(i).data = str2num(char(speclines(ilines)));
         catch
            showinfo(['error in parsing data for data set #' int2str(i)]);
         end
      end
   end
   
   % #P or #V or #G lines (between #S and #L lines)
   for j=(iS(i)+1):(iL(1)-1)
      if strncmp('#P ', speclines{j}, 3) || strncmp('#V ', speclines{j}, 3)
         eval(['specdata(i).' speclines{j}(4:end) ';']);
      end
      if strncmp('#G ', speclines{j}, 3)
         eval(speclines{j}(4:end));
      end
   end
end

if (num_scans == 0) % not a spec file
   specdata(1).scannum = 1;
   [pathstr, specdata(1).title, ext] = fileparts(specfile);
   specdata(1).data = loadxy(specfile);
   showinfo([specfile ' is not a SPEC file, found data: ' num2str(size(specdata(1).data), ...
                                                     '%ix%i')]);
   specdata(1).columnnames = num2lege(1:length(specdata.data(1,:)), 'col#');
end