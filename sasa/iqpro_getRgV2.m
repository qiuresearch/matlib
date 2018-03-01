function [iqpro, virial] = iqpro_getRgV2(iqpro, varargin)
% --- Usage:
%        [iqpro, virial] = iqpro_getRgV2(iqpro, varargin)
% --- Purpose:
%        
%
% --- Parameter(s):
%
% --- Return(s): 
%        iqpro - 
%
% --- Example(s):
%
% $Id: iqpro_getRgV2.m,v 1.2 2013/09/03 00:19:11 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end
parse_varargin(varargin);

if ~exist('savename', 'var') || isempty(savename)
   savename = 'noname';
end
if exist('guinier_range', 'var') && ~isempty(guinier_range)
   [iqpro.guinier_range] = deal(guinier_range);
end
if exist('match_range', 'var') && ~isempty(match_range)
   [iqpro.match_range] = deal(match_range);
end
if exist('match_data', 'var') && ~isempty(match_data)
   [iqpro.match_data] = deal(match_data);
   [iqpro.match] = deal(1);
end
if exist('match_scale', 'var') && ~isempty(match_scale)
   [iqpro.match_scale] = deal(match_scale);
end
if exist('match_offset', 'var') && ~isempty(match_offset)
   [iqpro.match_offset] = deal(match_offset);
end
iqpro = xypro_dataprep(iqpro);

for i=1:length(iqpro)
   
   % Ginier fit to get Rg
   guinier_fit = gyration(iqpro(i).data, iqpro(i).guinier_range);
   iqpro(i).rg = guinier_fit.rg;
   iqpro(i).rg_i0 = guinier_fit.i0;
   iqpro(i).rg_data = guinier_fit.data;
   iqpro(i).rg_fit = guinier_fit.fit;
   iqpro(i).rg_chi2 = guinier_fit.chi2;

   % Debye format fit to get Rg_debye
   debye_fit = gyration_debye(iqpro(i).data, iqpro(i).guinier_range);
   iqpro(i).rg_debye = debye_fit.rg;
   iqpro(i).rg_debye_i0 = debye_fit.i0;
   iqpro(i).rg_debye_data = debye_fit.data;
   iqpro(i).rg_debye_fit = debye_fit.fit;
   iqpro(i).rg_debye_chi2 = debye_fit.chi2;
   
   % gnom transformation to get P(r), Rg and I0
   if exist('gnomcfg', 'var') && ~isempty(gnomcfg)
      % save data to the gnom file format
      gdatfile = [iqpro(i).datadir iqpro(i).prefix, '.gdat'];
      gnom_savedata(iqpro(i).data(:,[1,2,4]), gdatfile, 'header', iqpro(i).title ); 

      gnomcfg.INPUT1.value = gdatfile;
      gnomcfg.OUTPUT.value = [iqpro(i).datadir iqpro(i).prefix '.out'];
      gnomcfg.RMAX.value = iqpro(i).dmax;
      iqpro(i).gnom = gnom_runcfg(gnomcfg);
      iqpro(i).rg_gnom = iqpro(i).gnom.rg;
      iqpro(i).rg_gnom_i0 = iqpro(i).gnom.i0;
      iqpro(i).rg_gnom_data = iqpro(i).gnom.iq(:,[1,2,3]);
      iqpro(i).rg_gnom_fit = iqpro(i).gnom.iq(:,[1,4]);
      iqpro(i).rg_gnom_chi2 = iqpro(i).gnom.chi2;
   end
   
   % calculate 2nd Virial coefficient
   iqpro(i).rho=iqpro(i).concentration*1e-3*6.0221415e23*1e-27; % number of particles per A^3
   iqpro(i).rho_unit = '#/A^3';
   iqpro(i).c = iqpro(i).rho*iqpro(i).molweight/6.0221415e23* 1e24;
   iqpro(i).c_unit = 'g/ml';
   
   % secondvirial #1) using rg_io from guinier fit
   % assume iqpro(i).normconst contains the PQ0
   iqpro(i).sq0 = iqpro(i).rg_i0/iqpro(i).rho/iqpro(i).normconst;
   iqpro(i).virialB2 = secondvirial_Sq02B2(iqpro(i).sq0, iqpro(i).rho);
   iqpro(i).virialB2_unit = 'A^3/#';
   
   % convert virialB2 in A^3/# to virialA2 in mol*ml/g^2
   iqpro(i).virialA2 = secondvirial_B22A2(iqpro(i).virialB2, iqpro(i).molweight);
   iqpro(i).virialA2_unit = 'ml*mol/g^2';

   % secondvirial #1) using rg_io from debye fit
   iqpro(i).sq0_debye = iqpro(i).rg_debye_i0/iqpro(i).rho/iqpro(i).normconst;
   iqpro(i).virialB2_debye = secondvirial_Sq02B2(iqpro(i).sq0_debye, iqpro(i).rho);
   
   % convert virialB2 in A^3/# to virialA2 in mol*ml/g^2
   iqpro(i).virialA2_debye = secondvirial_B22A2(iqpro(i).virialB2_debye, iqpro(i).molweight);

   % secondvirial #1) using rg_io from gnom fit
   if isfield(iqpro(i), 'rg_gnom_i0');
      iqpro(i).sq0_gnom = iqpro(i).rg_gnom_i0/iqpro(i).rho/iqpro(i).normconst;
      iqpro(i).virialB2_gnom = secondvirial_Sq02B2(iqpro(i).sq0_gnom, iqpro(i).rho);
      
      % convert virialB2 in A^3/# to virialA2 in mol*ml/g^2
      iqpro(i).virialA2_gnom = secondvirial_B22A2(iqpro(i).virialB2_gnom, iqpro(i).molweight);
   end
   
   % fit mid Q data to get fractal dimension?
   
   % fit high Q data to get surface to volume ratio?
