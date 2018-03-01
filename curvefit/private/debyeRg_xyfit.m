function [y, J] = debyeRg_xyfit(par, x, dy)
% par(1) - rg
% par(2) - I0

% return the parnames and default values if no input argument
if (nargin == 0)
    parnames = {'Rg', 'I0'};
    y = parnames;
    J = [50, 1];
    return
end

x0=(par(1)*x).^2;
y = par(2)*2./x0.^2.*(x0-1+exp(-x0));

% Jacobian of the function evaluated at x
if (nargout > 1)   % two output arguments
    J(:,1) = (-2./x0.*y + par(2)*2./x0.^2.*(1-exp(-x0)))*2*par(1).*x.^2;
    J(:,2) = y/par(2);
end
% if error is provided
if exist('dy', 'var')
    y = y./dy;
    if (nargout > 1)   % two output arguments
        J = J./repmat(dy, 1, length(par));
    end
end
