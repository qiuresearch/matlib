function y=exponential_xyfit(par, x, dy)
% par(1) - scale
% par(2) - exponent
% par(3) - offset
if (nargin == 0)
    parnames = {'scale', 'exponent', 'offset'};
    y = parnames;
    J = [1,1,0];
    return
end

switch length(par)
    case 3
        y = par(1)*exp(par(2)*x)+par(3);
    case 2
        y = par(1)*exp(par(2)*x);
    otherwise
        y = x;
end