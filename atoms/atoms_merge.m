function atoms_new = atoms_merge(atoms)
% --- Usage:
%        atoms_new = atoms_merge(atoms)
% --- Purpose:
%        merge multiple atomic structures
% --- Parameter(s):
%        atoms  - an array of atoms structure to merge
%
% --- Return(s):
%        atoms_new - the new structure
%
% --- Example(s):
%
% $Id: atoms_merge.m,v 1.3 2014/03/19 17:15:39 schowell Exp $
%

% 1) Simple check on input parameters

if nargin < 1
   help atoms_merge
   return
end

% 2) initialize the first
atoms_new = atoms(1);
num_groups = length(atoms);
if (num_groups == 1)
   return
end

% 3) copy the rest
for i=2:num_groups
   atoms_new.type = cat(1,atoms_new.type, atoms(i).type);
   atoms_new.serialno = cat(1, atoms_new.serialno, ...
                            atoms_new.serialno(end)+ atoms(i).serialno);
   atoms_new.name = cat(1,atoms_new.name, atoms(i).name);
   atoms_new.element = cat(1, atoms_new.element, atoms(i).element);
   atoms_new.altloc = cat(1, atoms_new.altloc, atoms(i).altloc);
   atoms_new.resname = cat(1, atoms_new.resname, atoms(i).resname);
   atoms_new.chainid = cat(1, atoms_new.chainid, atoms(i).chainid);
   atoms_new.seqno = cat(1, atoms_new.seqno, atoms(i).seqno);
   atoms_new.position = cat(1,atoms_new.position, atoms(i).position);
   
   % non-standard fields
   if isfield(atoms_new, 'exclvolume')
      atoms_new.exclvolume = cat(1,atoms_new.exclvolume, atoms(i).exclvolume);
      atoms_new.radius_sol = cat(1,atoms_new.radius_sol, atoms(i).radius_sol);
      atoms_new.z_vac = cat(1,atoms_new.z_vac, atoms(i).z_vac);
      atoms_new.z_sol = cat(1,atoms_new.z_sol, atoms(i).z_sol);
      atoms_new.mol_weight = cat(1,atoms_new.mol_weight, atoms(i).mol_weight);
   end
   if isfield(atoms_new, 'z')
      atoms_new.z = cat(1, atoms_new.z, atoms(i).z);
   end
end
