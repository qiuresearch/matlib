function D = distmx2( r1, r2 )
% DISTMX2     calculate separation matrix between 2 sets of points
% D = DISTMX2(R1, R2)  returns MxN matrix if R1 has M and R2 N rows
%   R1 and R2 must have the same number of columns

if size(r1,2) ~= size(r2,2)
    error('R1 and R2 must have equal number of columns')
end

M = size(r1, 1);
N = size(r2, 1);
D = zeros(M, N);
for i = 1:size(r1, 2)
    r1_i = r1(:, i*ones(N, 1));
    r2_i = r2(:, i*ones(M, 1));
    D = D + (r1_i - r2_i').^2;
end
D = sqrt(D);
