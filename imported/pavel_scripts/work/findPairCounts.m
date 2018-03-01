function pcnt = findPairCounts(w, sf, sfcnt)
% findPairCounts(w, sf, sfcnt)
%   w      weights from WDHIST
%   sf     atom scattering factors
%   sfcnt  sf stoichiometry

% check data consistency
N = sum(w);
if abs(N - sum(sfcnt)) > 100*eps
    error('weights not consistent with stoichiometry')
end
avgsf = sum(sf.*sfcnt)/N;
f = sf/avgsf;
if abs(w(1) - sum(f.^2 .* sfcnt)/N) > 100*eps
    error('w(1) not equal to <f^2>')
end

ij2k = []; k2ij = [];     % pair index conversion
ff = [];        % f product
k = 0;
for i=1:length(f)
    for j=i:length(f)
        k=k+1;
        ij2k(i,j) = k; ij2k(j,i) = k;
        k2ij(k,:) = [k,i,j];
        ff(end+1) = f(i)*f(j);
        totpairs(k) = sfcnt(i)*sfcnt(j);
        if i==j
            totpairs(k) = totpairs(k)/2;
        end
    end
end
Npt = length(ff);       % number of pair types

Nw = length(w)-1;
rhs = w(2:end); rhs = rhs(:)*N;
M = zeros(Nw, Nw*Npt);
for i=1:Nw
    M(i, Npt*(i-1)+(1:Npt) ) = ff;
end
for k = 1:Npt;
    row = Nw+k;
    for col = k : Npt : (Nw*Npt);
        M(row,col) = 1;
    end
    rhs(row,1) = totpairs(k);
end

pvec = lsqnonneg(M, rhs);
k2ij
pcnt = reshape(pvec, Npt, Nw)';
