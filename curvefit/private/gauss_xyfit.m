function [y, J] = gauss_xyfit(par, x, dy)
% par(1) - center
% par(2) - width (sigma)
% par(3) - area
% par(4) - bkgoffset (optional)
% par(5) - bkgslope (optional)

% return the parnames and default values if no input argument
if (nargin == 0)
    parnames = {'center', 'fullwidth', 'area', 'bkgoffset', 'bkgslope'};
    y = parnames;
    J = [1,1,1,0,0];
    return
end
y0 =  par(3)/par(2)/sqrt(2*pi)*exp(-0.5/par(2)/par(2)*(x-par(1)).^2);
switch length(par)
    case 5
        y = y0 + par(4) + par(5)*x;
    case 4
        y = y0 + par(4);
    otherwise
        y = y0;
end
% Jacobian of the function evaluated at x
if (nargout > 1)   % two output arguments
    J(:,1) = y0.*(x-par(1))/par(2)/par(2);
    J(:,2) = (1/par(2)^3*(x-par(1)).^2-1/par(2)).*y0;
    J(:,3) = y0/par(3);
    switch length(par)
        case 5
            J(:,4) = 1;
            J(:,5) = x;
        case 4
            J(:,4) = 1;
        otherwise
    end
end
% if error is provided
if exist('dy', 'var')
    y = y./dy;
    if nargout > 1   % two output arguments
        J = J./repmat(dy, 1, length(par));
    end
end
