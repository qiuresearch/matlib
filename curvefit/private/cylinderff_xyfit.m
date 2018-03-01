function [y, J] =cylinderff_xyfit(par, x, dy)
% par(1) - radius
% par(2) - height
% par(3) - scale
%      x - Q
if (nargin == 0)
    parnames = {'radius', 'height', 'scale'};
    y = parnames;
    J = [10,80,1];
end

iq = iq_cylinderff(par(1), par(2), x);
y = iq(:,2)*par(3);
