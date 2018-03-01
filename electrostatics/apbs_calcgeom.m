function sAPBS = apbs_calcgeom(sAPBS, fname, varargin)
% --- Usage:
%        sAPBS = apbs_calcgeom(sAPBS, fname, varargin)
% --- Purpose:
%        calculate the geometry of 1) APBS matrix with a potential
%        cutoff,  2) the atomic model, 3) the molecule in vacuum,
%        4) the molecule in solution, 5) the solution shell coordinates
% --- Parameter(s):
%        sAPBS - the APBS structure
%        fname - fname_vacmol.dx, fname_solmol.dx,
%                fname_solshell.dx are searched for 3,4,5 calculations
% --- Return(s): 
%        sAPBS - sAPBS.geom field is updated
%
% --- Example(s):
%
% $Id: apbs_calcgeom.m,v 1.3 2013/02/28 16:52:10 schowell Exp $
%

verbose = 1;
potcutoff = 1; 
mol = 0; 
solshell = 0; thickness = 1;
parse_varargin(varargin);
if ~exist('fname', 'var') || isempty(fname)
   fname = sAPBS.name; % file name prefix for the vacmol, solmol,
                       % and solshell.dx
end

% 1) geometry with a potential cutoff
if (max(potcutoff) > 0)
   sAPBS.geom.potcutoff = potcutoff;
   for k=1:length(potcutoff)
      pot = sAPBS.pot;
      pot(find(abs(pot) > potcutoff(k))) = 0;
%      pot = pot .* sAPBS.sacc; % to ensure all internal grids are in
      [ix,iy,iz] = ind2sub(sAPBS.dime, find(pot==0));
      if isempty(ix) % no potential higher than the cutoff, set to
                     % solvent acessibility matrix
         [ix,iy,iz] = ind2sub( size(sAPBS.sacc), find(sAPBS.sacc == 0));
      end
      sAPBS.geom.numgrids_pot(k) = length(ix);
      sAPBS.geom.volume_pot(k) = length(ix)*det(sAPBS.delta);
      
      sAPBS.geom.radius_pot(k) = ((max(ix)-min(ix))*sAPBS.delta(1,1) + ...
                               (max(iy)-min(iy))*sAPBS.delta(2,2))/4;
      sAPBS.geom.height_pot(k) = (max(iz)-min(iz))*sAPBS.delta(3,3);
      sAPBS.geom.diameter_pot(k) = ...
          diameter_equiv_cylinder(sAPBS.geom.radius_pot(k)*2, ...
                                  sAPBS.geom .height_pot(k));
   end
   showinfo(['geometry calculated with potential cutoff = ' ...
             strjoin(num2lege(potcutoff), ',') 'KT.'])
end

% 2) geometry in vaccum and solution
if (mol == 1)
   
   % atomic model only
   sAPBS = apbs_mergeatoms(sAPBS, 'ions', 0, 'solvent',0, 'verbose', 0);
   sAPBS.geom = struct_assign(atoms_calcgeom(sAPBS.atoms), sAPBS.geom);

   % vacuum and solution volume from APBS
   if ~exist([fname '_vacmol.dx'], 'file') || ~exist([fname ...
                          '_solmol.dx'], 'file')
      fname = 'apbs';
      sAPBS_tmp = sAPBS;
      sAPBS_tmp.name = fname;
      [sAPBS_tmp.ion.r] = deal(3); % hydration volume with inflated VDW
                                   % radii method with thickness = 3A
      sAPBS_tmp.srad = 0; % get the dry volume
      sAPBS_tmp.npbe = 0;
      sAPBS_tmp.srfm = 'mol';
      
      apbs_writein(sAPBS_tmp);
      [status, results] = unix(['apbs ' fname '.in > ' fname '.out']);
      unix(['\cp ' fname '_sacc.dx ' fname '_vacmol.dx']);
      unix(['\cp ' fname '_iacc.dx ' fname '_solmol.dx']);
   end
   dummy = apbs_readdx([fname '_vacmol.dx']);
   sAPBS.geom.vacmol = dummy.data;
   dummy = apbs_readdx([fname '_solmol.dx']);
   sAPBS.geom.solmol = dummy.data;
   % vacuum
   [ix,iy,iz] = ind2sub(sAPBS.dime, find(sAPBS.geom.vacmol == 0));
   
   sAPBS.geom.volume_vac = length(ix)*det(sAPBS.delta);
   sAPBS.geom.radius_vac = ((max(ix)-min(ix))*sAPBS.delta(1,1) + ...
                            (max(iy)-min(iy))*sAPBS.delta(2,2))/4;
   sAPBS.geom.height_vac = (max(iz)-min(iz))*sAPBS.delta(3,3);
   sAPBS.geom.diameter_vac = ...
       diameter_equiv_cylinder(sAPBS.geom.radius_vac*2, sAPBS.geom ...
                               .height_vac);
   
   % in solution (including the 3A hydration shell)
   [ix,iy,iz] = ind2sub(sAPBS.dime, find(sAPBS.geom.solmol == 0));
   
   sAPBS.geom.volume_sol = length(ix)*det(sAPBS.delta);
   sAPBS.geom.radius_sol = ((max(ix)-min(ix))*sAPBS.delta(1,1) + ...
                            (max(iy)-min(iy))*sAPBS.delta(2,2))/4;
   sAPBS.geom.height_sol = (max(iz)-min(iz))*sAPBS.delta(3,3);
   sAPBS.geom.diameter_sol = ...
       diameter_equiv_cylinder(sAPBS.geom.radius_sol*2, sAPBS.geom ...
                               .height_sol);
   showinfo(['geometry calculated for atomic, vaccum, solution molecules.'])
end

% 3) hydration shell extraction with ion accessibility matrix
if (solshell == 1)
   if ~isfield(sAPBS.geom, 'solshell') || ...
          ~isequal(size(sAPBS.geom.solshell), sAPBS.dime)
      
      if ~exist([fname '_solshell.dx'], 'file')
         fname = 'apbs';
         sAPBS_tmp = sAPBS;
         sAPBS_tmp.name = fname;
         % the distance between the VDW surface and solvent molecule
         % would be centering around sAPBS_tmp.srad
         [sAPBS_tmp.ion.r] = deal(sAPBS_tmp.srad-sAPBS.delta(1,1)/2); 
         sAPBS_tmp.npbe = 0;
         sAPBS_tmp.srfm = 'smol';
         
         apbs_writein(sAPBS_tmp);
         [status, results] = unix(['apbs ' fname '.in > ' fname '.out']);
         unix(['\cp ' fname '_iacc.dx ' fname '_solshell.dx']);
      end
      dummy = apbs_readdx([fname '_solshell.dx']);
      sAPBS.geom.solshell = dummy.data;
   
   end
   % get the shape
   sAPBS.geom.index_solshell = getshape(sAPBS.geom.solshell, 1, ...
                                                      'thickness', thickness);
   sAPBS.geom.thickness_solshell = thickness;
   showinfo(['Coordinates for solvation shell calculated.'])
end
