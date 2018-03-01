function [flowprof, flux] = flowprof_rect(y, z, varargin)
% --- Usage:
%        [flowprof, flux] = flowprof_rect(y, z, varargin)
% --- Purpose:
%        velocity profile of a rectangular section: -a<y<a, -b<z<b
%
% --- Parameter(s):
%        many parameters used, such as the dimension, viscosity,
%        etc. Need to check the program for details
% 
% --- Return(s):
%        results -
%
% --- Example(s):
%
% $Id: flowprof_rect.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $
%

% 1) parameters settings, checkings
a = 0.5;
b = 0.5;
mu = 1e-3; % the kinematic viscocity
dpdx = -1; % pressure gradient
M = 30;    % precision, number of terms
N = 30;    
method = 2;
v_avg = 0;
parse_varargin(varargin)
if isempty(y)
   [y,z] = meshgrid(linspace(-a,a,31), linspace(-b,b,31));
end
if isempty(N) % variable check due to FEMAB!!! STUPID
   N = 50;
end
if isempty(M)
   M = N(1);
end
%global a b mu M N method
a=a(1); b=b(1); mu=mu(1); dpdx=dpdx(1); M=M(1); N=N(1); v_avg= v_avg(1);


% 2) calculate the flux
i=1:2:(2*max([N,M])-1);
flux = 4*b*a^3/3/mu*(-dpdx)*(1-192*a/(pi^5)/b*sum(tanh(pi*b/2/a*i)./(i.^5)));

% 3) calculate the velocity profile
flowprof = 0*y;
switch method
   case 1 % method #1: from page 120 of book Viscous fluid flow of
          % White. It gives "NAN" for b/a > 10 or so. Use #2 if so.
      for i=1:2:(2*N-1)
         factor_mult = 16*a^2/mu/pi^3*(-dpdx) * (-1)^((i-1)/2) / i^3;
         flowprof = flowprof + factor_mult*(1-cosh(i*pi/2/a*z)./ ...
                                            cosh(i*pi*b/2/a)).*cos(i*pi/2/a*y);
      end
   case 2 % method #2: copied from code plot_2D_duct_flow.m of K. Beers. MIT
                      % ChE. 7/29/2002
      var1 = 16*(-dpdx)/mu/(pi^4);
      for m=1:2:(2*M-1)
         for n=1:2:(2*N-1)
            factor_mult = var1/m/n/((m/2/a)^2 + (n/2/b)^2);
            flowprof = flowprof+factor_mult*sin(m*pi/2/a*(y+a)) .* ...
                sin(n*pi/2/b*(z+b));
         end
      end
   otherwise
end

% 4) normalize the velocity to some average velocity if needed
if (v_avg > 0)
   ratio = flux/4/a/b/v_avg;
   flowprof = flowprof/ratio;
   flux = flux/ratio;
end
