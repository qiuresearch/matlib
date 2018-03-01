function [y, J] = osmodata_vdw_xyfit(par, x, dy)
% DebyeRg (see iq_debyeRg.m for details)
% par(1) - repulsion
% par(2) - decaying length of repulsion
% par(3) - attraction
% par(4) - decaying length of attraction
% par(5) - vdw attraction
% par(6) - vdw diameter

global DNA_Equilibrium_Spacing

% return the parnames and default values if no input argument
if (nargin == 0)
    parnames = {'mag_repulsion', 'len_repulsion', 'mag_attraction', ...
                'len_attraction', 'vdw_attraction', 'vdw_diamter'};
    y = parnames;
    J = [1,3,-1,1.5,-1,20];
    return
end

y0 = par(1)*exp(-x/par(2));
switch length(par)
    case 6 % fit both decaying lengths
        y = y0 + par(3)*exp(-x/par(4));
    case 5 % assume the factor of two in decaying length
        y = y0 + par(3)*exp(-x/par(2)/2);
    case 4 % if knowing equilibrium spacing, then, the attractive
        % can be calculated, assuming a factor of two in decay length
        if isempty(DNA_Equilibrium_Spacing) || (DNA_Equilibrium_Spacing < 1)
            y = y0;
        else
            y = y0 - par(1)*exp(-(x+DNA_Equilibrium_Spacing)/par(2)/2);
        end
    otherwise
end
y=y + par(end-1)*(x-par(end)).^(-2.5);

% Jacobian of the function evaluated at x
if (nargout > 1)   % two output arguments
    J(:,1) = y0/par(1);
    switch length(par)
        case 6
            J(:,2) = y0.*x/par(2)/par(2);
            J(:,3) = exp(-x/par(4));
            J(:,4) = par(3)*exp(-x/par(4)).*x/par(4)/par(4);
        case 5
            J(:,2) = y0.*x/par(2)/par(2) + par(3)*exp(-x/par(2)/2).*x/ ...
                     (2*par(2)*par(2));
            J(:,3) = exp(-x/par(2)/2);
        case 4
            if isempty(DNA_Equilibrium_Spacing)  || (DNA_Equilibrium_Spacing < 1)
                J(:,2) = y0.*x/par(2)/par(2);
            else
                J(:,1) = y0/par(1)- exp(-(x+DNA_Equilibrium_Spacing)/par(2)/2);
                J(:,2) = y0.*x/par(2)/par(2)-par(1)*exp(-(x+ ...
                    DNA_Equilibrium_Spacing)/par(2)/2).*(x+DNA_Equilibrium_Spacing)/(2*par(2)^2);
            end
       otherwise
    end
    J = [J, (x-par(end)).^(-2.5),  2.5*par(end-1)*(x-par(end)).^(-3.5)];
end

% if error is provided
if exist('dy', 'var')
    y = y./dy;
    if (nargout > 1)   % two output arguments
        J = J./repmat(dy, 1, length(par));
    end
end
