function [y, J] = coreshell_xyfit(par, x, dy)
% par(1) - inner radius
% par(2) - outer radius
% par(3) - inner density - H20 density
% par(4) - outer density - H20 density

% return the parnames and default values if no input argument
if (nargin == 0)
    %    parnames = {'innerRadius', 'outerRadius', 'innerDensity', 'outerDensity'};
    parnames = {'innerRadius', 'outerRadius'};
    y = parnames;
    J = [1,1,0,0];
    return
end

switch length(par)
    case 2
      %rho1=(.0083-.0692)*x + 3.3333+.5385; % DNA - Water
      %rho2=(.01 -.0692)*x + 1.9+.5385; % Protein - Water
      %sld = [rho1,rho2];
      bp = 37.8E3;                %bp for b221
      sld = coreshell_sld(x, bp, 290, 340);
      y = sqrt(abs(3/5 * ((sld(:,1) - sld(:,2)).*par(1)^5 + sld(:,2).*par(2)^5)./((sld(:,1) - sld(:,2)).*par(1)^3 + sld(:,2).*par(2)^3)));

      %   case 4
      %         y = sqrt(3/5 * ((par(3) - par(4)).*par(1).^5 +
      %         par(4).*par(2).^5)/((par(3) - par(4)).*par(1).^3 +
      %         par(4).*par(2).^3));
  otherwise
    showinfo('Please use two parameters only!');
end


J = 1;
% Jacobian (NEEDS TO BE UPDATED) of the function evaluated at x
% if (nargout > 1)   % two output arguments
%    J(:,1) = par(2)*cos(par(1)*x+par(3)).*x;
%    J(:,2) = y0/par(2);
%    J(:,3) = par(2)*cos(par(1)*x+par(3));
%    if (length(par) > 3)
%       J = J.*x.^par(4);
%    end
%    switch length(par)
%       case 4
%          J(:,4) = y0.*x.^par(4).*log(x);
%       case 5
%          J(:,4) = y0.*x.^par(4).*log(x);
%          J(:,5) = 1;
%       case 6
%          J(:,4) = y0.*x.^par(4).*log(x);
%          J(:,5) = 1;
%          J(:,6) = x;
%       otherwise
%    end
% end
% if error is provided
if exist('dy', 'var')
    y = y./dy;
    J = 1;
%    if (nargout > 1)   % two output arguments
%       J = J./repmat(dy, 1, length(par));
%    end
end
%  END OF CORE-SHELL
