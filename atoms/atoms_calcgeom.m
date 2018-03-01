function [atoms, geom] = atoms_calcgeom(atoms, varargin)
% --- Usage:
%        geom = geom_calcatoms(atoms, varargin)
% --- Purpose:
%        calculate the geometry parameters of an atoms structure, such
%        as molecule center, volume, average radius, radius of
%        gyration of atoms, electrons in vaccum and solution, etc.
% --- Parameter(s):
%        atoms - the atoms structure
% --- Return(s):
%        geom - a structure containing computed values
%
% --- Example(s):
%
% $Id: atoms_calcgeom.m,v 1.2 2013/02/28 16:52:10 schowell Exp $
%

if (nargin < 1)
   help atoms_calcgeom
   return
end

% 1) 
verbose = 1;
parse_varargin(varargin);

% 2) calculation
geom.num_atoms = length(atoms.z_vac);

geom.xyz_min = min(atoms.position);
geom.xyz_max = max(atoms.position);
geom.xyz_cen = mean(atoms.position);
geom.boxvolume = prod(geom.xyz_max - geom.xyz_min);
geom.exclvolume = sum(atoms.exclvolume);
geom.atomicradius_ave = (geom.exclvolume / geom.num_atoms *3/4/pi)^(1/3);

% number of electrons in vacuum and solution
geom.enum_vac = sum(atoms.z_vac);
geom.enum_sol = sum(atoms.z_sol);
dist_square = sum((atoms.position - repmat(geom.xyz_cen, geom.num_atoms, ...
                                           1)).^2,2);
% radius of gyration of atom, electrons in vacuum and solution
geom.rg_atm = sqrt(sum(dist_square)/geom.num_atoms);
geom.rg_vac = sqrt(sum(dist_square.*atoms.z_vac)/geom.enum_vac);
geom.rg_sol = sqrt(sum(dist_square.*atoms.z_sol)/geom.enum_sol);


% radius of gyration of the cylinder
dist_square = sum([atoms.position(:,1)-geom.xyz_cen(1), ...
                   atoms.position(:,2)-geom.xyz_cen(2)].^2,2);
geom.rg_rod_atm = sqrt(sum(dist_square)/geom.num_atoms);
geom.rg_rod_vac = sqrt(sum(dist_square.*atoms.z_vac)/geom.enum_vac);
geom.rg_rod_sol = sqrt(sum(dist_square.*atoms.z_sol)/geom.enum_sol);


% thinking about to calculate the equivalent radius of a sphere, and
% the second virial coefficient
geom.radius_atm = ((geom.xyz_max(1)-geom.xyz_min(1)) + ...
                   (geom.xyz_max(2)-geom.xyz_min(2)))/4;
geom.height_atm = geom.xyz_max(3) - geom.xyz_min(3);
geom.diameter_atm = diameter_equiv_cylinder(geom.radius_atm*2, ...
                                            geom.height_atm);

atoms.geom = geom;
