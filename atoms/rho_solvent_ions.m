function [rho_eff, ion] = rho_solvent_ions(ion, varargin)
% concentration is assumed to be in M

% 1) check and setup
NA = 6.0221415e23;

rho_water = 0.334611;
rho_eff = rho_water;
parse_varargin(varargin);

% 2) get the atom property
if ~isfield(ion(1), 'exclvolume') || (ion(1).exclvolume == 0)
   for i=1:length(ion)
      sprop = atomdb_getproperty(ion(i).name);
      ion(i).z = sprop.z;
      ion(i).exclvolume = sprop.exclvolume;
      ion(i).z_sol = sprop.z_sol;
   end
end

% 3) calculate
dV=0; dZ=0;

for i=1:length(ion)
   dV = dV + ion(i).n * NA * ion(i).exclvolume * 1e-27;
   dZ = dZ + ion(i).n * NA * ion(i).z; 
end

rho_eff = ((1-dV)*rho_water*1e27 + dZ)*1e-27;
