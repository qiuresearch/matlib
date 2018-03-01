function ok = residuedb_initialize(varargin)
% --- Usage:
%        ok = residuedb_initialize(varargin)
% --- Purpose:
%        initialize the residuedb database
% --- Parameter(s):
%        rho_solvent - the electron density of the solvent
%                      (default: 0.334611(water))
% --- Return(s): 
%        results - 
%
% --- Example(s):
%
% $Id: residuedb_initialize.m,v 1.1 2008-11-04 19:20:20 xqiu Exp $
%

global residuedb_isvalid  residuedb_sym_short residuedb_sym_long ...
    residuedb_sym_full residuedb_sas

residuedb_isvalid = 0;
residuedb_sym_full = {};
residuedb_sym_long = {};
residuedb_sym_short = {};
residuedb_sas = [];

rho_solvent = 0.334611;
parse_varargin(varargin);

residuedb_sas.colnames = {'Scattering Length (1e-12 cm)', ['Density ' ...
                    '(g/cm3)'], 'Scattering Length Density (1e-6/A2)', ...
                   'Volume (A3)'}; 

residuedb_sas.rownames = {'Hydrogenated', 'H/D Exchange', 'Deuterated', ...
                    'D/H Exchange'};

% read neutron scattering length information from data file

filename = 'residuedb_neutronscatteringlength.txt';
asciidata = strtrim(cellarr_readascii(filename));

num_lines = length(asciidata);
ii = 1;
while (ii < num_lines)
   if isempty(asciidata{ii}) || ~strcmp(asciidata{ii}(end), ')');
      ii = ii + 1;
      continue
   end
   
   tokens = strsplit(asciidata{ii}, ' ');
   resname = lower(tokens{1});
   residuedb_sym_full = {residuedb_sym_full{:}, tokens{1}};
   residuedb_sym_long = {residuedb_sym_long{:}, tokens{2}(2:end)};
   residuedb_sym_short = {residuedb_sym_short{:}, tokens{4}(1)};
   
   for jj=1:4
      tokens = strsplit(asciidata{ii+jj}, ' ');
      tmp.formula{jj} = tokens{2};
      tmp.scatlen(jj,1) = str2num(tokens{3});
      if (length(tokens) == 5)
         tmp.scatlen(jj,2) = str2num(tokens{4});
         tmp.scatlen(jj,3) = str2num(tokens{5});
         tmp.scatlen(jj,4) = tmp.scatlen(jj,1)*100/tmp.scatlen(jj,3);
      end
   end
   if isfield(residuedb_sas, resname)
      resname = [resname '2'];
   end
   residuedb_sas.(resname) = tmp;
   ii = ii+5;
end

residuedb_isvalid = 1;