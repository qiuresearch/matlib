function r1 = fitsprings(rs, l, k, r0)
% FITSPRINGS  find minimum energy of connected springs
% R1 = fitsprings(RS, L, K, R0)  minimize energy from starting position R0
% where
%    RS is Nx3 matrix of fixed nodes of connected springs
%    L  is vector of equilibrium spring lengths
%    K  is vector of spring constants

% make sure l and k are column vectors
l = l(:);
k = k(:);

options=optimset('Display','off','Jacobian','on', 'TolFun', 1e-8);
[r1,F,exitflag,output,JAC] = lsqnonlin(@springExpansion,r0,[],[],options,rs,l,k);

function [dL,J] = springExpansion(r, rs, l, k)
Lr = distmx2(rs, r);
dL = sqrt(k) .* (Lr - l);
if nargout > 1
    Ns = size(rs,1);
    J = sqrt(k) ./ Lr;
    J = J(:,ones(size(r,2),1)) .* (r(ones(Ns,1),:) - rs);
end
