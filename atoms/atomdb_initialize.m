function ok = atomdb_initialize(varargin)
% --- Usage:
%        ok = atomdb_initialize(varargin)
% --- Purpose:
%        initialize the atomdb database
% --- Parameter(s):
%        rho_solvent - the electron density of the solvent
%                      (default: 0.334611(water))
% --- Return(s): 
%        results - 
%
% --- Example(s):
%
% $Id: atomdb_initialize.m,v 1.3 2013/04/03 16:04:25 xqiu Exp $
%

global atomdb_isvalid atomdb_num atomdb_sym atomdb_const atomdb_sas ...
    atomdb_nucleic atomdb_protein atomdb_sugar atomdb_asfcoeftb ...
    atomdb_compcoeftb atomdb_macoeftb atomdb_bindenergytb ...
    atomdb_xxsectiontb atomdb_f1f2coeftb

rho_solvent = 0.334; %611;
parse_varargin(varargin);

atomdb_sym={'H','HE','LI','BE','B','C','N','O','F','NE','NA', ...
            'MG','AL','SI','P','S','CL','AR','K','CA', 'SC','TI', ...
            'V','CR','MN','FE','CO','NI','CU','ZN', 'GA','GE', ...
            'AS','SE','BR','KR','RB',  'SR','Y','ZR', 'NB','MO', ...
            'TC','RU','RH','PD','AG','CD','IN','SN', 'SB','TE', ...
            'I','XI','CS ', 'BA','LA','CE','PR','ND', 'PM', ...
            'SM','EU','GD','TB','DY','HO','ER','TM','YB','LU','HF', ...
            'TA','W','RE','OS','IR','PT','AU','HG','TL','PB', ...
            'BI','PO','AT','RN','FR','RA','AC','TH', 'PA','U', ...
            'NP','PU','AM','CM','BK','CF','ES','FM','MD','NO', ...
            'LR','RF','DB','SG','BH', 'HS','MT','UUN','UUU', ...
            'UUB','UUT','UUQ','UUP','UUH','UUS','UUO'};

atomdb_num = length(atomdb_sym);
atomdb_charge = [1, 0, 1, 0];

% ----- supported atomic (group) types in solutoin 

atomdb_sas.note = {['This is a list of atomic (group) types ' ...
                    'supported for solution small angle scattering.'], ...
                   ['"z" ' 'here is the number of electrons']};
atomdb_sas.num_atoms = 32;
atomdb_sas.ion_start = 14;
atomdb_sas.rho_solvent =rho_solvent;
% ions: Fe3+ Cu2+ Ca2+ Mg2+ Mn2+ Zn2+ H+ Na+ K+ Rb+ Cs+ Sr2+
%       CoHex Cl- Br- Ba2+ Li+ Al3+ La3+ (here "z" is number of electrons, i.e, Z-charge)
atomdb_sas.saxs_param = { ...
% ATOM IATYPE val z_vac excl vol z_eff r_hydro r_crysol weight
%  1      2    3    4     5        6      7      8   9
   'C'     1   0   6   16.4400   0.51   1.74   1.58  12  ; ...
   'CH'    2   0   7   21.5900   -0.21  2.00   1.73  13  ; ...
   'CH2'   3   0   8   26.7400   -0.93  2.00   1.85  14  ; ...
   'CH3'   4   0   9   31.8900   -1.65  2.00   1.97  15  ; ...
   'N'     5   0   7   2.4900    6.17   0.84   0.84  14  ; ...
   'NH'    6   0   8   7.6400    5.45   1.65   1.22  15  ; ...
   'NH2'   7   0   9   12.7900   4.73   1.70   1.45  16  ; ...
   'NH3'   8   0   10  17.9400   4.01   2.00   1.62  17  ; ...
   'O'     9   0   8   9.1300    4.95   1.50    1.3  16  ; ...
   'OH'   10   0   9   14.2800   4.23   1.60    1.5  17  ; ...
   'S'    11   0   16  19.8600   9.37   1.68   1.68  32.1; ...
   'SH'   12   0   17  25.1000   8.62   1.81   1.81  33.1; ...
   'P'    13   0   15  5.7300    13.09  1.11   1.11  31.0 ; ...
   'FE'   14   3   23  -94.9829  54.72  0.00   1.24  55.8; ...
   'CU'   15   2   27  0.0000    27.00  0.00   1.28  63.5; ...
   'CA'   16   2   18  -34.3732  29.48  4.12   1.97  40  ; ...
   'MG'   17   2   10  -39.6878  23.26  4.28    1.6  24.3; ...
   'MN'   18   2   23  0.0000    23.00  0.00    1.3  54.9; ...
   'ZN'   19   2   28  -38.3367  40.80  4.30   1.33  65.4; ...
   'H'    20   1   0   -2.4742   0.83   2.80   1.07  1  ; ...
   'NA'   21   1   10  -4.9816   11.66  3.58      0  23 ; ...
   'K'    22   1   18  12.1219   13.95  3.31      0  39.1  ; ...
   'RB'   23   1   36  20.4246   29.18  3.29      0  85.5  ; ...
   'CS'   24   1   54  32.7126   43.07  3.29      0  132.9 ; ...
   'SR'   25   2   36  -35.2035  47.76  4.12      0  87.6  ; ...
   'CO'   26   3   72  118.7452  32.34  0.00      0  149  ; ...
   'CL'   27   -1  18  27.0834   8.95   3.32      0  35.5  ; ...
   'BR'   28   -1  36  38.5420   23.13  3.30      0  79.9  ; ...
   'BA'   29   2   54  -23.2280  61.76  4.04      0  137.3  ; ...
   'LI'   30   1   2   -3.9685   3.33   3.82      0  6.9  ; ...
   'AL'   31   3   10  -72.2069  34.12  0.00      0  27  ; ...
   'LA'   32   3   54  -67.3920  76.51  0.00      0  138.9  ; ...
   'O-'   33   -1   9   9.1300   5.95   1.50    1.3  16  ; ...
   'NH+'  34	1   7	7.64	 4.448  1.65   1.22  15  ; ...
   'NH2+' 35	1   8	12.79	 3.728  1.70   1.45  16  ; ...
   'NH3+' 36	1   9	17.94	 3.008  2.00   1.62  17  ; ...
                };