end

figure_fullsize(); clf;
gnom_plotfit([iqpro.gnom], 'kratky_plot', 0)
saveps(gcf, [savename '_gnom.eps']);

% fit rho/i0 linearly to get the virialB2, for a series
if (length(iqpro) == 0)
   virial.rho = [iqpro.rho];
   virial.rho_unit = '#/A^3';
   virial.c = [iqpro.c];
   virial.c_unit = 'g/ml';
   virial.scale = [iqpro.scale];
   % fit the rho versus I(q=0)
   virial.i0 = [iqpro.rg_i0]; virial.i0 = [virial.i0(1:2:end)', ...
                       virial.i0(2:2:end)'];
   [B2, virial_fit] = secondvirial_Iq02B2(virial.rho, virial.i0);
   virial = struct_assign(virial_fit, virial);
   virial.A2 = secondvirial_B22A2(virial.B2, iqpro(1).molweight);
   virial.A2_unit = 'ml*mol/g^2';

   virial.i0_debye = [iqpro.rg_debye_i0]; virial.i0_debye = ...
       [virial.i0_debye(1:2:end)', virial.i0_debye(2:2:end)'];
   [B2, virial_debye] = secondvirial_Iq02B2(virial.rho, virial.i0_debye);
   virial = struct_assign(virial_debye, virial, 'suffix', '_debye');
   virial.A2_debye = secondvirial_B22A2(virial.B2_debye, iqpro(1).molweight);
   
   virial.i0_gnom = [iqpro.rg_gnom_i0]; virial.i0_gnom = ...
       [virial.i0_gnom(1:2:end)', virial.i0_gnom(2:2:end)'];
   [B2, virial_gnom] = secondvirial_Iq02B2(virial.rho, virial.i0_gnom);
   virial = struct_assign(virial_gnom, virial, 'suffix', '_gnom');
   virial.A2_gnom = secondvirial_B22A2(virial.B2_gnom, iqpro(1).molweight);
else
   virial = [];
end

% save and assign
assignin('caller', ['iqpro_' savename], iqpro);
assignin('caller', ['virial_' savename], virial);
