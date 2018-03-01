function hfig = iqcalc_plot(siq, varargin);
% --- Usage:
%        hfig = iqcalc_plot(siq, varargin);
% --- Purpose:
% --- Parameter(s):
%        siq   - 
%     varargin - 'verbose': 1 (default)
%                'q': 0:0.004:1.0 (default). the vector to calculate
%                're_calc': 0 (default). Read the data file if
%                           present instead of re_calculating
%                'save_iq': 0 (default)
%                'pdbfile': file name (no suffix) for saving pdb and I(Q) data
%
% --- Example(s):
%
% $Id: iqcalc_plot.m,v 1.2 2012/02/07 00:09:52 xqiu Exp $

if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

verbose = 1;
parse_varargin(varargin);

figure(1); clf;

% (2,2,1)
subplot(2,2,1); hold all; set(gca, 'yscale', 'log');
title('I(Q)s in Vacuum');

xyplot(siq.iq(:,[1,3]));
lege = {'Matlab Debye GW'};
if isfield(siq, 'iq_spec')
   lege{end} = [lege{end} sprintf(' (calctime:%0.0fs)', siq.iq_spec.calctime)];
end

if isfield(siq, 'iq_crysol')
   xyplot(siq.iq_crysol(:,[1,3]));
   lege = {lege{:}, 'Crysol'};
   if isfield(siq, 'iq_crysol_spec')
      lege{end} = [lege{end} sprintf(' (calctime:%0.0fs)', siq.iq_crysol_spec.calctime)];
   end
end

if isfield(siq, 'iq_sastbx_debye');
   xyplot(siq.iq_sastbx_debye);
   lege = {lege{:}, 'SASTBX Debye'};
end
if isfield(siq, 'iq_sastbx_she');
   xyplot(siq.iq_sastbx_she(:,[1,3]));
   lege = {lege{:}, 'SASTBX SHE'};
end
if isfield(siq, 'iq_sastbx_zernike');
   xyplot(siq.iq_sastbx_zernike(:,[1,3]));
   lege = {lege{:}, 'SASTBX Zernike'};
end

legend(lege); legend boxoff
axis tight
iqlabel

% (2,2,2)
subplot(2,2,2); hold all; set(gca, 'yscale', 'log');
title('I(Q)s in Solution');

xyplot(siq.iq(:,[1,2])); set(gca, 'yscale', 'log');
lege = {'Matlab Debye (no hydration shell)'};
if isfield(siq, 'iq_crysol')
   xyplot(siq.iq_crysol(:,[1,2]));
   lege = {lege{:}, 'Crysol'};
end
if isfield(siq, 'iq_sastbx_she');
   xyplot(siq.iq_sastbx_she(:,[1,2]));
   lege = {lege{:}, 'SASTBX SHE'};
end
if isfield(siq, 'iq_sastbx_zernike');
   xyplot(siq.iq_sastbx_zernike(:,[1,2]));
   lege = {lege{:}, 'SASTBX Zernike'};
end

legend(lege); legend boxoff
axis tight
iqlabel

% (2,2,3)
subplot(2,2,3); hold all; set(gca, 'yscale', 'log');
title('Contributions to I(Q)s')
lege = {};
if isfield(siq, 'iq_crysol')
   xyplot(siq.iq_crysol(:,[1,4]));
   lege = {lege{:}, 'Solvent envelope (Crysol)'};
   
   xyplot(siq.iq_crysol(:,[1,5]));
   lege = {lege{:}, 'Border layer (Crysol)'};
end
if isfield(siq, 'iq_sastbx_she')
   xyplot(siq.iq_sastbx_she(:,[1,4]));
   lege = {lege{:}, 'Solvent envelope (SASTBX SHE)'};
   
   xyplot(siq.iq_sastbx_she(:,[1,5]));
   lege = {lege{:}, 'Border layer (SAXTBX SHE)'};
end
if isfield(siq, 'iq_sastbx_zernike')
   xyplot(siq.iq_sastbx_zernike(:,[1,4]));
   lege = {lege{:}, 'Solvent envelope (SASTBX ZERNIKE)'};
   
   xyplot(siq.iq_sastbx_zernike(:,[1,5]));
   lege = {lege{:}, 'Border layer (SAXTBX ZERNIKE)'};
end

legend(lege); legend boxoff;
axis tight;
iqlabel
