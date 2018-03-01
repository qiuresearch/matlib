function p = pclust5(N)
% probability of a good randomly build 5 atom subcluster of N-atom molecule

if N < 6
    p = 1.0;
    return
end

M = N*(N-1)/2;
p = prod((N-4):N) / prod((M-9):M) * prod(1:10)/prod(1:5);
