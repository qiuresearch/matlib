function ep = rot2ep(R)
% ROT2EP   extract Euler Parameters from rotation matrix
% E = ROT2EP(R)  rotation axis is specified as a vector

if ~isequal(size(R), [3, 3]) | norm(R*R.'-eye(3)) > 1e-12
    error('R must be 3x3 orthogonal matrix')
end

tr = trace(R);
ep2 = [ (tr + 1), [2*diag(R).' - tr + 1] ] / 4;
sig123 = [ sign(R(3,2)-R(2,3)), sign(R(1,3)-R(3,1)), sign(R(2,1)-R(1,2)) ];
ep = sqrt(ep2) .* [1, sig123];
