function sAPBS = apbs_popions(sAPBS, varargin)
% --- Usage:
%        sAPBS = apbs_popions(sAPBS, varargin)
% --- Purpose:
%        1) calculate the density/probability of each ion in each
%        grid. This is simply No*exp(-eZ*PHI/KT)*grid_area.
%        2) if set, re-bin the probability to larger grids to aviod
%        overlaping 
%        3) populate the ions using MC method, i.e., random number
%
% --- Parameter(s):
%        sAPBS - the structure from "apbs_readall"
%
%        ecutoff - lower energy limit for populating (default: 0)
%        multinum - the multiplication factor to the total number of
%                   populated ions, decreease the z number
%                   correspondingly (default: 1)
%        num_bins - bin sizes along each direction to avoid
%                   overlapping (default: [1,1,1])
% --- Return(s): 
%        sAPBS - with sAPBS.ion field updated
%
% --- Example(s):
%
% $Id: apbs_popions.m,v 1.2 2013/02/28 16:52:10 schowell Exp $
%

% 1) default settings
verbose = 1;
ecutoff = 0; % the electro static energy cut off for ion population
multinum = 1; % multiply the number of each ion (not justifiable!)
num_bins = [1,1,1]; % whether to bin the data to reduce size
rand_reset = 1;
parse_varargin(varargin)

% 3) calculate the ion density/probability in each CELL!!!
num_ions = length(sAPBS.ion);
index_occupied = [];
sAPBS.rho_solvent = rho_solvent_ions(sAPBS.ion); % get the solvent effective density
if (rand_reset == 1) % reset the random number based on current time
   rand('state',sum(100*clock)); 
end
for i=1:num_ions
   % the asymptotic value for density in each grid
   sAPBS.ion(i).ndens0 = sAPBS.ion(i).n * 6.0221367e23 * 1e-27 * ...
       det(sAPBS.delta);

   % the coulomb energy  and probability in each grid
   energy = sAPBS.ion(i).z * sAPBS.pot;
   sAPBS.ion(i).ndens = sAPBS.ion(i).ndens0 * exp(-energy) .* sAPBS.iacc;
   % remove NaNs
   index_nans = find(isnan(sAPBS.ion(i).ndens)==1);
   if ~isempty(index_nans)
      showinfo([ num2str(length(index_nans)) ' NaNs found (maybe 0*Inf)!'])
      sAPBS.ion(i).ndens(index_nans) = 0;
   end
   
   % do energy cutoff
   if (ecutoff > 0)
      index_cutoffs = find(abs(energy) < ecutoff);
      if ~isempty(index_cutoffs)
         showinfo([num2str(length(index_cutoffs)) ' points below ' ...
                   'cutoff energy ' num2str(ecutoff) 'KT!'])
         sAPBS.ion(i).ndens(index_cutoffs) = 0;
      end
   end
   sAPBS.ion(i).ecutoff = ecutoff;
   
   % artificial number multiplicator
   if (multinum ~= 1)
      sAPBS.ion(i).ndens = multinum*sAPBS.ion(i).ndens;
      showinfo(['ion density is multiplied by factor: ' num2str(multinum, ...
                                                        '%0.2f')])
   end
      
   sAPBS.ion(i).num_ions = sum(sAPBS.ion(i).ndens(:), 'double');
   sAPBS.ion(i).num_grids  = numel(find(sAPBS.ion(i).ndens > 0));

   % rebin the probabilities to avoid close contacts 
   if ~isequal(num_bins, [1,1,1])
      ndens = zeros(sAPBS.dime);
      
      % I can only think of a loop construct now to do this
      ix_block = (1:num_bins(1))-ceil(num_bins(1)/2);
      iy_block = (1:num_bins(2))-ceil(num_bins(2)/2);
      iz_block = (1:num_bins(3))-ceil(num_bins(3)/2);
      % reduce one dimension at a time
      for ix = ceil(num_bins(1)/2):num_bins(1):sAPBS.dime(1)- ix_block(end)
         for iy = ceil(num_bins(2)/2):num_bins(2):sAPBS.dime(2)- iy_block(end)
            for iz = ceil(num_bins(3)/2):num_bins(3):sAPBS.dime(3)- iz_block(end)
               ndens(ix,iy,iz) = total(sAPBS.ion(i).ndens(ix+ix_block, ...
                                                          iy+iy_block, ...
                                                          iz+iz_block));
            end
         end
      end
   else
      ndens = sAPBS.ion(i).ndens;
   end
   
   % zero the occupied index and renormalize the matrix
   if ~isempty(index_occupied)
      ndens(index_occupied) = 0;
      ndens(:) = sAPBS.ion(i).num_ions / sum(ndens(:)) * ndens;
   end

   % check for > 1 probabilities
   index_overflow = find(ndens > 1);
   if ~isempty(index_overflow)
      showinfo([int2str(length(index_overflow)) 'points have density ' ...
                          'larger than 1!'])
   end
   
   % populate the ions
   i_popions = find(ndens > rand(sAPBS.dime));
   sAPBS.ion(i).num_popions = length(i_popions);
   if (sAPBS.ion(i).num_popions ~=0)
      sAPBS.ion(i).index_popions = i_popions;
      [ix,iy,iz] = ind2sub(sAPBS.dime, i_popions); % ix,iy,iz: nx1 vectors
      position = repmat(sAPBS.xyzmin, sAPBS.ion(i).num_popions, 1) ...
          + ([ix,iy,iz]-1)*sAPBS.delta;
   else
      sAPBs.ion(i).index_popions = [];
      position = [];
   end
   
   if ~isempty(position)
      sAPBS.ion(i).atoms = atoms_create(position, struct('type', 'HETATM', ...
               'element', {upper(sAPBS.ion(i).name)}, ...
               'resname', {upper(sAPBS.ion(i).name)}, 'chainid', 'I'));
      
      sAPBS.ion(i).atoms = atoms_getproperty(sAPBS.ion(i).atoms, ...
                           'rho_solvent', sAPBS.rho_solvent, 'verbose', 0);
      % decrease the effective Z number if the number was modified.
      if (multinum ~= 1)
         sAPBS.ion(i).atoms.z_vac = sAPBS.ion(i).atoms.z_vac/ multinum;
         sAPBS.ion(i).atoms.z_sol = sAPBS.ion(i).atoms.z_sol/ multinum;
      end
   end

   % show info
   showinfo(['ion: ' sAPBS.ion(i).name ', theoretical num: ' ...
             num2str(sAPBS.ion(i).num_ions) ', populated: ' ...
             num2str(sAPBS.ion(i).num_popions)]);
end
