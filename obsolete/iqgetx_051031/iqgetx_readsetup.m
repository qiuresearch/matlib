function sIqgetx = iqgetx_readsetup(setupfile, mode)
% --- Usage:
%        sIqgetx = iqgetx_readsetup(setupfile)
% --- Purpose:
%        read a setupfile to compile the IqGetX structure array
%
% --- Parameter(s):
%     
% --- Return(s): 
%        sIqgetx - 
%
% --- Example(s):
%
% $Id: iqgetx_readsetup.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $
%

if nargin < 1
   help iqgetx_readsetup
   return
end
if nargin < 2
   mode=1; 
end

% 2) read the file
setupdata = cellarr_readascii(setupfile);
if isempty(setupdata); return; end

% 3) parse the setupdata

% remove all comments
setupdata = strtrim(setupdata);
ipound = ~strncmp(setupdata, '#', 1);
idata_start = strmatch('#L', setupdata);
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
sOpt.dezinger=1;
for i=1:length(matlab_codes); eval(matlab_codes{i}); end

% extract the data entries
switch mode
   case 1
      templ_iqgetx = struct_assign(sOpt, iqgetx_init());
   case 2
      templ_iqgetx = struct_assign(sOpt, iqgetx2_init());
   otherwise
end
for i=1:length(data_entries);
   tokens = strsplit(data_entries{i}, ' ');
   if length(tokens) < 7
      disp(['not enough tokens in line -->' data_entries{i}])
      continue
   end
   templ_iqgetx.x = str2num(tokens{1});
   templ_iqgetx.label = strtrim(tokens{2});
   templ_iqgetx.prefix = strtrim(tokens{3});
   templ_iqgetx.time = str2num(tokens{4});
   templ_iqgetx.skipnums = eval(tokens{6});
   templ_iqgetx.title = strtrim(sprintf('%s ', tokens{7:end}));

   startnums = eval(tokens{5});
   dummy_iqgetx = repmat(templ_iqgetx, 1, length(startnums));
   for k=1:length(dummy_iqgetx)
      dummy_iqgetx(k).startnum = startnums(k);
      dummy_iqgetx(k).title = [dummy_iqgetx(k).title ' (' ...
                          int2str(startnums(k)) ')'];
   end
   
   sIqgetx.names{i} = tokens{2};
   sIqgetx.lengths(i) = length(startnums);
   eval(['sIqgetx.' strtrim(tokens{2}) '= dummy_iqgetx;']);
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% --- Change History:
%
% $Log: iqgetx_readsetup.m,v $
% Revision 1.1.1.1  2007-09-19 04:45:38  xqiu
% A new start of my matlab library with new directory structure.
%
% Revision 1.2  2005/06/09 01:52:38  xqiu
% Major changes to the designing!
%
% Revision 1.1  2005/04/29 14:42:49  xqiu
% Initialize the iqgetx standalone package!
%
% Revision 1.2  2004/11/19 05:04:26  xqiu
% Added comments
%
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%


                        