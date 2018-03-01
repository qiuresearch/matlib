function [atoms, index] = atoms_select(atoms, varargin)
% --- Usage:
%        [atoms, index] = atoms_remove(atoms, varargin)
% --- Purpose:
%        select atoms by a variety of options
% --- Parameter(s):
%        atoms  - an array of atoms structure to merge
%        varargin - 
%                   "index": the indices of the atoms
%                   "element": a cell array or  char array
%                   "resname": a cell array or char array (e.g., 'HOH'
%                   "restype": 1: DNA, 2: protein, 3: ions, 4: water 5: sugar 6: others
%                   "invert": invert the selection
% --- Return(s):
%        results -
%
% --- Example(s):
%
% $Id: atoms_select.m,v 1.1 2011-09-19 13:19:31 xqiu Exp $

% 1) Simple check on input parameters

verbose = 1;
invert = 0; % default is to select
parse_varargin(varargin);

% 2) get the index
if ~exist('index', 'var')
   index = [];
end

% add the elements
if exist('element', 'var')
   if ischar(element)
      element = cellstr(element);
   end
   for i=1:length(element)
      index = [index; strmatch(element{i}, strjust(atoms.name, 'left'))];
   end
end
% add the resname
if exist('resname', 'var')
   if ischar(resname)
      resname = cellstr(resname);
   end
   for i=1:length(resname)
      index = [index; strmatch(resname{i}, atoms.resname)];
   end
end
% add the restype
if exist('restype', 'var')
   for i=1:length(restype)
      index = [index; find(atoms.restype == restype(i))];
   end
end

% 3) if inverting selection
if (invert == 1)
   dummy = 1:length(atoms.element);
   dummy(index) = [];
   index = dummy;   % the index of atoms to remove
end

if (length(index) > 0)
   elements = unique(atoms.element(index));
   showinfo([int2str(length(index)) ' are selected. They are: ' ...
             strjoin(elements,',')]);
   atoms.type = atoms.type(index, :);
   atoms.serialno = atoms.serialno(index,:);
   atoms.name = atoms.name(index,:);
   atoms.element = atoms.element(index,:);
   atoms.altloc = atoms.altloc(index,:);
   atoms.resname = atoms.resname(index,:);
   atoms.chainid = atoms.chainid(index,:);
   atoms.seqno = atoms.seqno(index,:);
   atoms.position = atoms.position(index,:);
   if isfield(atoms, 'exclvolume')
      atoms.restype = atoms.restype(index,:);
      atoms.exclvolume = atoms.exclvolume(index,:);
      atoms.radius_sol = atoms.radius_sol(index,:);
      atoms.z_vac = atoms.z_vac(index,:);
      atoms.z_sol = atoms.z_sol(index,:);
   end
   if isfield(atoms, 'z')
      atoms.z = atoms.z(index,:);
   end
else
   showinfo('No atoms were selected!');
end