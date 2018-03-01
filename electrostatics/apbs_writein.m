function apbsin = apbs_writein(sAPBS, fname, varargin)
% --- Usage:
%        sAPBS = apbs_writein(fname, varargin)
% --- Purpose:
%        write the APBS input file for apbs running
% --- Parameter(s):
%
% --- Return(s): 
%        apbsin - the cell array same as the in file
%
% --- Example(s):
%
% $Id: apbs_writein.m,v 1.4 2012/06/16 16:43:24 xqiu Exp $
%

% 1) default settings and initialize some fields
verbose = 1;
parse_varargin(varargin)
if ~exist('fname', 'var') % default in file name
   fname = [sAPBS.name '.in'];
end

% 2) generate the cell array
indent = '    ';

% read
apbsin{1} = 'read';
for i=1:length(sAPBS.mol)
   apbsin = [apbsin, {[indent 'mol ' sAPBS.mol(i).format ' ' ...
                       sAPBS.mol(i).fname]}];
end
apbsin = [apbsin, {'end'}];

% elec
apbsin = [apbsin, {['elec name ' sAPBS.name]}];
apbsin = [apbsin, {[indent sAPBS.mode]}];
apbsin = [apbsin, {[indent 'mol' sprintf(' %d', sAPBS.mol_use)]}];
apbsin = [apbsin, {[indent 'dime' sprintf(' %d', sAPBS.dime)]}];
if isfield(sAPBS, 'fglen')
   apbsin = [apbsin, {[indent 'fglen' sprintf(' %0.2f', sAPBS.fglen)]}];
   if (length(sAPBS.fgcent) == 1)
      apbsin = [apbsin, {[indent 'fgcent mol ' num2str(sAPBS.fgcent)]}];
   else
      apbsin = [apbsin, {[indent 'fgcent' sprintf(' %0.2f', sAPBS.fgcent)]}];
   end
end
if isfield(sAPBS, 'cglen')
   apbsin = [apbsin, {[indent 'cglen' sprintf(' %0.2f', sAPBS.cglen)]}];
   if (length(sAPBS.cgcent) == 1)
      apbsin = [apbsin, {[indent 'cgcent mol ' num2str(sAPBS.cgcent)]}];
   else
      apbsin = [apbsin, {[indent 'cgcent' sprintf(' %0.2f', sAPBS.cgcent)]}];
   end
end
if (sAPBS.npbe == 1)
   apbsin = [apbsin, {[indent 'npbe']}];
else
   apbsin = [apbsin, {[indent 'lpbe']}];
end
apbsin = [apbsin, {[indent 'bcfl ' sAPBS.bcfl]}];
for i=1:length(sAPBS.ion)
   apbsin = [apbsin, {[indent 'ion' sprintf(' charge %d conc %0.10g radius %0.2f', ...
                                            sAPBS.ion(i).z, ...
                                            sAPBS.ion(i).n, sAPBS.ion(i).r)]}];
end
apbsin = [apbsin, {[indent 'pdie ' num2str(sAPBS.pdie, '%0.2f')]}];
apbsin = [apbsin, {[indent 'sdie ' num2str(sAPBS.sdie, '%0.2f')]}];
apbsin = [apbsin, {[indent 'chgm ' sAPBS.chgm]}];
apbsin = [apbsin, {[indent 'srfm ' sAPBS.srfm]}];
apbsin = [apbsin, {[indent 'srad ' num2str(sAPBS.srad, '%0.2f')]}];
apbsin = [apbsin, {[indent 'swin ' num2str(sAPBS.swin, '%0.2f')]}];
apbsin = [apbsin, {[indent 'sdens ' num2str(sAPBS.sdens, '%0.2f')]}];
apbsin = [apbsin, {[indent 'temp ' num2str(sAPBS.T, '%0.2f')]}];
%apbsin = [apbsin, {[indent 'gamma ' num2str(sAPBS.gamma, '%0.3f')]}];
apbsin = [apbsin, {[indent 'calcenergy ' sAPBS.calcenergy]}];
apbsin = [apbsin, {[indent 'calcforce ' sAPBS.calcforce]}];
%apbsin = [apbsin, {[indent 'write qdens dx ' sAPBS.name '_qdens']}];
apbsin = [apbsin, {[indent 'write pot dx ' sAPBS.name '_pot']}];
apbsin = [apbsin, {[indent 'write ivdw dx ' sAPBS.name '_iacc']}];
switch sAPBS.srfm
   case 'smol'
      apbsin = [apbsin, {[indent 'write smol dx ' sAPBS.name '_sacc']}];
   case 'mol'
      apbsin = [apbsin, {[indent 'write vdw dx ' sAPBS.name '_sacc']}];
   otherwise
      warning('solvent accessibility matrix is not saved!')
end
apbsin = [apbsin, {'end'}];

% quit
apbsin = [apbsin, {'quit'}];

% 3) write to the file
showinfo(['save input to file: ' fname]);
fid = fopen(fname, 'w');
fprintf(fid, '%s\n', apbsin{:});
fclose(fid);
