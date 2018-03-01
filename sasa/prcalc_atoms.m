function [pcf, iq] = prcalc_atoms(atoms, varargin)
% --- Usage:
%        [pcf, iq] = pcf_calcatoms(atoms, varargin)
% --- Purpose:
%    calcuate the pair correlation function (PCF) from the atoms structure.
%
% --- Parameter(s):
%        atoms - a structure of arrays (see atoms_readpdb.m for details)
%        varargin - a single string, or pairs (see parse_varargin.m)
%
% --- Return(s):
%        pcf -
%
% --- Calling Method(s):
%
% --- Example(s):
%
% $Id: prcalc_atoms.m,v 1.8 2015/01/12 17:02:33 schowell Exp $
% RATE: 3.5

% 1) Simple check on input parameters
if (nargin < 1)
    disp('ERROR:: an array of structures "atoms" should be provided!');
    help pcf_calcatoms
    return
end

% some default setups
vac = 0; % whether to use vaccuum or solution Z number
smooth = 0;
r_min=0.6;     % mininum distance between atoms
r0 = 1.7; % average atomic radius for shape factor correction to I(Q)
method = 1; % 1: C code; 2: matlab code; 3: C code without normalization
if 3 > method
    normalize = 1;
elseif 3 == method
    normalize = 0;
end

verbose = 1;
parse_varargin(varargin);
sol = 1-vac;

% read PDB file if passed
if ischar(atoms)
    atoms = atoms_readpdb(atoms);
end
% default from 0 to the maximum distance
if ~exist('r', 'var')
    r = 0:2000;
end

% 2) Prepare some variables
num_rpoints = length(r);
r_range = [r(1), r(num_rpoints)];
r_grid = (r_range(2)-r_range(1))/(num_rpoints-1);
pcf = zeros(num_rpoints, 2);
pcf(:,1) = r(:);

if (sol == 1)
    weights = atoms.z_sol;
end
if (vac == 1)
    weights = atoms.z_vac;
end

% 3) calcualte P(r)
switch method
    case 1
        fprintf('using prcalc.c\n')
        pcf = prcalc(atoms.position, atoms.z_sol, r(end));
    case 3
        fprintf('Not normalizing result (using prcalc_noNorm.c)\n')
        pcf = prcalc_noNorm(atoms.position, atoms.z_sol, r(end));
    case 2
        % Calculate the distance matrix (only upper half of the matrix is
        % used!)
        fprintf('using matlab method\n')
        num_atoms = length(atoms.z_vac);
        coords = atoms.position;
        %uisos = atoms.uiso;   % this seems not to be considered in SAS
        num_pairs = num_atoms*(num_atoms-1)/2;
        dist_pairs = zeros(num_pairs,1);
        weight_pairs = zeros(num_pairs,1);
        % uiso_pairs = zeros(num_pairs,1);
        
        showinfo(['calculting P(r), number of atom pairs: ' int2str(num_pairs) ])
        showinfo(['r range: (' num2str(r(1)), ', ' num2str(r(end)) ['), ' ...
            'number of points: '] int2str(num_rpoints) [', ' ...
            'smooth: '] int2str(smooth)])
        disp(['                r_min cutoff: ' num2str(r_min), ', normalize area to one: ' int2str(normalize)])
        
        i_old=1;
        for i_atom = 2:num_atoms
            i_new=i_old + i_atom - 2;
            dist_pairs(i_old:i_new) = floor(sqrt( sum(...
                [(coords(i_atom,1) - coords(1:i_atom-1,1)), ...
                (coords(i_atom,2) - coords(1:i_atom-1,2)), ...
                (coords(i_atom,3) - coords(1:i_atom-1,3))].^2,2))/r_grid) ...
                +1;
            
            weight_pairs(i_old:i_new) = weights(i_atom)*weights(1:i_atom-1)*2;
            % uiso_pairs(i_old:i_new) = uisos(i_atom) + uisos(1:i_atom-1);
            % sum is correct for U, not for sigma.
            i_old=i_new+1;
        end
        clear coords weights
        
        % handle out of range, add them to the last point
        %dist_pairs(dist_pairs > num_rpoints) = num_rpoints;
        
        i_pair = 1;
        while i_pair <= num_pairs
            pcf(dist_pairs(i_pair), 2) = pcf(dist_pairs(i_pair), 2) + ...
                weight_pairs(i_pair);
            i_pair = i_pair + 1;
            %   iq(:,2) = iq(:,2) + sinc(pcf(dist_pairs(i_pair)/pi*iq(:,1));
        end
        
    otherwise
        showinfo('This method is not yet implemented!');
end

% 4) postprocess the PCF
% zero the distances < r_min
if (r_min > 0.0)
    i_min = locate(r, r_min);
    pcf(1:i_min, 2)=0.0;
end
pcf(1,2) = 0.0;
% remove trailing zeros
ireal = find(pcf(:,2)>1e-10);
showinfo(['removing data beyond Dmax: ' num2str(pcf(ireal(end)+1,1)) ...
    'A']);
pcf(ireal(end)+1:end,:)=[];

% smoothening (this step is not justified, however, shouldn't be significant though)
if (smooth > 1)
    pcf(2:end,2) = pcf(2:end, 2) ./ r(2:end)';
    pcf(:,2) = r' .* conv_gauss(pcf(:,2), smooth);
end

% normalize the area to one
if (normalize == 1 && 3 ~= method)
    pcf(:,2) = pcf(:,2)/(sum(pcf(:,2))*r_grid);
end

% handle the I(Q) output
if (nargout == 2)
    %    iq = pcf_sinftiq(pcf, r_range, [0.0:0.0025:0.5], 'inverse');
    iq = iq2pr_sinft(pcf, r_range, [0.0:0.0025:0.5], 'inverse'); % iq2pr_sinft replaced pcf_sinftiq
    if (r0 ~=0) % shape factor correction
        iq(:,2) = iq(:,2) .* exp(-(r0*iq(:,1)).^2/3);
    end
end
