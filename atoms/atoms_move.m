function atoms = atoms_move(atoms, shift, varargin)
% --- Usage:
%        atoms = atoms_move(atoms, shift, varargin)
% --- Purpose:
%        move all atoms by a constant
% --- Parameter(s):
%
% --- Return(s):
%        atoms - shifted atoms structure
%
% --- Example(s):
%
% $Id: atoms_move.m,v 1.2 2013/02/28 16:52:10 schowell Exp $
%

% 1) Simple check on input parameters
if nargin < 2
   error('Not enough parameters!')
   help atoms_move
   return
end

verbose = 0;
parse_varargin(varargin);

% 2) move them
showinfo(['shift all atoms by (' num2str(shift, '%0.4f,') ')'])
atoms.position(:,1) = atoms.position(:,1) + shift(1);
atoms.position(:,2) = atoms.position(:,2) + shift(2);
atoms.position(:,3) = atoms.position(:,3) + shift(3);
