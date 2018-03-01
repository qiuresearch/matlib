%  The portal to prcalc() in prcalc.c
% --- Usage:
%        pr = prcalc(xyz, zeff, rmax)
%
% --- Purpose:
%        calculate P(r) from atomic coorinates and mass
%
% --- Parameter(s):
%        xyz   - atomic coordinates
%        zeff  - atomic masses
%        rmax  - maximum distance (for memory allocation of histogram
%                array)
%
% --- Return(s): 
%        pr    - pair-distance distribution function
%
% --- Example(s):
%        atoms = atoms_readpdb('ncp.pdb');
%        atoms.pr = prcalc(atoms.position, atoms.z_sol, 300);
%        xyplot(atoms.pr)
%
% --- Note(s):
%        default stepsize is 1A
%        if no rmax is given, will use 150 A
%
% --- Compiling:
%        mex -O CFLAGS="\$CFLAGS -std=c99" -lm prcalc.c         
%                                                        
% $Id: prcalc.m,v 1.2 2014/03/01 19:07:28 schowell Exp $ 
