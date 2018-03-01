function [iqdata, atoms, savefile] = dammif_plotfit(filename)
% --- Usage:
%        [iqdata, atoms, savefile] = dammif_plotfit(filename)
%
% --- Purpose:
%        show the fit and the PDB if found. Filename without prefix.
%
% --- Return(s): 
%
% --- Parameter(s):
%        var   - 
%
% --- Example(s):
%
% $Id: dammif_plotfit.m,v 1.1 2012/04/04 19:38:29 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

[iqdata, titlestr] = gnom_loaddata([filename '.fir']);

suffix = '_dammif.eps';
if exist([filename '-1r.pdb'], 'file')
   atoms = atoms_readpdb([filename '-1r.pdb']);
elseif exist([filename '-1.pdb'], 'file')
   atoms = atoms_readpdb([filename '-1.pdb']);
   suffix = '_dammin.eps';
else
   showinfo('No PDB file found!');
end
   
figure; clf;
subplot(2,2,1); set(gca, 'xscale', 'log', 'yscale', 'log');
hold all;
errorbar(iqdata(:,1), iqdata(:,2), iqdata(:,3), '.');
plot(iqdata(:,1), iqdata(:,4));
axis tight;
iqlabel;
title([filename suffix], 'interpreter', 'none');
legend('exp.','fit');
legend boxoff

subplot(2,2,2); axis off;
atoms_draw(atoms); 
axis equal; axis tight;
view([0,0,1]);
title('Z axis view');

subplot(2,2,3); axis off;
atoms_draw(atoms); 
axis equal; axis tight; 
view([0,1,0]);
title('Y axis view');

subplot(2,2,4); axis off;
atoms_draw(atoms); 
axis equal; axis tight; 
view([1,0,0]);
title('X axis view');

savefile = [filename suffix];
saveps(gcf, savefile);
