function sIqgetx = iqgetx_readsetup(setupfile, mode, varargin)
% --- Usage:
%        sIqgetx = iqgetx_readsetup(setupfile, mode)
% --- Purpose:
%        read a setupfile to compile the IqGetX structure
%        array. This routine assumes the format as:
%
% --- Parameter(s):
%        mode - 1: #L x label prefix time startnum skipnums title
%               2: #L x label prefix time buf1nums samnums buf2nums title
%               3: #L x label prefix time darknums buf1nums samnums buf2nums title
%               4: #L x label time samprefix samnums bufprefix bufnums title
%
%
% or 2. "1" uses iqgetx_init(), "2" ->
%                iqgetx2_init()
% --- Return(s): 
%        sIqgetx - 
%
% --- Example(s):
%
% $Id: iqgetx_readsetup.m,v 1.7 2013/12/17 20:37:06 xqiu Exp $
%

if (nargin < 1)
   help iqgetx_readsetup
   return
end
if (nargin < 2)  
   mode=1; % 1: before and after buffer are separated, 2: one
           % buffer data only
end

% 2) read the file
setupdata = cellarr_readascii(setupfile);
if isempty(setupdata); 
   showinfo('Empty setup file, please check!');
   return; 
end

% 3) parse the setupdata

% remove all comments
setupdata = cellempty(strtrim(setupdata));
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
sOpt.dezinger=1; % also serves to re-initialize sOpt
for i=1:length(matlab_codes); eval(matlab_codes{i}); end

% extract the data entries
data_entries = strrep(data_entries, sprintf('\t'), ' ');
switch mode
   case 1 % #L x label prefix time startnum skipnums title
      templ_iqgetx = struct_assign(sOpt, iqgetx_init('onebuf'), 'append',1);
      for i=1:length(data_entries);
         tokens = strsplit(data_entries{i}, ' ');
         if length(tokens) < 7
            disp(['not enough tokens in line -->' data_entries{i}])
            continue
         end
         templ_iqgetx.x = str2num(tokens{1});
         templ_iqgetx.label = strtrim(tokens{2});
         templ_iqgetx.samprefix = strtrim(tokens{3});
         templ_iqgetx.bufprefix = strtrim(tokens{3});
         templ_iqgetx.expotime = str2num(tokens{4});
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
   case 2 % #L x label prefix time buf1nums samnums buf2nums title
      templ_iqgetx = struct_assign(sOpt, iqgetx_init('twobuf'), 'append', 1);
      for i=1:length(data_entries);
         tokens = strsplit(data_entries{i}, ' ');
         if length(tokens) < 7
            disp(['not enough tokens in line -->' data_entries{i}])
            continue
         end
         templ_iqgetx.x = str2num(tokens{1});
         templ_iqgetx.label = strtrim(tokens{2});
         templ_iqgetx.samprefix = strtrim(tokens{3});
         templ_iqgetx.bufprefix = strtrim(tokens{3});
         templ_iqgetx.expotime = str2num(tokens{4});
         templ_iqgetx.title = strtrim(sprintf('%s ', tokens{8:end}));
         
         templ_iqgetx.buf1nums = eval(tokens{5});
         templ_iqgetx.samnums = eval(tokens{6});
         templ_iqgetx.buf2nums = eval(tokens{7});
         
         sIqgetx.names{i} = tokens{2};
         sIqgetx.lengths(i) = 1;
         eval(['sIqgetx.' strtrim(tokens{2}) '= templ_iqgetx;']);
      end
   case 3 % #L x label prefix time darknums buf1nums samnums buf2nums title
      templ_iqgetx = struct_assign(sOpt, iqgetx_init('twobuf'), 'append', 1);
      for i=1:length(data_entries);
         tokens = strsplit(data_entries{i}, ' ');
         if length(tokens) < 7
            disp(['not enough tokens in line -->' data_entries{i}])
            continue
         end
         templ_iqgetx.x = str2num(tokens{1});
         templ_iqgetx.label = strtrim(tokens{2});
         templ_iqgetx.samprefix = strtrim(tokens{3});
         templ_iqgetx.bufprefix = strtrim(tokens{3});
         templ_iqgetx.expotime = str2num(tokens{4});
         templ_iqgetx.title = strtrim(sprintf('%s ', tokens{9:end}));
         
         templ_iqgetx.darknums = eval(tokens{5});
         templ_iqgetx.buf1nums = eval(tokens{6});
         templ_iqgetx.samnums = eval(tokens{7});
         templ_iqgetx.buf2nums = eval(tokens{8});
         templ_iqgetx.darknums = eval(tokens{5}); 
         
         sIqgetx.names{i} = tokens{2};
         sIqgetx.lengths(i) = 1;
         eval(['sIqgetx.' strtrim(tokens{2}) '= templ_iqgetx;']);
      end
   case 4 % #L x label time samprefix samnums bufprefix bufnums title
      templ_iqgetx = struct_assign(sOpt, iqgetx_init('onebuf'), 'append', 1);
      
      % read the spec file if necessary
      if ~isempty(templ_iqgetx.specfile)
         disp(['reading SPEC data file: ' templ_iqgetx.specfile])
         templ_iqgetx.specdata = specdata_readfile(templ_iqgetx.specfile);
      end
      
      for i=1:length(data_entries);
         tokens = strsplit(data_entries{i}, ' ');
         if length(tokens) < 7
            disp(['not enough tokens in line -->' data_entries{i}])
            continue
         end
         %   data_entries{i}
         templ_iqgetx.x = str2num(tokens{1});
         templ_iqgetx.label = strtrim(tokens{2});
         templ_iqgetx.expotime = str2num(tokens{3});
         templ_iqgetx.samprefix = strtrim(tokens{4});
         templ_iqgetx.samnums = eval(tokens{5});
         templ_iqgetx.bufprefix = strtrim(tokens{6});
         templ_iqgetx.bufnums = eval(tokens{7});
         templ_iqgetx.title = strtrim(sprintf('%s ', tokens{8:end}));
         
         sIqgetx.names{i} = tokens{2};
         sIqgetx.lengths(i) = 1;
         eval(['sIqgetx.' strtrim(tokens{2}) '= templ_iqgetx;']);
      end
   otherwise
end
