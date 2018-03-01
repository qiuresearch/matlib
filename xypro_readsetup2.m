function setupdata = setup_readfile(setupfile)
% --- Usage:
%        setupdata = setup_readfile(setupfile)
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
% $Id: xypro_readsetup2.m,v 1.1 2013/08/23 19:16:11 xqiu Exp $
%
verbose = 1;
% 1) check the setupfile
if nargin < 1
   error('at least one parameter is required, please see the usage! ')
   help setupdata_readfile
   return
end

if ~ exist(setupfile, 'file')
   error(['spec file: ' setupfile ' does not exist!'])
   return
end

% 2) read the spec file, and remove useless lines

runit = fopen(setupfile, 'r');
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

% 3) parse the lines before #L and save to a structure

iS = strmatch('#S', speclines);
iL = strmatch('#L', speclines);
if (length(iS) ~= length(iL))
   showinfo(['WARNING:: numbers of #S and #L do not match for ' setupfile]);
end

num_scans = length(iL);
setupdata = repmat(struct('scannum', 0.0, 'title', ''), 1, num_scans);

iS = [iS; length(speclines)+1]; % artifical addition to get the
                                % last data easily
for i=1:num_scans
   % #S line
   tokens = strsplit(speclines{iS(i)}, ' ');
   if (length(tokens) > 2)
      setupdata(i).scannum = str2num(tokens{2});
      itmp = strfind(speclines{iS(i)}, tokens{3});
      setupdata(i).title = speclines{iS(i)}(itmp(1):end);
   end
   
   % #P and #V lines
   for j=(iS(i)+1):(iL(i)-1)
      if strncmp('#P ', speclines{j}, 3) || strncmp('#V ', speclines{j}, 3)
         eval(['setupdata(i).' speclines{j}(4:end) ';']);
      end
   end

   % #L line
   tokens = strsplit(speclines{iL(i)}, ' ');
   num_cols = length(tokens)-1;
   if (num_cols < 1)
      showinfo(['Warning:: no column information found for scan #', int2str(i), ' in SPEC file: ', setupfile]);
      continue
   end
   setupdata(i).columnnames = tokens(2:end);
   
   % data: each line gives a new structure
   num_rows = iS(i+1) - iL(i)-1;
   if (num_rows < 1)
      showinfo(['Warning:: no data found for scan #', int2str(i), ' in SPEC file: ' setupfile]);
      continue
   end
   for k=1:num_rows
      setupdata(k) = setupdata(1);
      for icol=1:num_cols
         str2value
         eval(['setupdata(k).' setupdata(i).columnnames{icol} '=' speclines{k+iL(i)} ';']);
      end
   end
end

if (num_scans == 0) % not a spec file
   setupdata(1).scannum = 1;
   setupdata(1).title = setupfile;
   setupdata(1).data = loadxy(setupfile);
   setupdata(1).columnnames = num2lege(1:length(setupdata.data(1,:)), 'col#');;
end