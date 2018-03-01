function sIqgetx = iqgetx_readsetup_imageplate(setupfile, varargin)
% --- Usage:
%        sIqgetx = iqgetx_readsetup_imageplate(setupfile, varargin)
% --- Purpose:
%        read a setupfile to compile the IqGetX structure array. This
%        routine assumes the format as: 
%           #L x label prefix time X_cen Y_cen X_ring Y_ring title
%
% --- Parameter(s):
%
% --- Return(s): 
%        sIqgetx - 
%
% --- Example(s):
%
% $Id: iqgetx_readsetup_imageplate.m,v 1.7 2013/08/19 03:02:25 xqiu Exp $
%

if (nargin < 1)
   help iqgetx_readsetup_imageplate
   return
end
verbose = 0;
readiq = 1;
parse_varargin(varargin);

% 2) read the file
setupdata = cellarr_readascii(setupfile);
if isempty(setupdata); 
   showinfo('Empty setup file, please check!');
   return; 
end

% 3) parse the setupdata

% remove all comments
setupdata = strtrim(setupdata);
ipound = ~strncmp(setupdata, '#', 1);
idata_start = strmatch('#L ', setupdata);
if isempty(idata_start)
   disp(['#L is not found in the setup file: ' setupfile ', exit!'])
   return
end
ipound(idata_start) = 1;
setupdata = setupdata(ipound);

% separate the general configuration and data entries
idata_start = strmatch('#L', setupdata);
matlab_codes = setupdata(1:(idata_start-1));
data_entries = setupdata((idata_start+1):end);

% run the matlab codes
sOpt.dezinger=0;
for i=1:length(matlab_codes); eval(matlab_codes{i}); end
if isfield(sOpt, 'dark_iq') && ischar(sOpt.dark_iq);
   sOpt.dark_iq = loadxy(sOpt.dark_iq);
end
if isfield(sOpt, 'bkg_iq') && ischar(sOpt.bkg_iq);
   sOpt.bkg_iq = loadxy(sOpt.bkg_iq);
end

% extract the data entries
templ_iqgetx = iqgetx_init_imageplate();
data_entries = strrep(data_entries, sprintf('\t'), ' ');
for i=1:length(data_entries);
   tokens = strsplit(data_entries{i}, ' ');
   if length(tokens) < 11
      disp(['not enough tokens in line -->' data_entries{i}])
      continue
   end
   templ_iqgetx.i= i;
   templ_iqgetx.label = strtrim(tokens{1});
   templ_iqgetx.x = str2num(tokens{2});
   templ_iqgetx.prefix = strtrim(tokens{3});
   templ_iqgetx.expotime = str2num(tokens{4});
   templ_iqgetx.Spec_to_Phos = str2num(tokens{5});
   templ_iqgetx.X_cen = str2num(tokens{6});
   templ_iqgetx.Y_cen = str2num(tokens{7});
   templ_iqgetx.autoalign_isa = str2num(tokens{8});
   templ_iqgetx.dspacing = str2num(tokens{9});
   templ_iqgetx.X_ring = str2num(tokens{10});
   templ_iqgetx.Y_ring = str2num(tokens{11});
   templ_iqgetx.title = strtrim(sprintf('%s ', tokens{12:end}));

   iqfile = ['iqdata/' templ_iqgetx.label '.iq'];
   if (readiq == 1) && exist(iqfile, 'file')
      templ_iqgetx.iq = load('-ascii', iqfile);
      showinfo(['Load I(Q) data: ' iqfile]);
   end
   templ_iqgetx = struct_assign(sOpt, templ_iqgetx);
   sIqgetx.names{i} = tokens{1};
   sIqgetx.lengths(i) = 1;
   if (verbose == 1)
      tokens
   end
   eval(['sIqgetx.' strtrim(tokens{1}) '= templ_iqgetx;']);
end
