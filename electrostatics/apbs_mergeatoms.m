function sAPBS = apbs_mergeatoms(sAPBS, varargin)
% --- Usage:
%        sAPBS = apbs_mergeatoms(sAPBS, varargin)
% --- Purpose:
%        add the ions and the solvent atoms (if exist) to the molecule
%        structure.
%
% --- Parameter(s):
%        sAPBS - the APBS structure with corresponding fields
%      
%        ions - 1 or 0, whether to merge ions
%        solvent - 1 or 0, whether to merge solvent
% --- Return(s):
%        sAPBS - sAPBS.mol, sAPBS.ion will have a new field
%        "atoms". The merged atoms will be sAPBS.atoms
%
% --- Example(s):
%
% $Id: apbs_mergeatoms.m,v 1.3 2012/06/16 16:43:24 xqiu Exp $
%

% 1) check parameters
verbose = 1; remove_hydrogen = 1; % remove before merging ion and sovent!
ions = 1; solvent = 1;
parse_varargin(varargin)

rho_solvent = rho_solvent_ions(sAPBS.ion);

% 2) get the molecule 
for i=1:length(sAPBS.mol)
   if isfield(sAPBS.mol(i), 'atoms') && ~isempty(sAPBS.mol(i).atoms); 
      continue; 
   end
   fname = sAPBS.mol(i).fname;
   [dummy, fname_noext] = fileparts(fname);
   if exist([fname_noext '.pdb'], 'file')  % read PDB file if possible
      fname = [fname_noext '.pdb'];
      showinfo(['PDB file <' fname '> exists, PQR not read!!!'])
   else
      if ~exist(fname, 'file')
         showinfo('not PDB or PQR files found!!!', 'ERROR')
      end
   end
   % read and remove H atoms
   sAPBS.mol(i).atoms = atoms_select(atoms_readpdb(fname, 'rho_solvent', ...
                                                   rho_solvent), ...
                                     'element', 'H', 'invert', 1);
end
sAPBS.atoms = atoms_merge([sAPBS.mol.atoms]);

% remove all H* atoms
if (remove_hydrogen == 1)
   [sAPBS.atoms, index] = atoms_select(sAPBS.atoms, 'element', 'H', ...
                                       'invert', 1);
   if (length(index) > 0)
      showinfo(['remove ' num2str(length(index)) ' unused H atoms!'])
   end
end

% 3) get the shifts of the ions and solvent
gcent = [0, 0, 0];
if isfield(sAPBS, 'fgcent') % fine grid center
   gcent = sAPBS.fgcent;
end
if isfield(sAPBS, 'gcent') % only one grid used
   gcent = sAPBS.gcent;
end
% ---- DISABLE it NOW!!! ----
if (length(gcent) == 1) % only adjust when molecule is re-centered
%   mol_center = mean(sAPBS.mol(gcent).atoms.position, 1);
%   box_center = sAPBS.xyzmin + (sAPBS.dime-1)/2*sAPBS.delta;
%   xyz_shift = mol_center - box_center;
end   
   
% 4) add the ion atoms
if isfield(sAPBS.ion(1), 'atoms') && (ions == 1)
   atoms_ions = atoms_merge([sAPBS.ion.atoms]);
   if exist('xyz_shift', 'var')
      atoms_ions = atoms_move(atoms_ions, xyz_shift, 'verbose');
   end
   sAPBS.atoms = atoms_merge([sAPBS.atoms, atoms_ions]);
   showinfo(['merge ions to molecule, total num: ' ...
             int2str(length(atoms_ions.element))]);
end

% 5) add the solvent atoms
if isfield(sAPBS, 'solvent') && (solvent == 1) && isfield(sAPBS.solvent, ...
                                                     'atoms')
   atoms_sol = sAPBS.solvent.atoms;
   if exist('xyz_shift', 'var')
      atoms_sol = atoms_move(atoms_sol, xyz_shift, 'verbose');
   end
   sAPBS.atoms = atoms_merge([sAPBS.atoms, atoms_sol]);
   showinfo(['merge solvent atoms, total num: ' ...
             int2str(length(atoms_sol.element))]);
end
