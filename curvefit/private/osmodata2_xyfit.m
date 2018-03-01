function [y, J] = osmodata2_xyfit(par, x, dy)
%Fit log(osmo_force) vs distance
% par(1) - repulsion1
% par(2) - decay length of repulsion1 (lambda/2)
% par(3) - repulsion2  
% par(4) - decay length of repulsion2 (lambda or any)
% par(5) - repulsion3
% par(6) - decay length of repulsion3 (lambda or any)

global DNA_Equilibrium_Spacing

% return the parnames and default values if no input argument
if (nargin == 0)
    parnames = {'mag_repulsion1', 'len_repulsion1', 'mag_repulsion2', ...
                'len_repulsion2', 'mag_repulsion3', 'len_repulsion3'};
    y = parnames;
    J = [1,2.4, 1,10, 1,4.8];
    return
end

y0 = par(1)*exp(-x/par(2));
switch length(par)
    case 6 % three exponentials
        y = y0 + par(3)*exp(-x/par(4)) + par(5)*exp(-x/par(6));
    case 5 % two repulsion (lambda/2 and electrostatic) plus lambda exponential
        y = y0 + par(3)*exp(-x/par(4)) + par(5)*exp(-x/par(2)/2);
    case 4 % fit both decay lengths
        y = y0 + par(3)*exp(-x/par(4));
    case 3 % assume the factor of two in decay length
        y = y0 + par(3)*exp(-x/par(2)/2);
    case 2 % if knowing equilibrium spacing, then, the attractive
        % can be calculated, assuming a factor of two in decay length
        if isempty(DNA_Equilibrium_Spacing) || (DNA_Equilibrium_Spacing < 1)
            y = y0;
        else
            y = y0 - par(1)*exp(-(x+DNA_Equilibrium_Spacing)/par(2)/2);
        end
    otherwise
end

% Jacobian of the function evaluated at x
if (nargout > 1)   % two output arguments
    J(:,1) = y0/par(1);
    switch length(par)
        case 6
            J(:,2) = y0.*x/par(2)/par(2);
            J(:,3) = exp(-x/par(4));
            J(:,4) = par(3)*exp(-x/par(4)).*x/par(4)/par(4);
            J(:,5) = exp(-x/par(6));
            J(:,6) = par(5)*exp(-x/par(6)).*x/(par(6)*par(6));
        case 5
            J(:,2) = y0.*x/par(2)/par(2) + par(5)*exp(-x/par(2)/2).*x/ ...
                (2*par(2)*par(2));
            J(:,3) = exp(-x/par(4));
            J(:,4) = par(3)*exp(-x/par(4)).*x/par(4)/par(4);
            J(:,5) = exp(-x/par(2)/2);
       case 4
            J(:,2) = y0.*x/par(2)/par(2);
            J(:,3) = exp(-x/par(4));
            J(:,4) = par(3)*exp(-x/par(4)).*x/par(4)/par(4);
        case 3
            J(:,2) = y0.*x/par(2)/par(2) + par(3)*exp(-x/par(2)/2).*x/ ...
                (2*par(2)*par(2));
            J(:,3) = +exp(-x/par(2)/2);
        case 2
            if isempty(DNA_Equilibrium_Spacing)  || (DNA_Equilibrium_Spacing < 1)
                J(:,2) = y0.*x/par(2)/par(2);
            else
                J(:,1) = y/par(1);
                J(:,2) = y0.*x/par(2)/par(2)-par(1)*exp(-(x+ ...
                    DNA_Equilibrium_Spacing)/par(2)/2).*(x+DNA_Equilibrium_Spacing)/(2*par(2)^2);
            end
        otherwise
    end
    J = J./repmat(y, 1, length(par))/log(10);
end

y = log10(y);

% if error is provided
if exist('dy', 'var')
    y = y./dy;
    if (nargout > 1)   % two output arguments
        J = J./repmat(dy, 1, length(par));
    end
end
