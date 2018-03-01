function atoms = centerPDB(pdb_files, varargin)
% --- Usage:
%        atoms = centerPDB(pdb_file, varargin)
%
% --- Purpose:
%        center the coordinates then re-save a PDB file
%
% --- Parameter(s):
%        pdb_file: path and file name to pdb file
%        show_result: show the resulting centered structure (optional)
%                     
%
% --- Return(s):
%        atoms: structure with the information from the pdb file
%
% --- Example(s):
%
% $Id: centerPDB.m,v 1.1 2014/05/13 00:58:41 schowell Exp $

if (nargin < 1)
   fprintf('nargin == %d\n',nargin)
   help centerPDB
   return
end

show_result = 0;

parse_varargin(varargin);

all_atoms.position = zeros(0,3);
all_atoms.mol_weight = zeros(0,1);

n_files = length(pdb_files);

for i = 1:n_files
    if ~exist('atoms', 'file')
        fprintf('\nERROR: No such file:\n')
        fprintf([pdb_files{i},'\n\n\n']);
        return
    end
    
    atoms(i) = atoms_readpdb(pdb_files{i});
    all_atoms.position = [all_atoms.position ; atoms(i).position];
    all_atoms.mol_weight = [all_atoms.mol_weight ; atoms(i).mol_weight];
end

com = calcCOM(all_atoms.position, all_atoms.mol_weight);

if show_result
   all_atoms.centered = all_atoms.position - repmat(com, length(all_atoms.position), 1);
   figure;
   hold all;
   xyplot3(all_atoms.position,'.');
   xyplot3(all_atoms.centered,'.');
   xyplot3(zeros(1,3),'rx','linewidth',6)
   xlabel('x');ylabel('y');zlabel('z');
   title('centered')
   legend('original','centered','zero')
end


for i = 1:n_files
    comMat = repmat(com, length(atoms(i).position), 1);
    atoms(i).position = atoms(i).position - comMat;
    outfile = strrep(pdb_files{i},'.pdb','_c.pdb');
    atoms_writepdb(atoms(i), outfile);
end
   

display( 'text')

return