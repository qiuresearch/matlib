function atoms = atoms_readpdb(file_pdb, varargin)
% --- Usage:
%        atoms = atoms_readpdb(file_pdb, option(s))
% --- Purpose:
%    read all ATOM, HETATM in a pdb file into an array of structures
%
% --- Parameter(s):
%    file_pdb - the PDB data file
%      option - optional switches, accepted values are:
%               'NOHETATM': will ignore HETATMs
%
% --- Return(s):
%        atoms - an array of structures
%
% --- Calling Method(s):
%
% --- Example(s):
%
% $Id: atoms_readpdb.m,v 1.6 2013/02/28 16:52:10 schowell Exp $
% RATE: 4.0

% 1) Simple check on input parameters

if (nargin < 1)
  error('a PDB file should be provided!');
  return
end

% Set default property (options) values
nohetatm = 0;
verbose = 1;
rho_solvent = 0.334611;  % electron density of water
parse_varargin(varargin);

% 2) Read the PDB file, and keep the ATOM or HETATM lines only

fid = fopen(file_pdb, 'r');   pdbdata = fread(fid);   fclose(fid);
pdbdata = strsplit(char(pdbdata'), sprintf('\n'))'; % each row is one line

index_atoms = strmatch('ATOM', pdbdata)';
index_hetatms = [];
if (nohetatm ~= 1)
   index_hetatms = strmatch('HETATM', pdbdata)';
   index_atoms = [index_atoms,  index_hetatms];
end
showinfo(['PDB file <' file_pdb '> read, # of ATOM: ' ...
          int2str(length(index_atoms)) ', # of HETATM: ' int2str(length(index_hetatms))])

if isempty(index_atoms)
  warning('Neither atom nor hetatm is found in the PDB file!');
  return
end

num_atoms = length(index_atoms);
mat_atoms = cell2mat(pdbdata(index_atoms)); 

% 3) extract the data. The steps are:
%     a) "mat_atoms" is a matrix of strings
%     b) using "mat_atoms(:,i:j)" to select the desired columns for all atoms
%     c) convert this matrix to number if necessary. I am surprised
%     that actually a 1D number array comes out of this 2D matrix
%     d) then use "mat2cell" to convert the matrix or vectro to
%     cell (removed, as now a structure of arrays is used)

%  atoms = struct('serialno',0, 'name','', 'altloc','', 'resname','', ...
%                 'chainid', '', 'resseq', 0, 'icode', '', 'position', ...
%                 0, 'occupancy', 0.0, 'uiso', 0.0, 'segid', '', ...
%                 'element', '', 'z', 0.0, 'charge', 0.0);

irows = ones(1,num_atoms);

atoms.type = mat_atoms(:,1:6);
atoms.serialno = str2num(mat_atoms(:,7:11)); % an integer
atoms.name =mat_atoms(:,13:16);
% replace "OP1" by "O1P", "OP2" by "O2P", "C7" by "C5M"
atoms.name = transpose(atoms.name);
atoms.name = strrep(atoms.name(:)', ' OP1', ' O1P');
atoms.name = strrep(atoms.name, ' OP2', ' O2P');
atoms.name = strrep(atoms.name, ' C7 ', ' C5M');
% replace "'" by '*'
atoms.name = reshape(strrep(atoms.name, char(39), '*'), 4, num_atoms)';
atoms.element = strtrim(cellstr(atoms.name)); %strtrim(mat2cell(mat_atoms(:,13:16),irows,4));

atoms.altloc = mat_atoms(:,17);
% column 21 is supposed to be SPACE, however, some PDB has it 
atoms.resname = mat_atoms(:,18:20);
% rename the residue names to full to simplify atoms_getproperty()
atoms.resname = transpose(strjust(atoms.resname, 'right'));
atoms.resname = atoms.resname(:)';
atoms.resname = strrep(atoms.resname, '  A', 'ADE');
atoms.resname = strrep(atoms.resname, '  G', 'GUA');
atoms.resname = strrep(atoms.resname, '  C', 'CYT');
atoms.resname = strrep(atoms.resname, '  T', 'THY');
atoms.resname = strrep(atoms.resname, '  U', 'URI');
atoms.resname = strrep(atoms.resname, ' DA', 'ADE');
atoms.resname = strrep(atoms.resname, ' DG', 'GUA');
atoms.resname = strrep(atoms.resname, ' DC', 'CYT');
atoms.resname = strrep(atoms.resname, ' DT', 'THY');
atoms.resname = strrep(atoms.resname, ' DU', 'URI');
atoms.resname = regexprep(atoms.resname, 'DA[0-9+-]+', 'ADE');
atoms.resname = regexprep(atoms.resname, 'DG[0-9+-]+', 'GUA');
atoms.resname = regexprep(atoms.resname, 'DC[0-9+-]+', 'CYT');
atoms.resname = regexprep(atoms.resname, 'DT[0-9+-]+', 'THY');
atoms.resname = regexprep(atoms.resname, 'DU[0-9+-]+', 'URI');
atoms.resname = reshape(atoms.resname, 3, num_atoms)';
% GTP is complied in crysol, but not yet used in our research
atoms.chainid = mat_atoms(:,22);
atoms.seqno = mat_atoms(:,23:27);
atoms.position(:,1) = str2num(mat_atoms(:,31:38))'; % a 1x3 double array
atoms.position(:,2) = str2num(mat_atoms(:,39:46))';
atoms.position(:,3) = str2num(mat_atoms(:,47:54))';

%   try % in case of non-standard PDB files -- less than 80 columns
%     atoms.occupancy = str2num(mat_atoms(:,55:60)); % a double float
%     atoms.uiso = str2num(mat_atoms(:,61:66)); % a double float
%     atoms.segid = mat_atoms(:,73:76);
%     atoms.element = strtrim(mat2cell(mat_atoms(:,77:78),irows,2));
%     atoms.charge = mat2cell(mat_atoms(:,79:80),irows,2);
%   catch
%     if verbose == 1
%       warning('Some occupancy, and/or names, and/or charges missing!');
%     end
%   end
%   
% 4) Get some atom properties
atoms = atoms_getproperty(atoms, 'rho_solvent', rho_solvent, 'verbose', ...
                          verbose);