atomdb_sas.name = atomdb_sas.saxs_param(:,1)';
atomdb_sas.charge = cell2mat(atomdb_sas.saxs_param(:,3)');
atomdb_sas.z = cell2mat(atomdb_sas.saxs_param(:,4)');
% numbers before Fe3+ are taken from D.Svergun's JAC crysol
% paper. Some of Svergun's values are measured by Fraser et.al.,
% JAC78, which are, hopefully, more accurate than just using the van
% der waals radii. The latter numbers are the hydration volume taking
% into account of electro-restriction effect. From book "ions in
% solution" by John Burgess, page 59.
atomdb_sas.exclvolume = cell2mat(atomdb_sas.saxs_param(:,5)');
atomdb_sas.z_sol = atomdb_sas.z - atomdb_sas.exclvolume * rho_solvent;
% the solution radius data is kind of messy. The atomic groups data
% are preferrably taken from the paper by Pavlov et al., Biopolymers,
% Vol.22, 1507-1522. If not exists, values from Svergun's Crysol paper
% are used. The solution radius for these netural atoms (groups)
% should be the van derr waals radius. For ions, the hydrated radius
% is from page 73 of the book "ionic hydration in chemistry and
% biophysics" by B.E. Conway (1981). This radius data is used to map
% out the molecular surface, hydration shell. H+ ion radius is "H3O+"
atomdb_sas.radius_sol = cell2mat(atomdb_sas.saxs_param(:,7)');
% value from crysol (not complete, until H)
atomdb_sas.radius_crysol = cell2mat(atomdb_sas.saxs_param(:,8)');
atomdb_sas.mol_weight = cell2mat(atomdb_sas.saxs_param(:,9)');

% ---------------- the nucleic acid data taken from Crysol manual homepage
%  two factors determine the atom (group) type: 
%                  1) Residue name, 2) Atom name
%  index points to the array in atomdb_sas
%
atomdb_nucleic.saxs_param = {...
           'ADE', 'GUA', 'CYT', 'URI', 'THY', 'GTP' 'ATOM';
             9      9      9      9      9      9   'OXT'; ... 
             13     13     13     13     13     0   'P'  ; ... % (ribose)
             33     33     33     33     33     33  'O1P'; ... 
             10     10     10     10     10     10  'O2P'; ... 
             9      9      9      9      9      9   'O5*'; ... 
             3      3      3      3      3      3   'C5*'; ... 
             2      2      2      2      2      2   'C4*'; ... 
             9      9      9      9      9      9   'O4*'; ... 
             2      2      2      2      2      2   'C3*'; ... 
             9      9      9      9      9      9   'O3*'; ... 
             3      3      3      2      3      3   'C2*'; ... 
             10     10     10     10     0      10  'O2*'; ... 
             2      2      2      2      2      2   'C1*'; ... 
             5      5      0      0      0      5   'N9' ; ... %(nucloside)
             2      2      0      0      0      2   'C8' ; ... 
             5      5      0      0      0      5   'N7' ; ... 
             1      1      2      2      1      1   'C5' ; ... 
             1      1      2      2      2      1   'C6' ; ... 
             7      0      0      0      0      0   'N6' ; ... 
             5      6      5      5      5      6   'N1' ; ... 
             2      1      1      1      1      1   'C2' ; ... 
             5      5      5      6      6      5   'N3' ; ... 
             1      1      1      1      1      1   'C4' ; ... 
             0      9      0      0      0      9   'O6' ; ... 
             0      7      0      0      0      7   'N2' ; ... 
             0      0      9      9      9      9   'O2' ; ... 
             0      0      7      0      0      0   'N4' ; ... 
             0      0      0      9      9      0   'O4' ; ... 
             0      0      0      0      0      13  'P3' ; ... 
             0      0      0      0      0      5   'N23'; ... 
             0      0      0      0      0      13  'P2' ; ...           
             0      0      0      0      0      13  'P1' ; ...           
             0      0      0      0      4      0   'C5M'; ... % as_C7)
             0      0      0      0      4      0   'C7' ; ... 
                 };

atomdb_nucleic.resname = atomdb_nucleic.saxs_param(1,1:end-1);
atomdb_nucleic.name = atomdb_nucleic.saxs_param(2:end,end)';
atomdb_nucleic.num_rows = length(atomdb_nucleic.name);
atomdb_nucleic.num_cols = length(atomdb_nucleic.resname);
atomdb_nucleic.sastype = cell2mat(atomdb_nucleic.saxs_param(2:end,1:end-1));

% ---------------- the protein data taken from Crysol manual homepage
%  two factors determine the atom (group) type: 
%                  1) Residue name, 2) Atom name
%  index points to the array in atomdb_sas
%

% consider to add an entry for 'NH1', 'NH2'
% atomdb_protein.saxs_param = { ...
% 'N' 'CA' 'C' 'O' 'CB' 'CG' 'CD' 'CE' 'CZ' 'CH' 'ND' 'NE' 'NZ' 'NH' 'OG' 'OD' 'OE' 'OH' 'SG' 'SD' 'OX' 'AA';...  
%  6    2   1   9   4     0   0     0   0    0    0     0   0    0     0   0    0    0    0     0   9  'ALA';...
%  6    2   1   9   3     3   3     0   1    0    0     6   0    7     0   0    0    0    0     0   9  'ARG';...
%  6    2   1   9   3     1   0     0   0    0    7     0   0    0     0   9    0    0    0     0   9  'ASN';...
%  6    2   1   9   3     1   0     0   0    0    0     0   0    0     0   9    0    0    0     0   9  'ASP';...
%  6    2   1   9   3     0   0     0   0    0    0     0   0    0     0   0    0    0    12    0   9  'CYS';...
%  6    2   1   9   3     3   1     0   0    0    0     7   0    0     0   0    9    0    0     0   9  'GLN';...
%  6    2   1   9   3     3   1     0   0    0    0     0   0    0     0   0    9    0    0     0   9  'GLU';...
%  6    3   1   9   0     0   0     0   0    0    0     0   0    0     0   0    0    0    0     0   9  'GLY';...
%  6    2   1   9   3     1   2     2   0    0    5     6   0    0     0   0    0    0    0     0   9  'HIS';...
%  6    2   1   9   2     3   4     0   0    0    0     0   0    0     0   0    0    0    0     0   9  'ILE';...
%  6    2   1   9   3     2   4     4   0    0    0     0   0    0     0   0    0    0    0     0   9  'LEU';...
%  6    2   1   9   3     3   3     3   3    0    0     0   8    0     0   0    0    0    0     0   9  'LYS';...
%  6    2   1   9   3     3   3     4   0    0    0     0   0    0     0   0    0    0    0     11  9  'MET';...
%  6    2   1   9   3     1   2     2   2    0    0     0   0    0     0   0    0    0    0     0   9  'PHE';...
%  5    2   1   9   3     3   3     0   0    0    0     0   0    0     0   0    0    0    0     0   9  'PRO';...
%  6    2   1   9   3     0   0     0   0    0    0     0   0    0     10  0    0    0    0     0   9  'SER';...
%  6    2   1   9   2     4   0     0   0    0    0     0   0    0     10  0    0    0    0     0   9  'THR';...
%  6    2   1   9   3     1   2     2   2    2    0     6   0    0     0   0    0    0    0     0   9  'TRP';...
%  6    2   1   9   3     1   2     2   1    0    0     0   0    0     0   0    0    10   0     0   9  'TYR';...
%  6    2   1   9   3     4   4     0   0    0    0     0   0    0     0   0    0    0    0     0   9  'VAL';...
% %N    CA  C   O   CB    CG  CD    CE  CZ   CH   ND    NE  NZ   NH    OG  OD   OE   OH   SG    SD  OX  
% };
atomdb_protein.saxs_param = { ...
  'ALA' 'ARG' 'ASN' 'ASP' 'CYS' 'GLN' 'GLU' 'GLY' 'HIS' 'ILE' 'LEU' 'LYS' 'MET' 'PHE' 'PRO' 'SER' 'THR' 'TRP' 'TYR' 'VAL' 'PDB'; ...
    10    10    10    10    10    10    10    10    10    10    10    10    10    10    10    10    10    10    10    10  'OXT'; ...
    7     7     7     7     7     7     7     7     7     7     7     7     7     7     7     7     7     7     7     7   'NT'; ...
    6     6     6     6     6     6     6     6     6     6     6     6     6     6     6     6     6     6     6     6   'N '; ...
    2     2     2     2     2     2     2     3     2     2     2     2     2     2     2     2     2     2     2     2   'CA'; ...
    1     1     1     1     1     1     1     1     1     1     1     1     1     1     1     1     1     1     1     1   'C '; ...
    9     9     9     9     9     9     9     9     9     9     9     9     9     9     9     9     9     9     9     9   'O '; ...
    4     3     3     3     3     3     3     0     3     2     3     3     3     3     3     3     2     2     3     2   'CB'; ...
    0     3     1     1     0     3     3     0     1     0     2     3     3     1     3     0     0     4     1     0   'CG'; ...
    0     0     0     0     0     0     0     0     0     3     0     0     0     0     0     0     0     0     0     4   'CG1'; ...
    0     0     0     0     0     0     0     0     0     4     0     0     0     0     0     0     4     0     0     4   'CG2'; ...
    0     3     0     0     0     1     1     0     0     0     0     3     0     0     3     0     0     0     0     0   'CD'; ...
    0     0     0     0     0     0     0     0     0     4     4     0     0     2     0     0     0     4     2     0   'CD1'; ...
    0     0     0     0     0     0     0     0     2     0     4     0     0     2     0     0     0     1     2     0   'CD2'; ...
    0     0     0     0     0     0     0     0     0     0     0     3     4     0     0     0     0     0     0     0   'CE'; ...
    0     0     0     0     0     0     0     0     2     0     0     0     0     2     0     0     0     0     2     0   'CE1'; ...
    0     0     0     0     0     0     0     0     0     0     0     0     0     2     0     0     0     1     2     0   'CE2'; ...
    0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     2     0     0   'CE3'; ...
    0     1     0     0     0     0     0     0     0     0     0     0     0     2     0     0     0     0     1     0   'CZ'; ...
    0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     2     0     0   'CZ2'; ...
    0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     2     0     0   'CZ3'; ...
    0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0   'CH'; ...
    0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     2     0     0   'CH2'; ...
    0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0   'ND'; ...
    0     0     0     0     0     0     0     0     34    0     0     0     0     0     0     0     0     0     0     0   'ND1'; ...
    0     0     7     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0   'ND2'; ...
    0     6     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0   'NE'; ...
    0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     6     0     0   'NE1'; ...
    0     0     0     0     0     7     0     0     6     0     0     0     0     0     0     0     0     0     0     0   'NE2'; ...
    0     0     0     0     0     0     0     0     0     0     0     36    0     0     0     0     0     0     0     0   'NZ'; ...
    0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0   'NH'; ...
    0     7     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0   'NH1'; ...
    0     35    0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0   'NH2'; ...
    0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     10    0     0     0     0   'OG'; ...
    0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     10    0     0     0   'OG1'; ...
    0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0   'OD'; ...
    0     0     9     33    0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0   'OD1'; ...
    0     0     0     9     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0   'OD2'; ...
    0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0   'OE'; ...
    0     0     0     0     0     9     33    0     0     0     0     0     0     0     0     0     0     0     0     0   'OE1'; ...
    0     0     0     0     0     0     9     0     0     0     0     0     0     0     0     0     0     0     0     0   'OE2'; ...
    0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     10    0   'OH'; ...
    0     0     0     0     12    0     0     0     0     0     0     0     0     0     0     0     0     0     0     0   'SG'; ...
    0     0     0     0     0     0     0     0     0     0     0     0     11    0     0     0     0     0     0     0   'SD'; ...
    0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0   'OX'; ...
};

atomdb_protein.resname = atomdb_protein.saxs_param(1,1:end-1);
atomdb_protein.name = atomdb_protein.saxs_param(2:end,end)';
atomdb_protein.num_rows = length(atomdb_protein.name);
atomdb_protein.num_cols = length(atomdb_protein.resname);
atomdb_protein.sastype = cell2mat(atomdb_protein.saxs_param(2:end,1:end-1));

% ---------------- the sugar data taken from Crysol manual homepage
%  two factors determine the atom (group) type: 
%                  1) Residue name, 2) Atom name
%  index points to the array in atomdb_sas
%
atomdb_sugar.resname = {'NAG', 'MAN', 'GAL', 'GLC', 'SIA'};
atomdb_sugar.name = {'C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', ...
                    'C9', 'C10', 'C11', 'O1A', 'O1B', 'O1', 'O2', ...
                    'O3', 'O4', 'O5', 'O6', 'O7', 'O8', 'O9', 'O10', ...
                    'N2', 'N5'};
