function r1 = relaxdist(dTarget, r)
% RELAXDIST   LSQ relaxation of atom positions to fit target distances
% R1 = RELAXDIST(DTARGET, R)

N = size(r,1);
if length(dTarget) ~= N*(N-1)/2
    error('inconsistent lengths of dTarget and r')
end
dTarget = sort(dTarget);

% find target distance matrix T
D = distmx(r);
[i,j] = find(tril(ones(N),-1) == 1);
k = (N-1)*i + j;
[ignore,kidx] = sort(D(k));
k = k(kidx);
T = zeros(N);
T(k) = dTarget;
T = T+T';
opt = optimset('DerivativeCheck', 'on', 'Jacobian', 'on', 'Display', 'on');
opt = optimset('Display', 'on');
r1 = lsqnonlin(@distdiff, r, [], [], opt, T);

function [dDT,J] = distdiff(r, T)
n = size(r,1);
m = size(r,2);
D = distmx(r);
dDT = D-T;
idx = triu(ones(n),+1);
idx = (idx(:) == 1);
dDT = dDT(idx);
if nargout < 2
    return
end
% calculate Jacobi matrix
J = zeros(n*(n-1)/2, n*m);
k = 0;
for i = 1:n
    for j = i+1:n
	k = k + 1;
	for l = 1:m
	    J(k, i + n*(l-1) ) = ( r(i,l) - r(j,l) ) / D(i,j);
	    J(k, j + n*(l-1) ) = ( r(j,l) - r(i,l) ) / D(j,i);
	end
    end
end
