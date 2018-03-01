function [y, J] = guinierRg_xyfit(par, x, dy)
% par(1) - rg
% par(2) - I0
% x is Q^2; y is log(I)

% return the parnames and default values if no input argument
if (nargin == 0)
    parnames = {'Rg', 'log(I0)'};
    y = parnames;
    J = [50, 1];
    return
end

y = par(2) - (1/3*par(1)^2)*x;

% Jacobian of the function evaluated at x
if (nargout > 1)   % two output arguments
    J(:,1) = -2/3*par(1)*x;
    J(:,2) = 1;
end
% if error is provided
if exist('dy', 'var')
    y = y./dy;
    if (nargout > 1)   % two output arguments
        J = J./repmat(dy, 1, length(par));
    end
end
