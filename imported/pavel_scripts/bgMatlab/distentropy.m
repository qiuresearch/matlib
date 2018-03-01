function S = distentropy(d, deltad)
% DISTENTROPY   estimate per-distance entropy in a distance list
% S = DISTENTROPY(D, DELTAD)
%
% D      -- vector of distances
% DELTAD -- tolerance for considering 2 distances equal

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<2
    deltad = 0;
end

ds = sort(d(:));
P = length(ds);
m = [];

i = 1;
while i <= P
    mi = find(ds(i+1:end) > ds(i) + deltad);
    if isempty(mi)
        mi = P - i + 1;
    else
        mi = mi(1);
    end
    m(end+1,1) = mi;
    i = i + mi;
end

S = (P.*log(P) - sum(m.*log(m))) / P;