atomdb_sugar.num_rows = length(atomdb_sugar.name);
atomdb_sugar.num_cols = length(atomdb_sugar.resname);

atomdb_sugar.sastype = [ ...
%   NAG MAN GAL GLC SIA
     2,  2,  2,  2,  1; ... % ! C1
     2,  2,  2,  2,  1; ... % ! C2
     2,  2,  2,  2,  3; ... % ! C3
     2,  2,  2,  2,  2; ... % ! C4
     2,  2,  2,  2,  2; ... % ! C5
     3,  3,  3,  3,  2; ... % ! C6
     2,  0,  0,  0,  2; ... % ! C7
     4,  0,  0,  0,  2; ... % ! C8
     0,  0,  0,  0,  3; ... % ! C9
     0,  0,  0,  0,  1; ... % ! C10
     0,  0,  0,  0,  4; ... % ! C11
     0,  0,  0,  0,  9; ... % ! O1A
     0,  0,  0,  0, 10; ... % ! O1B
     0,  0,  0, 10,  0; ... % ! O1
     0, 10, 10, 10,  0; ... % ! O2
    10, 10, 10, 10,  0; ... % ! O3
    10, 10, 10, 10,  9; ... % ! O4
     9,  9,  9,  9,  0; ... % ! O5
    10, 10, 10, 10,  9; ... % ! O6
     9,  0,  0,  0, 10; ... % ! O7
     0,  0,  0,  0, 10; ... % ! O8
     0,  0,  0,  0, 10; ... % ! O9
     0,  0,  0,  0,  9; ... % ! O10
     6,  0,  0,  0,  1; ... % ! N2
     0,  0,  0,  0,  6];    % ! N5
