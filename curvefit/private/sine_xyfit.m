function [y, J] = sine_xyfit(par, x, dy)
% par(1) - sine frequency
% par(2) - sine amplitude
% par(3) - sine phase
% par(4) - sine decay power (or damping power)
% par(5) - sine bkgoffset
% par(6) - sine bkgslope

% return the parnames and default values if no input argument
if (nargin == 0)
    parnames = {'frequency', 'amplitude', 'phase', 'decaypower', ...
        'bkgoffset', 'bkgslope'};
    y = parnames;
    J = [1,1,0,0,0,0];
    return
end

y0 = par(2)*sin(par(1)*x+par(3));
switch length(par)
    case 4
        y = y0.*x.^par(4);
    case 5
        y = y0.*x.^par(4) + par(5);
    case 6
        y = y0.*x.^par(4) + par(5) + par(6)*x;
    otherwise
        y = y0;
end

% Jacobian of the function evaluated at x
if (nargout > 1)   % two output arguments
    J(:,1) = par(2)*cos(par(1)*x+par(3)).*x;
    J(:,2) = y0/par(2);
    J(:,3) = par(2)*cos(par(1)*x+par(3));
    if (length(par) > 3)
        J = J.*x.^par(4);
    end
    switch length(par)
        case 4
            J(:,4) = y0.*x.^par(4).*log(x);
        case 5
            J(:,4) = y0.*x.^par(4).*log(x);
            J(:,5) = 1;
        case 6
            J(:,4) = y0.*x.^par(4).*log(x);
            J(:,5) = 1;
            J(:,6) = x;
        otherwise
    end
end
% if error is provided
if exist('dy', 'var');
    y = y./dy;
    if (nargout > 1)   % two output arguments
        J = J./repmat(dy, 1, length(par));
    end
end
