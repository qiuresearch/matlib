function [pr, iq] = pdb2pr(pdb, varargin)
% --- Usage:
%       function [pr, iq] = pdb2pr(pdb)
% --- Purpose:
%       wrapper for using pr_calcatoms on pdb files
%
% --- Parameter(s):
%       pdb - the PDB data file
%       option - optional switches, accepted values are:
%                   'NOHETATM': will ignore HETATMs
%
% --- Return(s):
%       pr - P(r) calculated from the pdb atoms
%       iq - I(q) calculated from the pdb atoms
%       *.pr - file containing P(r) calculated from the pdb atoms
%       *.iq - file containing I(q) calculated from the pdb atoms
%
% --- Calling Method(s):
%       
% --- Example(s):
%       [tetra.pr, tetra.iq] = pdb2pr('1zbb_tetra.pdb');
%
% $Id: prcalc_pdbfile.m,v 1.1 2014/01/31 16:57:26 xqiu Exp $

parse_varargin(varargin);  % not currecntly used

% check for pdb file
i = strfind(lower(pdb),'pdb');
if i && exist(pdb,'file')
    out.pr = [pdb(1:i-1),'pr'];
    out.iq = [pdb(1:i-1),'iq'];
else
    help pdb2pr
    error('Me:badInput','PDB file was not input or does not exist!');
end

% read in pdb locations and weights
atoms = atoms_readpdb(pdb,varargin{:});

% calculate pr and iq
fprintf('calculating distance for %d atoms\n',length(atoms.z_sol));
fprintf('this may take awhile\n');
[pr, iq] = prcalc_atoms(atoms,varargin{:});

% output data
if exist(out.pr,'file'); fprintf('NOTE: %s was overwritten.\n',out.pr); end;    
if exist(out.iq,'file'); fprintf('NOTE: %s was overwritten.\n',out.iq); end;
saveascii(pr, out.pr);
saveascii(iq, out.iq);
