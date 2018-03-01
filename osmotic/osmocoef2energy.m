function [energydata, pressuredata] = osmocoef2energy(osmocoef, ...
                                                  distance, ...
                                                  DNA_Equilibrium_Spacing, ...
                                                  varargin)
% --- Usage:
%        [energydata, pressuredata] = osmocoef2energy(osmocoef, ...
%                                  distance, DNA_Equilibrium_Spacing)
% --- Purpose:
%        return the energy per A verus distance curve. The osmocoef is
%        assumed to give the pressure/distance curve in (dyne/cm^2)
%        verus Angstrom. Hexagonal packaing is used.
%
% --- Parameter(s):
%        var   - 
%
% --- Return(s): 
%        energy (KT) per A
%
% --- Example(s):
%
% $Id: osmocoef2energy.m,v 1.5 2015/02/23 03:31:20 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end
if ~exist('distance', 'var') || isempty(distance)
   distance = 20:0.02:50;
end

if ~exist('DNA_Equilibrium_Spacing', 'var')
   DNA_Equilibrium_Spacing = 0;
end

has_vdw = 0;
parse_varargin(varargin);

x=reshape(distance, length(distance), 1);
par = osmocoef;
if (length(par) > 2) && (par(3) == 0)
   par = par(1:2);
end

% 1) get energy data

% set up some coefficients
A = sqrt(3); % dV = A*xdx (volume derivative per base pair)
% convert into KT at T=25C
temperature = 25;
kT = (4.1164092e-21)/(273.15+25)*(temperature+273.15); % in Joule
B = kT*1e31; % 31 from A^3 and 10 dyne = 1 Pascal

if (has_vdw == 1); len_par_vdw = 2; else len_par_vdw = 0; end

y0 = par(1)*A*energy_integral(par(2),x);
switch length(par)-len_par_vdw % y in unit of (dyne/cm^2)*A^3
   case 6
      y = y0+  par(3)*A*energy_integral(par(4),x) + par(5)*A* ...
          energy_integral(par(6),x);
  case 5
      y = y0 + par(3)*A*energy_integral(par(4),x) + par(5)*A* ...
          energy_integral(par(2)*2,x);
   case 4
      y = y0 + par(3)*A*energy_integral(par(4),x);
   case 3 % free magnitudes for repulsion and attraction, with
          % fixed decay length ratio
      y = y0 + par(3)*A*energy_integral(par(2)*2, x);
   case 2
      if isempty(DNA_Equilibrium_Spacing) || (DNA_Equilibrium_Spacing < 1)
         y = y0;
      else
         y = y0 - par(1)*A*energy_integral(par(2)*2, x)*exp(-DNA_Equilibrium_Spacing/par(2)/2);
      end
   otherwise
end

energydata(:,1) = x;
energydata(:,2) = y(:,1)/B;
energydata(:,3) = y(:,2)/B; % energy gradient to distance

% 2) get pressue data
if (nargout > 1)

y0 = par(1)*exp(-x/par(2));
switch length(par)-len_par_vdw
   case 6 
      y = y0 + par(3)*exp(-x/par(4)) + par(5)*exp(-x/par(6));
   case 5 
      y = y0 + par(3)*exp(-x/par(4)) + par(5)*exp(-x/par(2)/2);
   case 4
      y = y0 + par(3)*exp(-x/par(4));
   case 3
      y = y0 + par(3)*exp(-x/par(2)/2);
   case 2
      if isempty(DNA_Equilibrium_Spacing) || (DNA_Equilibrium_Spacing < 1) 
         y = y0;
      else
         y = y0 - par(1)*exp(-(x+DNA_Equilibrium_Spacing)/par(2)/2);
      end
   otherwise
end
if has_vdw
    y=y-par(end-1)*(x-par(end)).^(-2.5);
end

pressuredata(:,1) = x;
pressuredata(:,2) = y;
pressuredata(:,3) = y0; % first componet
pressuredata(:,4) = y-y0; % secod component

end

function energy = energy_integral(lambda, x0)
% get the integral of int(x0, inf)(exp(-x/lambda)*xdx)

energy(:,1) = exp(-x0/lambda).*(lambda*x0 + lambda*lambda);

% its derivative to x0
energy(:,2) =-energy(:,1)/lambda + exp(-x0/lambda)*lambda;
