function sAPBS = apbs_popsolvent(sAPBS, varargin)
% --- Usage:
%        sAPBS = apbs_popsolvent(sAPBS, varargin)
% --- Purpose:
%        pouplate the solvent molecules around the macromolecule.  
%        1) obtain the shell cube position with getshape.m
%        2) populate the ions using MC method, i.e., random number
%
% --- Parameter(s):
%        sAPBS - the structure from "apbs_readall"
%  
%        totalnum - total number of solvent molecules to populate
%                   (default: 100)
%        z - the z number of each molecule (default: 8)
%        multinum - multiplication factor to the total number, but
%                   decrease the z (default: 1)
%        num_bins - bin sizes for each direction (default: [1,1,1]) 
% --- Return(s): 
%        sAPBS - with sAPBS.ion field updated
%
% --- Example(s):
%
% $Id: apbs_popsolvent.m,v 1.2 2013/02/28 16:52:10 schowell Exp $
%

% 1) default settings
verbose = 1;

thickness = 1;      % how many layers to search for
gradient = 3;       % the decrease of density of each layer
totalnum = 86; % total number of solvent molecules to populate
z = 8;
multinum = 3;
num_bins = [1,1,1]; % whether to bin the data to reduce size
rand_reset = 1;
parse_varargin(varargin)
totalnum = totalnum*multinum;
z = z/multinum;

% 2) get the density matrix of the solvent molecules
if isfield(sAPBS, 'geom') && isfield(sAPBS.geom, 'index_solshell')
   index = sAPBS.geom.index_solshell;
else % a quick and dirty way, though not strictly correct
   index = getshape(sAPBS.sacc, 1, 'thickness', thickness); % find 1s
end

ndens = zeros(sAPBS.dime);
ndens(index) = totalnum/length(index); % equal probability
sAPBS.solvent.name = 'O';
sAPBS.solvent.z = z;
sAPBS.solvent.num_mols = totalnum;
sAPBS.solvent.ndens = ndens;

% rebin the probabilities to avoid close contacts 
if ~isequal(num_bins, [1,1,1])
   % I can only think of a loop construct now to do this
   ix_block = (1:num_bins(1))-ceil(num_bins(1)/2);
   iy_block = (1:num_bins(2))-ceil(num_bins(2)/2);
   iz_block = (1:num_bins(3))-ceil(num_bins(3)/2);
   % reduce one dimension at a time
   for ix = ceil(num_bins(1)/2):num_bins(1):sAPBS.dime(1)- ix_block(end)
      for iy = ceil(num_bins(2)/2):num_bins(2):sAPBS.dime(2)- iy_block(end)
         for iz = ceil(num_bins(3)/2):num_bins(3):sAPBS.dime(3)- iz_block(end)
            ndens(ix,iy,iz) = total(ndens(ix+ix_block, iy+iy_block, ...
                                          iz+iz_block));
         end
      end
   end
end

% 3) check off the positions already occupied by ions
index_occupied = [];
for i=1:length(sAPBS.ion)
   if isfield(sAPBS.ion(i), 'index_popions')
      index_occupied = [index_occupied; sAPBS.ion(i).index_popions];
   end
end
if ~isempty(index_occupied)
   ndens(index_occupied) = 0;
   ndens(:) = totalnum / sum(ndens(:)) * ndens;
end

% 4) populate the solvent molecules

if (rand_reset == 1)  % reset the random number based on current time
   rand('state',sum(100*clock));
end
i_popmols = find(ndens > rand(sAPBS.dime));
sAPBS.solvent.num_popmols = length(i_popmols);
if (sAPBS.solvent.num_popmols ~=0)
   sAPBS.solvent.index_popmols = i_popmols;
   [ix,iy,iz] = ind2sub(sAPBS.dime, i_popmols); % ix,iy,iz: nx1 vectors
   position = repmat(sAPBS.xyzmin, sAPBS.solvent.num_popmols, 1) + ...
       ([ix,iy,iz]-1)*sAPBS.delta;
else
   sAPBs.solvent.index_popmols = [];
   position = [];
end

if ~isempty(position)
   sAPBS.solvent.atoms = atoms_create(position, struct('type', 'HETATM', ...
                         'element', {sAPBS.solvent.name}, 'resname', 'HOH', 'chainid', 'S'));
   sAPBS.solvent.atoms.exclvolume = zeros(sAPBS.solvent.num_popmols, 1);
   sAPBS.solvent.atoms.radius_sol = zeros(sAPBS.solvent.num_popmols, 1);
   sAPBS.solvent.atoms.z_vac = repmat(sAPBS.solvent.z, ...
                                      sAPBS.solvent.num_popmols, 1);
   sAPBS.solvent.atoms.z_sol = sAPBS.solvent.atoms.z_vac;
   %sAPBS.solvent.atoms = atoms_getproperty(sAPBS.solvent.atoms, ...
   %                                          'rho_solvent',
   %                                          sAPBS.rho_solvent);
end

% show info
showinfo(['Dummy hydration atoms: ' sAPBS.solvent.name ', number: ' ...
          num2str(sAPBS.solvent.num_mols) ', populated: ' ...
          num2str(sAPBS.solvent.num_popmols)])
