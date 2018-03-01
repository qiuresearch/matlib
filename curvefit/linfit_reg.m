function [ab, covar, chi2] = linfit_reg(x,y,dy)
%        [ab, covar, chi2] = linfit_reg(x,y,dy)
%
%   Using matrix inversion to fit [x,y,dy] to y = ax+b
%
%   Optional parameter is dy, a N-column vector of standard
%   deviation of d..
%
%   Performs a weighted least square fit.
%
%   Returns ab [a, da; b db]
%   Returns var-covar, a M*M array
%   Returns chi2 (properly weighted)


% Equal weighting if none specified.
if (nargin<3)
    dy = ones(length(y),1);
end

% remove NaN in x, y, dy
inan = find(isnan(x) | isnan(y) | isnan(dy));
if ~isempty(inan)
   showinfo(num2str(length(inan), 'Data to fit contain %i NaN, removing...'), 'warning');
   x(inan) = [];
   y(inan) = [];
   dy(inan) = [];
end

% Compute the Jacobian of Y=aX+b
weight = diag(1./dy.^2);
jacobian(:,1) = x; % dY/da=X
jacobian(:,2) = 1; % dY/db=1

% Variance-Covariance matrix
inv_covar = transpose(jacobian)*weight*jacobian;
covar = inv(inv_covar);

% the solution & chi**2
ab = inv_covar\transpose(jacobian)*weight*y(:);
% ab = covar*transpose(jacobian)*weight*y(:);
chi2 =  sum((y - ab(1)*x-ab(2)).^2./dy.^2)/(length(y)-1);
ab = [ab(1), sqrt(covar(1,1)); ...
      ab(2), sqrt(covar(2,2))];
