function M = distmx( r, flags )
% DISTMX(R)   calculate separation matrix for [n x 3] points
% D = DISTMX(R, FLAGS)  for FLAGS containing
%   'c'  returns a column vector rearanged from tril(distmx,-1)
%   's'  returns a sorted column vector of distances

if nargin < 2
    flags = '';
end
flags = lower(flags);
if length(flags) & any(flags == 's')
    flags = [ flags 'c' ];
end

n = size(r, 1);
M = zeros(n);
for i = 1:size(r, 2)
    r_i = r(:, i*ones(n, 1));
    M = M + (r_i - r_i').^2;
end
M = sqrt(M);

if length(flags) & any(flags == 'c')
    idx = tril(ones(n),-1);
    idx = (idx(:) == 1);
    M = M(idx);
end

if length(flags) & any(flags == 's')
    M = sort(M);
end
