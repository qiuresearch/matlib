function [y, J]=linear_xyfit(par, x, dy)
% par(1) - slope
% par(2) - intercept
% return the parnames and default values if no input argument
if (nargin == 0)
    parnames = {'slope', 'intercept'};
    y = parnames;
    J = [1,0];
    return
end
y=par(1)*x+par(2);

% Jacobian of the function evaluated at x
if (nargout > 1)   % two output arguments
    J(:,1) = x;
    J(:,2) = 1;
end
if exist('dy', 'var')
    y = y./dy;
    if (nargout > 1)   % two output arguments
        J = J./repmat(dy, 1, length(par));
    end
end