% OLD 10-07-2004num_atoms = size(mat_atoms,1);
% OLD 10-07-2004atoms = repmat( struct('serialno',1, 'name','', 'altloc','', ...
% OLD 10-07-2004                       'resname','', 'chainid', '', 'resseq', 0, ...
% OLD 10-07-2004                       'icode', '', 'position', [0.0,0.0,0.0], ...
% OLD 10-07-2004                       'occupancy', 0.0, 'uiso', 0.0, 'segid', '', ...
% OLD 10-07-2004                       'element', '', 'z', 0.0, 'charge', 0.0), num_atoms, 1);
% OLD 10-07-2004
% OLD 10-07-2004irows = ones(1,num_atoms);
% OLD 10-07-2004
% OLD 10-07-2004cell_dummy = mat2cell(str2num(mat_atoms(:,7:11)),irows,1);
% OLD 10-07-2004[atoms.serialno] = deal(cell_dummy{:});  % an integer
% OLD 10-07-2004
% OLD 10-07-2004cell_dummy(:) = strtrim(mat2cell(mat_atoms(:,13:16),irows,4));
% OLD 10-07-2004[atoms.name] = deal(cell_dummy{:});      % a variable length string
% OLD 10-07-2004
% OLD 10-07-2004cell_dummy(:) = strtrim(mat2cell(mat_atoms(:,13:14),irows,2));
% OLD 10-07-2004[atoms.element] = deal(cell_dummy{:});
% OLD 10-07-2004
% OLD 10-07-2004cell_dummy(:) = strtrim(mat2cell(mat_atoms(:,17),irows,1));
% OLD 10-07-2004[atoms.altloc] = deal(cell_dummy{:});    % one character
% OLD 10-07-2004
% OLD 10-07-2004cell_dummy(:) = strtrim(mat2cell(mat_atoms(:,18:20),irows,3));
% OLD 10-07-2004[atoms.resname] = deal(cell_dummy{:});   % a variable length string
% OLD 10-07-2004
% OLD 10-07-2004cell_dummy(:) = strtrim(mat2cell(mat_atoms(:,22),irows,1));
% OLD 10-07-2004[atoms.chainid] = deal(cell_dummy{:});   % one character
% OLD 10-07-2004
% OLD 10-07-2004cell_dummy(:) = mat2cell(str2num(mat_atoms(:,23:26)),irows,1);
% OLD 10-07-2004[atoms.resseq] = deal(cell_dummy{:});    % an integer
% OLD 10-07-2004
% OLD 10-07-2004cell_dummy(:) = strtrim(mat2cell(mat_atoms(:,27),irows,1));
% OLD 10-07-2004[atoms.icode] = deal(cell_dummy{:});     % a character
% OLD 10-07-2004
% OLD 10-07-2004cell_dummy(:) = mat2cell(str2num(mat_atoms(:,31:54)),irows,3);
% OLD 10-07-2004[atoms.position] = deal(cell_dummy{:});  % a 1x3 double array
% OLD 10-07-2004
% OLD 10-07-2004cell_dummy(:) = mat2cell(str2num(mat_atoms(:,55:60)),irows,1);
% OLD 10-07-2004[atoms.occupancy] = deal(cell_dummy{:}); % a double float
% OLD 10-07-2004
% OLD 10-07-2004cell_dummy(:) = mat2cell(str2num(mat_atoms(:,61:66)),irows,1);
% OLD 10-07-2004[atoms.uiso] = deal(cell_dummy{:});      % a double float
% OLD 10-07-2004
% OLD 10-07-2004try % in case of non-standard PDB files -- less than 80 columns
% OLD 10-07-2004  cell_dummy(:) = strtrim(mat2cell(mat_atoms(:,73:76),irows,4));
% OLD 10-07-2004  [atoms.segid] = deal(cell_dummy{:});     % a variable length string
% OLD 10-07-2004
% OLD 10-07-2004  cell_dummy(:) = strtrim(mat2cell(mat_atoms(:,77:78),irows,2));
% OLD 10-07-2004  [atoms.element] = deal(cell_dummy{:});   % a variable length string 
% OLD 10-07-2004
% OLD 10-07-2004catch
% OLD 10-07-2004  warning('No element names found between col 77:78!');
% OLD 10-07-2004end
% OLD 10-07-2004
% OLD 10-07-2004try
% OLD 10-07-2004  cell_dummy(:) = strtrim(mat2cell(mat_atoms(:,79:80),irows,2));
% OLD 10-07-2004  [atoms.charge] = deal(cell_dummy{:});    % a variable length string
% OLD 10-07-2004catch
% OLD 10-07-2004  warning('No atom charge found between col 77:78!');
% OLD 10-07-2004  % [atoms.charge] = deal(0);
% OLD 10-07-2004end
