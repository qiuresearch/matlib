function result = atoms_draw(atoms, atomsshow, varargin)
%        result = draw_atom(atoms, atomsshow, varargin)
% --- Purpose:
%        quick show of atomic structure
%
% --- Parameter(s):
%     
% --- Return(s): 
%        results - 
%
% --- Calling Method(s):
%
% --- Example(s):
%
% $Id: atoms_draw.m,v 1.2 2012/04/04 19:37:16 xqiu Exp $
%

% 1) Simple check on input parameters

if (nargin < 1) 
  error('One array of atom structures should be provided!');
  return
end

% 2)
if ~exist('atomsshow', 'var')
   atomsshow = {'C', 'O', 'P', 'CA'};
end

facecolor = {'b', 'r', 'g', 'y', 'c'};
edgecolor = {'k', 'k', 'k', 'k', 'k'};
marksize = [10,12,14,12,14];

parse_varargin(varargin)
hold on
for iatom=1:length(atomsshow)
  index_atom = strmatch(atomsshow{iatom}, atoms.element, 'exact');
  
  if isempty(index_atom)
    disp(['No ' atomsshow{iatom} ' atoms found!'])
    continue
  end
  num_atoms = length(index_atom);
  disp(['Number of ' atomsshow{iatom} ' atoms is ' num2str(num_atoms)])
  iatom = mod(iatom, length(facecolor)+1);
  plot3(atoms.position(index_atom,1), atoms.position(index_atom,2), ...
        atoms.position(index_atom,3), 'o', 'MarkerFaceColor', ...
        facecolor{iatom}, 'MarkerEdgeColor', edgecolor{iatom}, ...
        'MarkerSize', marksize(iatom));
end

% --- Change History(s):
%
% $Log: atoms_draw.m,v $
% Revision 1.2  2012/04/04 19:37:16  xqiu
% *** empty log message ***
%
% Revision 1.1.1.1  2007-09-19 04:45:38  xqiu
% A new start of my matlab library with new directory structure.
%
% Revision 1.1  2005/11/03 00:33:20  xqiu
% *** empty log message ***
%
% Revision 1.4  2005/07/22 19:23:55  xqiu
% corresponding changes due to APBS package
%
% Revision 1.3  2005/07/10 18:21:22  xqiu
% small changes
%
% Revision 1.2  2005/01/17 22:26:26  xqiu
% Add atoms manipulation routines
%
% Revision 1.1  2004/10/08 19:26:18  xqiu
% speed improvements!
%
% Revision 1.2  2004/09/30 13:55:25  xqiu
% Remove one bug
%
% Revision 1.1.1.1  2004/09/30 13:52:14  xqiu
% Start my own matlab library in CVS. 
%
% 
