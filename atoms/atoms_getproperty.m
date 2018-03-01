function atoms = atoms_getproperty(atoms, varargin)
% --- Usage:
%        atoms = atoms_getproperty(atoms, varargin)
% --- Purpose:
%        look up a built-in table for atomic properties based on the
%        atoms.element. Checking order is: 1) nucleic acid, 2) general
%        SAS type, 3) give up
%
% --- Parameter(s):
%        atoms - a structure of arrays (refer to atoms_readpdb.m for details)
%        
%        rho_solvent - the electron density of the solvent
%                      (default: 0.334611 (water))
%        volume_factor - the multiplication factor to volume
%                        (default: 0.93 is found to match crysol data best)
% --- Return(s):
%        atoms - new fields atoms.z_vac, atoms.z_sol,
%        atoms.exclvolume, atoms.radius_sol
%
% --- Calling Method(s):
%
% --- Example(s):
%
% $Id: atoms_getproperty.m,v 1.4 2013/04/03 16:04:26 xqiu Exp $
% RATE: 3.0
%

global atomdb_isvalid atomdb_num atomdb_sym atomdb_const atomdb_sas ...
    atomdb_nucleic atomdb_protein atomdb_sugar atomdb_asfcoeftb ...
    atomdb_compcoeftb atomdb_macoeftb atomdb_bindenergytb ...
    atomdb_xxsectiontb atomdb_f1f2coeftb

if ( isempty(atomdb_isvalid) || (atomdb_isvalid == 0) )
  if ~atomdb_initialize();
    error('the atomdb property data base initialization fault!');
    return
  end
end

% 1) Simple check on input parameters

if (nargin < 1)
  disp('ERROR:: an atoms structure of arrays should be provided!');
  return
end

verbose = 1;
rho_solvent = 0.334; %611;  % electron density of water
volume_factor = 1.0;
parse_varargin(varargin);

num_atoms = length(atoms.element);
atoms.restype = zeros(num_atoms, 1); % 1: DNA, 2: protein, 3: ions,
                                     % 4: water 5: sugar 6: others
atoms.restype_names = {'NucleicAcids', 'Protein', 'Ion', 'Water', ...
                    'Sugar', 'Others'};
atoms.exclvolume = zeros(num_atoms, 1);
atoms.radius_sol = zeros(num_atoms,1);
atoms.radius_crysol = zeros(num_atoms,1);
atoms.z_vac = zeros(num_atoms,1);
atoms.mol_weight = zeros(num_atoms,1);

% 2) Find the index of each atom in the property data base

index_todo = 1:num_atoms;

% --- search the index ---
%  For each type (nucleic acids/protein/etc/), resname is first
%  searched, then atom name is searched. 
% 
%  index_todo keeps all un-assigned atoms. When all atoms (in the
%  atoms.element) have been assigned indices. Search is done!

% a) check for nucleic acids (note that all single letter resnames in
% PDB have been converted to three letters in atoms_readpdb.m)
showinfo(['check ' num2str(length(index_todo)) ' atoms for nucleic ' ...
          'acids atom (group) ...']);
idb_resname = strindex(atoms.resname(index_todo,:), atomdb_nucleic.resname, ...
                       'exact'); % has the same size as index_todo
i_nucleic = find(idb_resname ~= 0); % keep all the indices of found
                                    % atoms relative to index_do
atoms.restype(index_todo(i_nucleic)) = 1;

showinfo([int2str(length(i_nucleic)) ' standard nucleic acids ' ...
          'residue names ...']);
