function [pdr,Ntot] = split2angles( Nsteps, Ntpers )
% SPLIT2ANGLES  calculate shares of spherical angle for 100, 110, 111, 211
% [pdr,Ntot] = split2angles( Nsteps, Ntper_step )
%    directions over the 1/8 sphere (x,y,z > 0)

% use MC method:

% number of steps
if nargin < 1
    Nsteps = 1000;
end
% trials in 1 step
if nargin < 1
    Ntpers = 1000;
end
% total trials:
Ntot = Nsteps * Ntpers;
% ndr = [ n100 n110 n111 n211 ]
ndr = [ 0  0  0  0 ];
% matrix of unit vectors:
Muv = [
    [0  0  1];
    [0  1  1] / sqrt(2);
    [1  1  1] / sqrt(3);
    [1  1  2] / sqrt(6);
];
sdr = { '100', '110', '111', '211' };

if nargout == 0
    idx_report = ceil(Nsteps/10);
else
    idx_report = Nsteps+1;
end
for i=1:Nsteps
    % get unit vectors randomly distributed over the sphere surface
    phi = pi/2 * rand( Ntpers, 1 );
    z = rand( Ntpers, 1 );
    w = sqrt( 1 - z.^2 );
    r = [  w.*cos(phi),  w.*sin(phi),  z  ];
    r = sort( r' );
    % r is now 3 x Ntpers
    % direction cosines:
    sc = Muv * r;
    [ignore, nmax] = max( sc );
    for j = 1:4
	ndr(j) = ndr(j) + sum( nmax == j );
    end
    if ~rem( i, idx_report )
	fprintf( '%i  ', i );
    end
end

if nargout == 0
    fprintf('\n');
    for i = 1:4;
	fprintf('%s\t%i\t%.5f\n', sdr{i}, ndr(i), ndr(i)/sum(ndr));
    end
end

pdr = ndr / sum(ndr);
