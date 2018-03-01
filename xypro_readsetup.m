function xypro = xypro_readsetup(setupfile, mode)
% --- Usage:
%        xypro = iqfit_readsetup(setupfile, mode)
% --- Purpose:
%        read a setupfile to the xypro format.
%
% --- Parameter(s):
%        mode - 1: #L x label prefix time startnum skipnums title
%
% --- Return(s): 
%        xypro - 
%
% --- Example(s):
%
% $Id: xypro_readsetup.m,v 1.2 2013/08/23 18:52:47 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end
if (nargin < 2)  
   mode=1; % 1: 
end

% 2) read the file
setupdata = cellarr_readascii(setupfile);
if isempty(setupdata); 
   showinfo('Empty setup file, please check!');
   return; 
end

% 3) parse the setupdata

% remove all comments
setupdata = cellempty(strtrim(setupdata));   % remove empty lines
ipound = ~strncmp(setupdata, '#', 1);        % find the comments
idata_start = strmatch('#L', setupdata);     % find start of data indicator
if isempty(idata_start)                      % make sure indicator exists
   disp(['#L is not found in the setup file: ' setupfile ', exit!'])
   return
end
ipound(idata_start) = 1;                     % keep start of data line
setupdata = setupdata(ipound);               % remove lines beginning with '#'

% separate the general configuration and data entries
idata_start = strmatch('#L', setupdata);     % find start of data indicator
matlab_codes = setupdata(1:(idata_start-1)); % do the separation
data_entries = setupdata((idata_start+1):end);

% run the matlab codes
sOpt.normconst=1; % also serves to re-initialize sOpt
for i=1:length(matlab_codes); eval(matlab_codes{i}); end

% extract the data entries
xypro = [];
data_entries = strrep(data_entries, sprintf('\t'), ' '); %replace tab with space
switch mode
   case 1 % #L num prefix x n(mM) Dmax mw xmin xmax guinier legend
      templ_xypro = xypro_init();
      
      templ_xypro = struct_assign(sOpt, templ_xypro, 'append');
      for i=1:length(data_entries);
         tokens = strsplit(data_entries{i}, ' ');
         if length(tokens) < 7
            disp(['not enough tokens in line -->' data_entries{i}])
            continue
         end
         templ_xypro.id = str2num(tokens{1});
         templ_xypro.prefix = strtrim(tokens{2});
         templ_xypro.filename = [templ_xypro.datadir templ_xypro.prefix ...
                             templ_xypro.suffix];
         templ_xypro.ionstrength = str2num(tokens{3});
         templ_xypro.concentration = str2num(tokens{4});
         templ_xypro.dmax = str2num(tokens{5});
         templ_xypro.molweight = str2num(tokens{6});
         templ_xypro.xmin = str2num(tokens{7});
         templ_xypro.xmax = str2num(tokens{8});
         templ_xypro.guinier_range = str2num(tokens{9});
         templ_xypro.title = strtrim(sprintf('%s ', tokens{10:end}));
         
         if isempty(xypro)
            xypro = templ_xypro;
         else
            xypro = [xypro, templ_xypro];
         end
      end
  otherwise
    disp([' Not supported yet!']);
end
