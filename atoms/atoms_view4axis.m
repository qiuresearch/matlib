function atoms = atoms_view4axis(atoms)
% --- Usage:
%        atoms = view4axis(atoms)
%
% --- Purpose:
%
% --- Return(s): 
%
% --- Parameter(s):
%        var   - 
%
% --- Example(s):
%
% $Id: atoms_view4axis.m,v 1.1 2012/04/04 19:37:50 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

titlestr = 'PDB';
if ischar(atoms)
   titlestr = atoms;
   atoms = atoms_readpdb(atoms);
end

figure;
subplot(2,2,1)
axis off;
atoms_draw(atoms); 
axis equal; axis tight; 
view([1,1,1]);
title([titlestr ' [1,1,1] view'], 'interpreter', 'none');

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
