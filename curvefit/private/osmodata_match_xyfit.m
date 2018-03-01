function [y, J] = osmodata_match_xyfit(par, x, dy)
% matching two force cuves by an x offset and another expoential
% par(1) - delta_x
% par(2) - magnitude of exponetial force
% par(3) - decay length of exponential force

% return the parnames and default values if no input argument
if (nargin == 0)
    parnames = {'delta_x', 'magnitude', 'decay_length'};
    y = parnames;
    J = [0, 1e10, 4];
    return
end
global OSMO_COEF

y0 = OSMO_COEF(1)*exp(-(x-par(1))/OSMO_COEF(2)) + OSMO_COEF(3)* ...
     exp(-(x-par(1))/OSMO_COEF(4));

switch length(par)
  case 2
    y = y0 + par(2)*exp(-x/4); 
  case 3
    y = y0 + par(2)*exp(-x/par(3)); 
  otherwise
    y = y0;
end

% Jacobian of the function evaluated at x
if (nargout > 1)   % two output arguments
    J(:,1) = OSMO_COEF(1)*exp(-(x-par(1))/OSMO_COEF(2))/OSMO_COEF(2) ...
             + OSMO_COEF(3)*exp(-(x-par(1))/OSMO_COEF(4))/OSMO_COEF(4);
    switch length(par)
      case 2
        J(:,2) = exp(-x/4);
      case 3
        J(:,2) = exp(-x/par(3));
        J(:,3) = par(2)*exp(-x/par(3))/par(3)/par(3);
      otherwise
    end
end

% if error is provided
if exist('dy', 'var')
    y = y./dy;
    if (nargout > 1)   % two output arguments
        J = J./repmat(dy, 1, length(par));
    end
end