if ~isempty(i_nucleic)
   idb_atmname = strindex(atoms.element(index_todo), atomdb_nucleic.name, ...
                          'exact');
    % atoms with matched resname, but unmatched atom name
   i_mismatch = find(idb_atmname(i_nucleic) == 0);
   if ~isempty(i_mismatch)
      showinfo([int2str(length(i_mismatch)) ' atoms with nucleic ' ...
               'acid resnames, but without standard atom names'], 'warning');
      disp(['      They are: ' ...
            strjoin(unique(atoms ...
                           .element(index_todo(i_nucleic(i_mismatch)))),', ')])
      disp(['           resnames are: ' ...
            strjoin(unique(mat2cell(atoms.resname(index_todo(i_nucleic(i_mismatch)),:), ...
                                 ones(length(i_mismatch), 1), 3)), ',')])
      i_nucleic(i_mismatch) = [];
   end

   showinfo([int2str(length(i_nucleic)) ' standard nucleic acids atom (or ' ...
             'atom group) names ...']);
   
   % index to the sastype for the i_nucleic (of index_todo)
   idb_sastype = atomdb_nucleic.sastype((idb_resname(i_nucleic)-1)* ...
                                        atomdb_nucleic.num_rows + ...
                                        idb_atmname(i_nucleic));
   i_no_sastype = find(idb_sastype <= 0);
   if ~isempty(i_no_sastype)
      warning([num2str(length(i_no_sastype)) ' nucleic acid ' ...
               'atoms have PDB atom type <= 0!!!'])
      atoms.name(index_todo(i_nucleic(i_no_sastype)),:);
      i_nucleic(i_no_sastype);
      i_nucleic(i_no_sastype) = [];
      idb_sastype(i_no_sastype) = [];
   end
end

% process the nucleic acid atoms
if ~isempty(i_nucleic)
   showinfo([ 'Nucleic acids: ' num2str(length(i_nucleic)) ' atoms ' ...
                       '(or groups) found ...']);

   i_atoms = index_todo(i_nucleic);
   atoms.exclvolume(i_atoms) = atomdb_sas.exclvolume(idb_sastype);
   atoms.radius_sol(i_atoms) = atomdb_sas.radius_sol(idb_sastype);
   atoms.radius_crysol(i_atoms) = atomdb_sas.radius_crysol(idb_sastype);
   atoms.z_vac(i_atoms) = atomdb_sas.z(idb_sastype);
   atoms.mol_weight(i_atoms) = atomdb_sas.mol_weight(idb_sastype);
else
   showinfo('no nucleic acid atoms found!')
end

% check whether mission completed
index_todo(i_nucleic) = [];
if isempty(index_todo)
   showinfo('all atoms located, done!!!')
   atoms.z_sol = atoms.z_vac - rho_solvent*volume_factor*atoms.exclvolume;
   return
end

% b) check for protein (note that the branch number (4th letter) is
% not used by the CRYSOL convention)
showinfo(['check ' num2str(length(index_todo)) ' atoms for protein ' ...
          'atom (group) ...']);

idb_resname = strindex(atoms.resname(index_todo,:), atomdb_protein.resname, ...
                       'exact');    % has the same size as index_todo
i_protein = find(idb_resname ~= 0); % keep all the indices of found
                                    % atoms relative to index_do
atoms.restype(index_todo(i_protein)) = 2;
showinfo([int2str(length(i_protein)) ' standard protein residue ' ...
          'names ...']);
if ~isempty(i_protein)
   % Crysol appears to only use the first three characeters in the
   % name
   atmnames = strtrim(mat2cell(atoms.name(:, 1:4), ones(length(atoms.element),1), 4));
   idb_atmname = strindex(atmnames(index_todo), atomdb_protein.name, 'exact');
    % atoms with matched resname, but unmatched atom name
   i_mismatch = find(idb_atmname(i_protein) == 0);
   if ~isempty(i_mismatch)
      showinfo([int2str(length(i_mismatch)) ' atoms with protein ' ...
               'reside names, but without standard atom names'], 'warning');
      disp(['      They are: ' ...
            strjoin(unique(atoms ...
                           .element(index_todo(i_protein(i_mismatch)))),', ')])
      disp(['           resnames are: ' ...
            strjoin(unique(mat2cell(atoms.resname(index_todo(i_protein(i_mismatch)),:), ...
                                 ones(length(i_mismatch), 1), 3)), ',')])
       i_protein(i_mismatch) = [];
   end

   showinfo([int2str(length(i_protein)) ' standard protein atom (or ' ...
             'atom group) names ...']);
   
   % index to the sastype for the i_protein (of index_todo)
   idb_sastype = atomdb_protein.sastype((idb_resname(i_protein)-1)* ...
                                        atomdb_protein.num_rows + ...
                                        idb_atmname(i_protein));
   i_no_sastype = find(idb_sastype <= 0);
   if ~isempty(i_no_sastype)
      showinfo([num2str(length(i_no_sastype)) ' protein ' ...
               'atoms have PDB atom type <= 0!!!'], 'warning');
      disp(['      They are: ' ...
            strjoin(unique(atoms.element(index_todo(i_protein(i_no_sastype)))),' ,')])
      disp(['           resnames are: ' ...
            strjoin(unique(mat2cell(atoms.resname(index_todo(i_protein(i_no_sastype)),:), ...
                                 ones(length(i_no_sastype), 1), 3)), ',')])

      % I want to match only the atom now and disregard the resname
      
      i_protein(i_no_sastype);
      i_protein(i_no_sastype) = [];
      idb_sastype(i_no_sastype) = [];
   end
