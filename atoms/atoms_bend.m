function atoms = atoms_bend(atoms, direction, curvature, varargin)
% --- Usage:
%        atoms = atoms_bend(atoms, shift, varargin)
% --- Purpose:
%        move all atoms by a constant
% --- Parameter(s):
%
% --- Return(s):
%        atoms - shifted atoms structure
%
% --- Example(s):
%
% $Id: atoms_bend.m,v 1.2 2013/02/28 16:52:09 schowell Exp $
%

% 1) Simple check on input parameters
if nargin < 2
   error('Not enough parameters!')
   help atoms_bend
   return
end

verbose = 0;
parse_varargin(varargin);

% 2) move them

direction = direction/norm(direction);
size(direction)
center = mean(atoms.position);

position(:,1) = atoms.position(:,1) - center(1);
position(:,2) = atoms.position(:,2) - center(2);
position(:,3) = atoms.position(:,3) - center(3);
size(position(1,:))
for i=1:length(position(:,1))
   normdir = cross(position(i,:), direction);
   radian = norm(normdir)/curvature;
   position(i,:) = position(i,:) + direction*curvature*(1-cos(radian)) ...
       - cross(direction, normdir/norm(normdir))*curvature*(radian-sin(radian));
end
atoms.position = position;