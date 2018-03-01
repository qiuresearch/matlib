function sAPBS = apbs_readall(fname, varargin)
% --- Usage:
%        sAPBS = apbs_readall(fname, varargin)
% --- Purpose:
%        read in some relevant output files from APBS run based on my
%        own convention. Files to be looked for are: 1) fname.in, 2)
%        fname_pot.dx, 3) fname_qdens.dx (not by default), 4)
%        fname_iacc.dx 5) fname_sacc.dx
% --- Parameter(s):
%
% --- Return(s): 
%        sAPBS - the APBS data structure
%
% --- Example(s):
%
% $Id: apbs_readall.m,v 1.4 2012/07/24 13:47:11 xqiu Exp $
%

% 1) default settings
verbose = 0;
in = 1;
pot = 1;
qdens = 0;
iacc = 1;
sacc = 1;
parse_varargin(varargin);

if ~exist('fname', 'var')
   fname = 'apbs';
end

% 2) read in files one by one

% fname.in
if (in == 1)
   sAPBS = apbs_readin([fname '.in']);
end

% fname_pot.dx
if (pot == 1)
   sAPBS = struct_assign(apbs_readdx(dxfile_get(fname, '_pot')), ...
                         sAPBS, 'append', 1);
   sAPBS.pot = sAPBS.data;
end

% fname_qdens.dx
if (qdens ==1)
   sAPBS = struct_assign(apbs_readdx(dxfile_get(fname, '_qdens')), ...
                         sAPBS, 'append', 1);
   sAPBS.qdens = sAPBS.data;
end

% fname_iacc.dx: ion accessibility 
if (iacc == 1)
   sAPBS = struct_assign(apbs_readdx(dxfile_get(fname, '_iacc')), ...
                         sAPBS, 'append', 1);
   sAPBS.iacc = sAPBS.data;
end

% fnmae_sacc.dx: solvent accessibility
if (sacc == 1)
   sAPBS = struct_assign(apbs_readdx(dxfile_get(fname, '_sacc')), ...
                         sAPBS, 'append', 1);
   sAPBS.sacc = sAPBS.data;
end

sAPBS = rmfield(sAPBS, 'data');

   function dxfile=dxfile_get(prefix, suffix)
   dxfile = [fname suffix '.dx'];
   if ~exist(dxfile, 'file')
      dxfile = dir([fname '*' suffix '*.dx']);
      if ~isempty(dxfile); dxfile = dxfile(1).name; end
   end
   end
end