end

% process the protein atoms
if ~isempty(i_protein)
   showinfo([ 'Protein acids: ' num2str(length(i_protein)) ' atoms ' ...
                       '(or groups) found ...']);

   i_atoms = index_todo(i_protein);
   atoms.exclvolume(i_atoms) = atomdb_sas.exclvolume(idb_sastype);
   atoms.radius_sol(i_atoms) = atomdb_sas.radius_sol(idb_sastype);
   atoms.radius_crysol(i_atoms) = atomdb_sas.radius_crysol(idb_sastype);
   atoms.z_vac(i_atoms) = atomdb_sas.z(idb_sastype);   
   atoms.mol_weight(i_atoms) = atomdb_sas.mol_weight(idb_sastype);
else
   showinfo('no protein atoms found!')
end

% check whether mission completed
index_todo(i_protein) = [];
if isempty(index_todo)
   showinfo('all atoms located, done!!!')
   atoms.z_sol = atoms.z_vac - rho_solvent*volume_factor*atoms.exclvolume;
   return
end

% c) check for sugar atoms
showinfo(['check ' num2str(length(index_todo)) ' atoms for sugar ' ...
          'atom (group) ...']);
idb_resname = strindex(atoms.resname(index_todo,:), atomdb_sugar.resname, ...
                       'exact');  % has the same size as index_todo
i_sugar = find(idb_resname ~= 0); % keep all the indices of found
                                  % atoms relative to index_do
atoms.restype(index_todo(i_sugar)) = 5;

showinfo([int2str(length(i_sugar)) ' standard sugar ' ...
          'residue names ...']);
if ~isempty(i_sugar)
   idb_atmname = strindex(atoms.element(index_todo), atomdb_sugar.name, ...
                          'exact');
    % atoms with matched resname, but unmatched atom name
   i_mismatch = find(idb_atmname(i_sugar) == 0);
   if ~isempty(i_mismatch)
      showinfo([int2str(length(i_mismatch)) ' atoms with sugar ' ...
               'acid resnames, but without standard atom names'], 'warning');
      disp(['      They are: ' ...
            strjoin(unique(atoms ...
                           .element(index_todo(i_sugar(i_mismatch)))),', ')])
      i_sugar(i_mismatch) = [];
   end

   showinfo([int2str(length(i_sugar)) ' standard sugar acids atom (or ' ...
             'atom group) names ...']);
   
   % index to the sastype for the i_sugar (of index_todo)
   idb_sastype = atomdb_sugar.sastype((idb_resname(i_sugar)-1)* ...
                                        atomdb_sugar.num_rows + ...
                                        idb_atmname(i_sugar));
   i_no_sastype = find(idb_sastype <= 0);
   if ~isempty(i_no_sastype)
      warning([num2str(length(i_no_sastype)) ' sugar acid ' ...
               'atoms have PDB atom type <= 0!!!'])
      atoms.name(index_todo(i_sugar(i_no_sastype)),:)
      i_sugar(i_no_sastype)
      i_sugar(i_no_sastype) = [];
      idb_sastype(i_no_sastype) = [];
   end
