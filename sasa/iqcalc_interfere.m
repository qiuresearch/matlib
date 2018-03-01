function iq = iq_interfere(atoms1, atoms2, varargin);
% --- Usage:
%        iq = iq_interfere(atoms1, atoms2, varargin);
% --- Purpose:
%        calculate the intereference term between two atom groups
%        based on Debye formula.
% --- Parameter(s):
%        atoms1 - 
%        atoms2 - 
%      varargin - 'verbose': 1 (default)
%                 'vac': 0 (default). 1 if in vaccum
%                 'sol': 1 (default)
%                 'r0': 1.7 (default). atom radius for shape correction
%                 'q': 0:0.005:0.5 (default). the vector to calculate
% --- Return(s): 
%        results - 
%
% --- Example(s):
%
% $Id: iqcalc_interfere.m,v 1.1 2011-10-16 22:25:40 xqiu Exp $
%
if (nargin < 1)
   help iq_calcatoms
   return
end

% 1) 
verbose = 1;
vac = 0;
sol = 1;
r0=1.7; % the average atomic radius for shape factor correction
q = 0.00:0.005:0.5;
parse_varargin(varargin);
sol = 1-vac;

if (nargin < 2)
   atoms2 = atoms1;
end

% 2)
if (sol == 1)
   atoms1.z = atoms1.z_sol;
   atoms2.z = atoms2.z_sol;
end
if (vac == 1)
   atoms1.z = atoms1.z_vac;
   atoms2.z = atoms2.z_vac;
end
   

% 3)
num_atoms1 = length(atoms1.z);
num_atoms2 = length(atoms2.z);

iq = zeros(length(q), 2);
iq(:,1) = q(:);
dist = zeros(num_atoms2,1);
showinfo(['number of atomic pairs: ' int2str(num_atoms1* num_atoms2) ...
      ', be patient ...'])
for i=1:num_atoms1
   dist(:,1) = sqrt(sum([atoms2.position(:,1) - atoms1.position(i,1), ...
                       atoms2.position(:,2) - atoms1.position(i,2), ...
                       atoms2.position(:,3) - atoms1.position(i,3)].^2,2));
   for j=1:num_atoms2
      iq(:,2) = iq(:,2) + atoms1.z(i)*atoms2.z(j)*sinc(dist(j,1)/pi*iq(:,1));
   end
end

% 4) shape factor correction
if (r0 ~= 0)
   iq(:,2) = iq(:,2) .* exp(-(r0*iq(:,1)).^2/3);
end