%   NAG MAN GAL GLC SIA

% ---------------- the atomic const data base 
% source : http://www.esrf.fr/cgi-bin/periodic

atomdb_const.column_names = {'Z', 'AtomicRadius[A]', 'CovalentRadius[A]', 'AtomicMass', 'BoilingPoint[K]', 'MeltingPoint[K]', 'Density[g/ccm]', 'AtomicVolume', 'CoherentScatteringLength[1E-12cm]', 'IncoherentX-section[barn]', 'Absorption@1.8A[barn]'};
atomdb_const.row_names = atomdb_sym(1:103);
atomdb_const.data = ...
[ 1  0.79  0.32    1.0079400    20.2680    14.0250     0.0899 14.400  -0.37400  79.9000     0.3326; ...
  2  0.49  0.93    4.0026020     4.2150     0.9500     0.1787  0.000   0.32600   0.0000     0.0075; ...
  3  2.05  1.23    6.9410000  1615.0000   453.7000     0.5300 13.100  -0.19000   0.9100    70.5000; ...
  4  1.40  0.90    9.0121820  2745.0000  1560.0000     1.8500  5.000   0.77900   0.0050     0.0076; ...
  5  1.17  0.82   10.8110000  4275.0000  2300.0000     2.3400  4.600   0.53000   1.7000   767.0000; ...
  6  0.91  0.77   12.0110000  4470.0000  4100.0000     2.6200  4.580   0.66480   0.0010     0.0035; ...
  7  0.75  0.75   14.0067400    77.3500    63.1400     1.2510 17.300   0.93600   0.4900     1.9000; ...
  8  0.65  0.73   15.9994000    90.1800    50.3500     1.4290 14.000   0.58050   0.0000     0.0002; ...
  9  0.57  0.72   18.9984032    84.9500    53.4800     1.6960 17.100   0.56540   0.0008     0.0096; ...
 10  0.51  0.71   20.1797000    27.0960    24.5530     0.9010 16.700   0.45470   0.0080     0.0390; ...
 11  2.23  1.54   22.9897680  1156.0000   371.0000     0.9700 23.700   0.36300   1.6200     0.5300; ...
 12  1.72  1.36   24.3050000  1363.0000   922.0000     1.7400 13.970   0.53750   0.0770     0.0630; ...
 13  1.82  1.18   26.9815390  2793.0000   933.2500     2.7000 10.000   0.34490   0.0085     0.2310; ...
 14  1.46  1.11   28.0855000  3540.0000  1685.0000     2.3300 12.100   0.41490   0.0150     0.1710; ...
 15  1.23  1.06   30.9736200   550.0000   317.3000     1.8200 17.000   0.51300   0.0060     0.1720; ...
 16  1.09  1.02   32.0660000   717.7500   388.3600     2.0700 15.500   0.28470   0.0070     0.5300; ...
 17  0.97  0.99   35.4527000   239.1000   172.1600     3.1700 22.700   0.95792   5.2000    33.5000; ...
 18  0.88  0.98   39.9480000    87.3000    83.8100     1.7840 28.500   0.19090   0.2200     0.6750; ...
 19  2.77  2.03   39.0983000  1032.0000   336.3500     0.8600 45.460   0.37100   0.2500     2.1000; ...
 20  2.23  1.91   40.0780000  1757.0000  1112.0000     1.5500 29.900   0.49000   0.0300     0.4300; ...
 21  2.09  1.62   44.9559100  3104.0000  1812.0000     3.0000 15.000   1.22900   4.5000    27.2000; ...
 22  2.00  1.45   47.8800000  3562.0000  1943.0000     4.5000 10.640  -0.33000   2.6700     6.0900; ...
 23  1.92  1.34   50.9415000  3682.0000  2175.0000     5.8000  8.780  -0.03820   5.1870     5.0800; ...
 24  1.85  1.18   51.9961000  2945.0000  2130.0000     7.1900  7.230   0.36350   1.8300     3.0700; ...
 25  1.79  1.17   54.9308500  2335.0000  1517.0000     7.4300  1.390  -0.37300   0.4000    13.3000; ...
 26  1.72  1.17   55.8470000  3135.0000  1809.0000     7.8600  7.100   0.95400   0.3900     2.5600; ...
 27  1.67  1.16   58.9332000  3201.0000  1768.0000     8.9000  6.700   0.25000   4.8000    37.1800; ...
 28  1.62  1.15   58.6900000  3187.0000  1726.0000     8.9000  6.590   1.03000   5.2000     4.4900; ...
 29  1.57  1.17   63.5460000  2836.0000  1357.6000     8.9600  7.100   0.77180   0.5200     3.7800; ...
 30  1.53  1.25   65.3900000  1180.0000   692.7300     7.1400  9.200   0.56800   0.0770     1.1100; ...
 31  1.81  1.26   69.7230000  2478.0000   302.9000     5.9100 11.800   0.72880   0.0000     2.9000; ...
 32  1.52  1.22   72.6100000  3107.0000  1210.4000     5.3200 13.600   0.81929   0.1700     2.3000; ...
 33  1.33  1.20   74.9215900   876.0000  1081.0000     5.7200 13.100   0.65800   0.0600     4.5000; ...
 34  1.22  1.16   78.9600000   958.0000   494.0000     4.8000 16.450   0.79700   0.3300    11.7000; ...
 35  1.12  1.14   79.9040000   332.2500   265.9000     3.1200 23.500   0.67900   0.1000     6.9000; ...
 36  1.03  1.12   83.8000000   119.8000   115.7800     3.7400 38.900   0.78000   0.0300    25.0000; ...
 37  2.98  2.16   85.4678000   961.0000   312.6400     1.5300 55.900   0.70800   0.3000     0.3800; ...
 38  2.45  1.91   87.6200000  1650.0000  1041.0000     2.6000 33.700   0.70200   0.0400     1.2800; ...
 39  2.27  1.62   88.9058500  3611.0000  1799.0000     4.5000 19.800   0.77500   0.1500     1.2800; ...
 40  2.16  1.45   91.2240000  4682.0000  2125.0000     6.4900 14.100   0.71600   0.1600     0.1850; ...
 41  2.09  1.34   92.9063800  5017.0000  2740.0000     8.5500 10.870   0.70540   0.0024     1.1500; ...
 42  2.01  1.30   95.9400000  4912.0000  2890.0000    10.2000  9.400   0.69500   0.2800     2.5500; ...
 43  1.95  1.27   98.9100000  4538.0000  2473.0000    11.5000  8.500   0.68000   0.0000    20.0000; ...
 44  1.89  1.25  101.0700000  4423.0000  2523.0000    12.2000  8.300   0.72100   0.0700     2.5600; ...
 45  1.83  1.25  102.9055000  3970.0000  2236.0000    12.4000  8.300   0.58800   0.0000   145.0000; ...
 46  1.79  1.28  106.4200000  3237.0000  1825.0000    12.0000  8.900   0.59100   0.0930     6.9000; ...
 47  1.75  1.34  107.8682000  2436.0000  1234.0000    10.5000 10.300   0.59220   0.5800    63.3000; ...
 48  1.71  1.48  112.4110000  1040.0000   594.1800     8.6500 13.100   0.51000   2.4000  2520.0000; ...
 49  2.00  1.44  114.8200000  2346.0000   429.7600     7.3100 15.700   0.40650   0.5400   193.8000; ...
 50  1.72  1.41  118.7100000  2876.0000   505.0600     7.3000 16.300   0.62280   0.0220     0.6260; ...
 51  1.53  1.40  121.7500000  1860.0000   904.0000     6.6800 18.230   0.56410   0.3000     5.1000; ...
 52  1.42  1.36  127.6000000  1261.0000   722.6500     6.2400 20.500   0.54300   0.0200     4.7000; ...
 53  1.32  1.33  126.9044700   458.4000   386.7000     4.9200 25.740   0.52800   0.0000     6.2000; ...
 54  1.24  1.31  131.2900000   165.0300   161.3600     5.8900 37.300   0.48500   0.0000    23.9000; ...
 55  3.34  2.35  132.9054300   944.0000   301.5500     1.8700 71.070   0.54200   0.2100    29.0000; ...
 56  2.78  1.98  137.3270000  2171.0000  1002.0000     3.5000 39.240   0.52500   0.0100     1.2000; ...
 57  2.74  1.69  138.9055000  3730.0000  1193.0000     6.7000 20.730   0.82400   1.1300     8.9700; ...
 58  2.70  1.65  140.1150000  3699.0000  1071.0000     6.7800 20.670   0.48400   0.0000     0.6300; ...
 59  2.67  1.65  140.9076500  3785.0000  1204.0000     6.7700 20.800   0.44500   0.0160    11.5000; ...
 60  2.64  1.64  144.2400000  3341.0000  1289.0000     7.0000 20.600   0.76900  11.0000    50.5000; ...
 61  2.62  1.63  145.0000000  3785.0000  1204.0000     6.4750 22.390   1.26000   1.3000   168.4000; ...
 62  2.59  1.62  150.3600000  2064.0000  1345.0000     7.5400 19.950   0.42000  50.0000  5670.0000; ...
 63  2.56  1.85  151.9650000  1870.0000  1090.0000     5.2600 28.900   0.66800   2.2000  4600.0000; ...
 64  2.54  1.61  157.2500000  3539.0000  1585.0000     7.8900 19.900   0.95000 158.0000 48890.0000; ...
 65  2.51  1.59  158.9253400  3496.0000  1630.0000     8.2700 19.200   0.73800   0.0040    23.4000; ...
 66  2.49  1.59  162.5000000  2835.0000  1682.0000     8.5400 19.000   1.69000  54.5000   940.0000; ...
 67  2.47  1.58  164.9303200  2968.0000  1743.0000     8.8000 18.700   0.80800   0.3600    64.7000; ...
 68  2.45  1.57  167.2600000  3136.0000  1795.0000     9.0500 18.400   0.80300   1.2000   159.2000; ...
 69  2.42  1.56  168.9342100  2220.0000  1818.0000     9.3300 18.100   0.70500   0.4100   105.0000; ...
 70  2.40  1.74  173.0400000  1467.0000  1097.0000     6.9800 24.790   1.24000   3.0000    35.1000; ...
 71  2.25  1.56  174.9670000  3668.0000  1936.0000     9.8400 17.780   0.73000   0.1000    76.4000; ...
 72  2.16  1.44  178.4900000  4876.0000  2500.0000    13.1000 13.600   0.77700   2.6000   104.1000; ...
 73  2.09  1.34  180.9479000  5731.0000  3287.0000    16.6000 10.900   0.69100   0.0200    20.6000; ...
 74  2.02  1.30  183.8500000  5828.0000  3680.0000    19.3000  9.530   0.47700   2.0000    18.4000; ...
 75  1.97  1.28  186.2070000  5869.0000  3453.0000    21.0000  8.850   0.92000   0.9000    90.7000; ...
 76  1.92  1.26  190.2000000  5285.0000  3300.0000    22.4000  8.490   1.10000   0.4000    16.0000; ...
 77  1.87  1.27  192.2200000  4701.0000  2716.0000    22.5000  8.540   1.06000   0.2000   425.3000; ...
 78  1.83  1.30  195.0800000  4100.0000  2045.0000    21.4000  9.100   0.96300   0.1300    10.3000; ...
 79  1.79  1.34  196.9665400  3130.0000  1337.5800    19.3000 10.200   0.76300   0.3600    98.6500; ...
 80  1.76  1.49  200.5900000   630.0000   234.2800    13.5300 14.820   1.26600   6.7000   372.3000; ...
 81  2.08  1.48  204.3833000  1746.0000   577.0000    11.8500 17.200   0.87850   0.1400     3.4300; ...
 82  1.81  1.47  207.2000000  2023.0000   600.6000    11.4000 18.170   0.94003   0.0030     0.1710; ...
 83  1.63  1.46  208.9803700  1837.0000   544.5200     9.8000 21.300   0.85256   0.0072     0.0338; ...
 84  1.53  1.46  209.0000000  1235.0000   527.0000     9.4000 22.230  -0.01000  -0.0100    -0.0100; ...
 85  1.43  1.45  210.0000000   610.0000   575.0000    -0.0100 -0.010  -0.01000  -0.0100    -0.0100; ...
 86  1.34  1.43  222.0000000   211.0000   202.0000     9.9100 50.500  -0.01000  -0.0100    -0.0100; ...
 87  3.50  2.50  223.0000000   950.0000   300.0000    -0.0100 -0.010   0.84950   0.0072     0.0360; ...
 88  3.00  2.40  226.0250000  1809.0000   973.0000     5.0000 45.200   1.00000   0.0000    12.8000; ...
 89  3.20  2.20  227.0280000  3473.0000  1323.0000    10.0700 22.540  -0.01000  -0.0100    -0.0100; ...
 90  3.16  1.65  232.0381000  5061.0000  2028.0000    11.7000 19.900   0.98400   0.0000     7.3700; ...
 91  3.14 -0.01  231.0358800    -0.0100    -0.0100    15.4000 15.000   0.91000   0.0000   200.6000; ...
 92  3.11  1.42  238.0289000  4407.0000  1405.0000    18.9000 12.590   0.84170   0.0040     7.5700; ...
 93  3.08 -0.01  237.0480000    -0.0100   910.0000    20.4000 11.620   1.05500   0.0000   175.9000; ...
 94  3.05 -0.01  244.0000000  3503.0000   913.0000    19.8000 12.320   1.41000   0.0000   558.0000; ...
 95  3.02 -0.01  243.0000000  2880.0000  1268.0000    13.6000 17.860   0.83000   0.0000    75.3000; ...
 96  2.99 -0.01  247.0000000    -0.0100  1340.0000    13.5110 18.280   0.70000   0.0000     0.0000; ...
 97  2.97 -0.01  247.0000000    -0.0100    -0.0100    -0.0100 -0.010  -0.01000  -0.0100    -0.0100; ...
 98  2.95 -0.01  251.0000000    -0.0100   900.0000    -0.0100 -0.010  -0.01000  -0.0100    -0.0100; ...
 99  2.92 -0.01  254.0000000    -0.0100    -0.0100    -0.0100 -0.010  -0.01000  -0.0100    -0.0100; ...
100  2.90 -0.01  257.0000000    -0.0100    -0.0100    -0.0100 -0.010  -0.01000  -0.0100    -0.0100; ...
101  2.87 -0.01  258.0000000    -0.0100    -0.0100    -0.0100 -0.010  -0.01000  -0.0100    -0.0100; ...
102  2.85 -0.01  259.0000000    -0.0100    -0.0100    -0.0100 -0.010  -0.01000  -0.0100    -0.0100; ...
103  2.82 -0.01  260.0000000    -0.0100    -0.0100    -0.0100 -0.010  -0.01000  -0.0100    -0.0100 ];

ok = 1;
