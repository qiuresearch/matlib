function [iq, specdata] = iqcalc_atoms(atoms, varargin);
% --- Usage:
%        [iq, specdata] = iq_calcatoms(atoms, varargin);
% --- Purpose:
%        calculate the scattering intensities with the Debye formula.
%        Return: iq - nx3 matrix, [q, iq_sol, iq_vac]
%                specdata - specdata.time gives the calculation time
%                         specdata.columnnames
%                         specdata.title
% --- Parameter(s):
%        atoms - atom structure
%     varargin - 'verbose': 1 (default)
%                'r0': 1.44 (default). atom radius for shape correction
%                'q': 0:0.002:0.5 (default). the vector to calculate
%
% --- Example(s):
%
% $Id: iqcalc_atoms.m,v 1.3 2013/04/03 16:04:26 xqiu Exp $
%
if (nargin < 1)
   help iqcalc_atoms
   return
end

% 1) 
verbose = 1;
method = 1; % 1: loop through atomic pairs, 2: loop through Q data
            % points, 3: to be added (either call crysol, or try
            % the spherical harmonics method)
r0=1.444; % the average atomic radius for shape factor correction
q = 0.00:0.002:0.5;   
parse_varargin(varargin);

% 2)
z_sol = atoms.z_sol;
z_vac = atoms.z_vac;
position = atoms.position;
[num_rows, num_cols] = size(q);
if (num_rows == 1) || (num_cols ==1) % 1 D array
   q = reshape(q, num_rows*num_cols, 1);
else
end


% 3)
time_start = cputime;
num_atoms = length(z_sol);
showinfo(['number of atomic pairs: ' int2str(num_atoms*(num_atoms-1)/2) ...
          ', be patient ...']);
if (q(1,1) == 0)
   iq = zeros(length(q)-1, 3);
   iq(:,1) = q(2:end);
else
   iq = zeros(length(q), 2);
   iq(:,1) = q(:);
end

switch method
   case 1 % loop through the atomic pairs
      dist = zeros(num_atoms,1);
      sincqr = iq(:,1);
      % qr = zeros(length(iq(:,1)), num_atoms);
      for i=2:num_atoms
         dist(1:i-1,1) = sqrt(sum([position(1:i-1,1) - position(i,1), ...
                             position(1:i-1,2) - position(i,2), ...
                             position(1:i-1,3) - position(i,3)].^2, 2));
         
         % the matrix of Q*r (I was surprised that this is 20%
         % slower than doing the loop below
         %  qr(:,1:i-1) = iq(:,1)*dist(1:i-1,1)';
         %  iq(:,2) = iq(:,2)+sin(qr(:,1:i-1))./qr(:,1:i-1)*z(1:i-1,1)*z(i);
         
         for j=1:i-1
            sincqr(:) = sin(dist(j,1)*iq(:,1))./(dist(j,1)*iq(:,1));
            iq(:,2) = iq(:,2) + z_sol(i)*z_sol(j)*sincqr;
            iq(:,3) = iq(:,3) + z_vac(i)*z_vac(j)*sincqr;
         end
      end
      iq(:,2) = iq(:,2) *2 + sum(z_sol.^2);
      iq(:,3) = iq(:,3) *2 + sum(z_vac.^2);
   case 2
      disp('Not implemented yet')
   otherwise
end

if (q(1,1) == 0)
   iq = [0, sum(z_sol)^2, sum(z_vac)^2; iq];
end

% 4) shape factor correction
if (r0 ~= 0)
   iq(:,2) = iq(:,2) .* exp(-(r0*iq(:,1)).^2*(4*pi/3)^1.5/5/pi/3);
   iq(:,3) = iq(:,3) .* exp(-(r0*iq(:,1)).^2*(4*pi/3)^1.5/5/pi/3);
end

% 5) show time
calctime = cputime - time_start;

specdata.title = sprintf(['number of atomic pairs: %0i, running time: ' ...
                    '%0.1f s'], num_atoms*(num_atoms-1)/2, calctime);
specdata.columnnames = {'Q', 'IQ_sol', 'IQ_vac'};
specdata.num_pairs = num_atoms*(num_atoms-1)/2;
specdata.calctime = calctime;
specdata.time = datestr(now);
specdata.data = iq;

showinfo(sprintf('total CPU time used: %8.0fs', calctime));
