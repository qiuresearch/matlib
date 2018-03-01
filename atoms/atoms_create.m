function atoms = atoms_create(position, sPar)
% --- Usage:
%        atoms = atoms_create(position, sPar)
% --- Purpose:
%        generate the atoms structure from positions only
% --- Parameter(s):
%        positions - nx3 array of the atomic positions
%        sPar - a structure with fields corresponding to the atoms
%               structure specifying the field values for the newly
%               created atoms structure. You can pass with any
%               fields.
%
% --- Return(s): 
%        atoms - the atoms structure
%
% --- Example(s):
%
% $Id: atoms_create.m,v 1.2 2013/02/28 16:52:10 schowell Exp $
%
verbose = 1;

% 1) default settings
[num_atoms, num_dummy] = size(position);
% the default values if used will be expanded during dimension checking
atoms = struct('type', 'ATOM  ', 'serialno', (1:num_atoms)', 'name', '', ...
               'element', {'C'}, 'altloc', ' ', 'resname', '  I', ...
               'chainid', ' ', 'seqno', '     ', 'position', position);

% 2) use specified parameters
if exist('sPar', 'var')
   atoms = struct_assign(sPar, atoms);
end
if ~iscell(atoms.element) % convert 
   atoms.element = cellstr(atoms.element);
end

% 3) make sure the dimension of each field is correct
if (length(atoms.type) <= 6)
   atoms.type = repmat(sprintf('%-6s', atoms.type), num_atoms, 1);
end

if (length(atoms.serialno) == 1)
   atoms.serialno = atoms.serialno -1 + 1:num_atoms';
end

if (length(atoms.element) == 1)
   atoms.element = repmat(atoms.element, num_atoms, 1);
end

if isequal(atoms.name, '') % not passed
   atoms.name = cell2mat(atoms.element);
   [num_dummy, num_cols] = size(atoms.name);
   switch num_cols
      case 1
         atoms.name = cat(2, repmat(' ', num_atoms, 1), atoms.name, ...
                          repmat(' ', num_atoms, 2));
      case 2
         atoms.name = cat(2, repmat(' ', num_atoms, 1), atoms.name, ...
                          repmat(' ', num_atoms, 1));
      case 3
         atoms.name = cat(2, repmat(' ', num_atoms, 1), atoms.name);
      case 4
      otherwise
         showinfo('atom names too long, >4 letters!!!', 'warning');
   end
end

if (length(atoms.altloc) == 1)
   atoms.altloc = repmat(atoms.altloc, num_atoms, 1);
end

if (length(atoms.resname) <= 3)
   num_cols = length(atoms.resname);
   atoms.resname = repmat(atoms.resname, num_atoms, 1);
   if (num_cols < 3)
      atoms.resname = cat(2, atoms.resname, repmat(' ', num_atoms, ...
                                                   3-num_cols));
   end
end

if (length(atoms.chainid) == 1)
   atoms.chainid = repmat(atoms.chainid, num_atoms, 1);
end

if (length(atoms.seqno) <=5)
   num_cols = length(atoms.seqno);
   atoms.seqno = repmat(atoms.seqno, num_atoms, 1);
   if (num_cols < 5)
      atoms.seqno = cat(2, repmat(' ', num_atoms, 5-num_cols), atoms.seqno);
   end
end
