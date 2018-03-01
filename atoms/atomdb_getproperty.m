function sProp = atomdb_getproperty(atoms, varargin)
% --- Usage:
%        sProp = atomdb_getproperty(atoms, varargin)
% --- Purpose:
%        obtain the property of atoms from the atomdb database.
% --- Parameter(s):
%        atoms - a cell array of atomic symbols
%        varargin - "const": set to 1 to get physical constants
%                   "sas":   set to 1 to get sas constants
% --- Return(s): 
%        sProp - the property structure with fields such as 
%
% --- Example(s):
%
% $Id: atomdb_getproperty.m,v 1.4 2015/03/01 21:50:21 xqiu Exp $
%

global atomdb_isvalid atomdb_num atomdb_sym atomdb_const atomdb_sas ...
    atomdb_nucleic atomdb_protein atomdb_sugar atomdb_asfcoeftb ...
    atomdb_compcoeftb atomdb_macoeftb atomdb_bindenergytb ...
    atomdb_xxsectiontb atomdb_f1f2coeftb

% evalin('caller', [ 'global atomdb_isvalid atomdb_num atomdb_sym ' ...
%                    'atomdb_const atomdb_sas atomdb_nucleic ' ...
%                    'atomdb_asfcoeftb atomdb_compcoeftb atomdb_macoeftb  ' ...
%                    'atomdb_bindenergytb atomdb_xxsectiontb ' ...
%                    'atomdb_f1f2coeftb ']);
% 
% check atomdb validity
if ( isempty(atomdb_isvalid) || (atomdb_isvalid == 0) )
  if ~atomdb_initialize();
    error('the atomdb property data base initialization error!');
    return
  end
end

% which properties to get
sas = 1;
const = 0;
parse_varargin(varargin)

% 1) convert character to cell if necessary
if ischar(atoms)
   atoms = cellstr(atoms);
end
if (nargin < 1) || (~iscellstr(atoms))
   error('ERROR:: a cell array of atom names should be provided!')
   help atomdb_getproperty
   return
end

% 2) get'em
atoms = upper(atoms);
for i=1:length(atoms)
   sProp(i).name = atoms{i};
   
   if (sas == 1)
      idb = strmatch(upper(sProp(i).name), atomdb_sas.name, 'exact');
      if ~isempty(idb)
         sProp(i).z = atomdb_sas.z(idb);
         sProp(i).charge = atomdb_sas.charge(idb);
         sProp(i).exclvolume = atomdb_sas.exclvolume(idb);
         sProp(i).z_sol = atomdb_sas.z_sol(idb);
         sProp(i).radius_sol = atomdb_sas.radius_sol(idb);
      else
         disp(['WARNING:: no entry found in SAS database for atom: ' ...
                sProp(i).name])
      end
   end

   if (const == 1)
      idb = strmatch(upper(sProp(i).name), atomdb_sym, 'exact');
      if ~isempty(idb)
         sProp(i).z = atomdb_const.data(idb,1);
         sProp(i).mass = atomdb_const.data(idb,4);
      else
         disp(['WARNING:: no entry found in SAS database for atom: ' ...
                sProp(i).name])
      end
   end
end
