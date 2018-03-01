function [y,J]=power_xyfit(par, x, dy)
% par(1) - scale
% par(2) - offset
pow = -4;         % spherical scattering target
% pow = -2;        % lamelar scattering target
% pow = -1;        % rod-like scattering target
    
if (nargin == 0)
    parnames = {'scale', 'power', 'offset'};
    y = parnames;
    J = [1,1,0];
    return
end

y = par(1)*x.^par(2)+par(3);

if nargout > 1
    J(:,1) = x.^par(2);
    J(:,2) = par(1)*x.^(par(2)-1)*par(2);
    J(:,3) = 1;
end
% if error is provided
if exist('dy', 'var')
    y = y./dy;
    if nargout > 1   % two output arguments
        J = J./repmat(dy, 1, length(par));
    end
end