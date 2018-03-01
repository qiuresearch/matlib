function siq = iqcalc_all(atoms, varargin);
% --- Usage:
%        siq = iq_calcatoms(atoms, varargin);
% --- Purpose:
%        calculate the scattering intensities with the Debye formula.
%        Return: siq - a structure containing I(Q)s from various methods
%
% --- Parameter(s):
%        atoms - atom structure or PDB file name
%     varargin - 'verbose': 1 (default)
%                'q': 0:0.004:1.0 (default). the vector to calculate
%                're_calc': 0 (default). Read the data file if
%                           present instead of re_calculating
%                'save_iq': 0 (default)
%                'pdbfile': file name (no suffix) for saving pdb and I(Q) data
%
% --- Example(s):
%
% $Id: iqcalc_all.m,v 1.2 2012/02/07 00:09:52 xqiu Exp $
%

if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

verbose = 1;
re_calc = 0;
save_iq = 0;
q = linspace(0, 1.0, 256);
parse_varargin(varargin);

% get the atoms if a PDF file name passed
if ischar(atoms);
   [pathstr, name, ext] = fileparts(atoms);
   siq.pdbfile = name;
   siq.ext = ext;
   siq.atoms = atoms_readpdb([siq.pdbfile ext]);
   % only used DNA and proteins (can include 5: sugar)
   siq.atoms = atoms_select(atoms, 'restype', [1,2]);
else 
   if exist('pdbfile', 'var') && ischar(pdbfile)
      siq.pdbfile = pdbfile;
   else
      siq.pdbfile = 'iqcalc_all';
   end
   siq.ext = '.pdb';
   siq.atoms = atoms;
   atoms_writepdb(siq.atoms, [siq.pdbfile siq.ext]);
   showinfo(['saving atoms to PDB file: ' siq.pdbfile siq.ext]);
end

% Calculating or reading from previously saved files

% My matlab routine
iqfile = [siq.pdbfile '_xqiu.iq'];
if (re_calc == 0) && exist(iqfile, 'file')
   siq.iq = loadxy([pdbfile '_xqiu.iq']);
else
   [siq.iq, siq.iq_spec] = iq_calcatoms(siq.atoms, 'q', q);
   if (save_iq == 1)
      specdata_savefile(siq.iq_spec, iqfile');
      showinfo(['saving I(Q) data to file: ' iqfile]);
   end
end

% crysol
iqfile = [siq.pdbfile '_crysol.iq'];
if (re_calc == 0) && exist(iqfile, 'file');
   siq.iq_crysol = loadxy(iqfile);
else
   [siq.iq_crysol, siq.iq_crysol_spec] = crysol_runcfg([siq.pdbfile ...
                       siq.ext], 'cleanup');
   if (save_iq == 1)
      specdata_savefile(siq.iq_crysol_spec, iqfile');
      showinfo(['saving I(Q) data to file: ' iqfile]);
   end
end

% SASTBX Debye
iqfile = [siq.pdbfile '_sastbx_debye.iq'];
if exist(iqfile, 'file');
   siq.iq_sastbx_debye = loadxy(iqfile);
else
   % can not calculate yet
end

% SASTBX SHE
iqfile = [siq.pdbfile '_sastbx_she.iq'];
if exist(iqfile, 'file');
   siq.iq_sastbx_she = loadxy(iqfile);
else
   % can not calculate yet
end

% SASTBX zernike
iqfile = [siq.pdbfile '_sastbx_zernike.iq'];
if exist(iqfile, 'file');
   siq.iq_sastbx_zernike = loadxy(iqfile);
else
   % can not calculate yet
end