end

% process the sugar acid atoms
if ~isempty(i_sugar)
   showinfo([ 'Sugar acids: ' num2str(length(i_sugar)) ' atoms ' ...
                       '(or groups) found ...']);
   i_atoms = index_todo(i_sugar);
   atoms.exclvolume(i_atoms) = atomdb_sas.exclvolume(idb_sastype);
   atoms.radius_sol(i_atoms) = atomdb_sas.radius_sol(idb_sastype);
   atoms.radius_crysol(i_atoms) = atomdb_sas.radius_crysol(idb_sastype);   
   atoms.z_vac(i_atoms) = atomdb_sas.z(idb_sastype);   
   atoms.mol_weight(i_atoms) = atomdb_sas.mol_weight(idb_sastype);
else
   showinfo('no sugar atoms found!')
end

% check whether mission completed
index_todo(i_sugar) = [];
if isempty(index_todo)
   showinfo('all atoms located, done!!!')
   atoms.z_sol = atoms.z_vac - rho_solvent*volume_factor*atoms.exclvolume;
   return
end

% d) check for other PDB atom types

% assign water restypes

i_water = strcmpi('HOH', mat2cell(atoms.resname(index_todo, :), ...
                                  ones(length(index_todo), 1), 3));
i_water = find(i_water == 1);
showinfo([int2str(length(i_water)) ' water molecules found']);
if ~isempty(i_water)
   atoms.restype(index_todo(i_water)) = 4;
end

% 
for i=4:-1:2
   showinfo(['check ' int2str(length(index_todo)) ' atoms for ' ...
             'generic atom (group) types with first ' int2str(i) ...
             ' characters in atom names']);

   % use the first three letters only
   if (i ~= 4)
      atmnames = strtrim(mat2cell(atoms.name(:, 1:i), ...
                                  ones(length(atoms.element),1), i));
   else
      atmnames = atoms.element;
   end
   
   idb_sastype = strindex(atmnames(index_todo), atomdb_sas.name, 'exact');
   i_sas = find(idb_sastype ~=0); % the atoms index available in
                                  % PDB dataf base

   if ~isempty(i_sas)
      showinfo([num2str(length(i_sas)) ' atoms found ...'])
      
      idb_sastype = idb_sastype(i_sas);
      i_atoms = index_todo(i_sas);
      atoms.exclvolume(i_atoms) = atomdb_sas.exclvolume(idb_sastype);
      atoms.radius_sol(i_atoms) = atomdb_sas.radius_sol(idb_sastype);
      atoms.radius_crysol(i_atoms) = atomdb_sas.radius_crysol(idb_sastype);
      atoms.z_vac(i_atoms) = atomdb_sas.z(idb_sastype);
      atoms.mol_weight(i_atoms) = atomdb_sas.mol_weight(idb_sastype);

      % check whehter they are ions found
      i_ion = find(idb_sastype >= atomdb_sas.ion_start);
      if ~isempty(i_ion)
         showinfo([int2str(length(i_ion)) ' ions found']);
         atoms.restype(index_todo(i_sas(i_ion))) = 3;
      end
   else
      showinfo('no atoms found!!!')
   end
   
   index_todo(i_sas) = [];
   if isempty(index_todo)
      showinfo('all atoms located, done!!!')
      atoms.z_sol = atoms.z_vac - rho_solvent*volume_factor*atoms.exclvolume;
      return
   end
end

% finally report any un-assigned atoms
atoms.z_sol = atoms.z_vac - rho_solvent*volume_factor* atoms.exclvolume;
if ~isempty(index_todo)
   showinfo([num2str(length(index_todo)) ' atoms not identified ' ...
             'in the PDB atom types!'], 'warning')
   disp(['      They are: ' strjoin(unique(atoms.element(index_todo)),', ') ...
                       ])
   disp(['           resnames are: ' ...
         strjoin(unique(mat2cell(atoms.resname(index_todo,:), ...
                                 ones(length(index_todo), 1), 3)), ...
                 ', ')])
end

return
