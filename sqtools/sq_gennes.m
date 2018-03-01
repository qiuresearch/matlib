function sq = sq_gennes(par, sFIT)
%
% par(1): the statistical segment length of polymer chains (a)
% par(2): number of cross links (Nc)
% par(3): effective interaction parameter (x_eff)
% par(4): an arbitrary scale
%

if ~exist('sFIT')
   error('sFIT is not passed!');
   return
end

Q = sFIT{1};

C = 36/(par(2)^2*par(1)^2);
sq = C./(Q.*Q) + par(3) + par(1)^2*Q.*Q/24;
sq(:) = 1./sq;
sq(:) = sq*par(4);
