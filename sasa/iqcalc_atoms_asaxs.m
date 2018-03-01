function [iq, iq0, pcf0] = asaxs_calcatoms(atoms, element, deltaZ, varargin);
% --- Usage:
%        [iq, iq0, pcf0] = asaxs_calcatoms(atoms, element, deltaZ, varargin);
% --- Purpose:
%        compute the anomalous scattering signal from "element"
%        with contrast of "deltaZ". 
%        The current method is to use "pcf_calcatoms" twice with
%        different contrast for "element".
% --- Parameter(s):
%        atoms - the atoms structure
%        element - the elelement symbol, such as "MG"
%        deltZ - the Z(on edge) - Z(off edge), e.g., -2
% --- Return(s): 
%        iq - the ASAXS sigal 
%        iq0 - iq0(:,2): I(Q) off edge, iq0(:,3): I(Q) on edge
%        pcf0 - ibid
% --- Example(s):
%
% $Id: iqcalc_atoms_asaxs.m,v 1.1 2013/08/23 19:14:05 xqiu Exp $
%

verbose = 1;
parse_varargin(varargin);

% 1) check parameters
if (nargin < 1)
   help asaxs_calcatoms
   return
end
if (nargin < 2)
   element = 'CO';
end
if (nargin < 3)
   deltaZ = -2;
end

% 2) prepare 
if ~isfield(atoms, 'z')
   atoms.z = atoms.z_sol;
end
index = strmatch(element, atoms.element);
if isempty(index)
   disp(['ERROR:: no atoms of type ' element ' found!'])
   return
else
   showinfo(['number of ' element ' atoms: ' int2str(length(index))]);
end

% 3) calculate
[pcf0, iq0] = pcf_calcatoms(atoms, 'normalize', 0, 'smooth', 0);
atoms.z(index) = atoms.z(index) + deltaZ;
[pcf1, iq1] = pcf_calcatoms(atoms, 'normalize', 0, 'smooth', 0);

iq = iq0;
iq(:,2) = iq0(:,2) - iq1(:,2);
iq0(:,3) = iq1(:,2);
pcf0(:,3) = pcf1(:,2);
