function [y, J] = double_gauss_xyfit(par, x, dy)
% par(1) - center 1
% par(2) - width 1 (sigma)
% par(3) - area 1
% par(4) - center 2
% par(5) - width 2
% par(6) - area 2
% par(7) - bkgoffset (optional)
% par(8) - bkgslope (optional)

% return the parnames and default values if no input argument
if (nargin == 0)
    parnames = {'center1', 'fullwidth1', 'area1', 'center2', ...
        'fullwidth2', 'area2', 'bkgoffset', 'bkgslope'};
    y = parnames;
    J = [1,1,1,2,1,1,0,0];
    return
end
y1 =  par(3)/par(2)/sqrt(2*pi)*exp(-0.5/par(2)/par(2)*(x-par(1)).^2);
y2 =  par(6)/par(5)/sqrt(2*pi)*exp(-0.5/par(5)/par(5)*(x-par(4)).^2);
y = y1+y2;
switch length(par)
    case 8
        y(:) = y + par(7) + par(8)*x;
    case 7
        y(:) = y + par(7);
    otherwise
end

% Jacobian of the function evaluated at x
if (nargout > 1)   % two output arguments
    J(:,1) = y1.*(x-par(1))/par(2)/par(2);
    J(:,2) = (1/par(2)^3*(x-par(1)).^2-1/par(2)).*y1;
    J(:,3) = y1/par(3);
    J(:,4) = y2.*(x-par(4))/par(5)/par(5);
    J(:,5) = (1/par(5)^3*(x-par(4)).^2-1/par(5)).*y2;
    J(:,6) = y2/par(6);
    switch length(par)
        case 8
            J(:,7) = 1;
            J(:,8) = x;
        case 7
            J(:,7) = 1;
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
