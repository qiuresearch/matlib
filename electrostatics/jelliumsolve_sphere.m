function sol = jelliumsolve_sphere(varargin)
% --- Usage:
%        sol = jelliumsolve_sphere(varargin)
% --- Purpose:
%        The cell model was critisized for assuming a crystal-like
%        behavior of a liquid state structure, and it is more accurate
%        for very concerntrated solutions.  The Jellium model regards
%        the macromolecule and its condensed counterions as a uniform
%        background for subtraction. The effective charge and the
%        background charge can be determined self-consistently. It
%        is more suitable for dilute moelcular solutions. Please
%        refer to Trizac and Levin PRE, 69, 031403, 2004 for details.
%   
% --- Parameter(s):
%
% --- Return(s):
%        results -
%
% --- Example(s):
%
% $Id: jelliumsolve_sphere.m,v 1.3 2013/02/28 16:52:10 schowell Exp $
%

% 1) the parameters
radius=25;
kappa = 0.05;  % the inverse Debye screening length
n = 0.5;       % DNA concentration in mM
Z = 48;        % the bare charge
l_bjerrum = 7.1139;
parse_varargin(varargin);

% 2) 
factor_z_bkg = 4*pi*l_bjerrum*n*6.02e-7;
factor_phi_D = 6.02e-7*n/(kappa^2/8/pi/l_bjerrum);
R = (1/(6.023e-7*n))^(1/3)/2;
E0 = Z*l_bjerrum/radius/radius; % the electric field at the surface
z_bkg = 3;
phi_D = asinh(z_bkg*factor_phi_D)
solopt = bvpset('Stats', 'on');
solinit = bvpinit(linspace(radius, R, 201), @jelliuminit_sphere);
sol = bvp4c(@jelliumequ_sphere, @jelliumbc_sphere, solinit, solopt);

% 3) save results
sol.radius = radius;
sol.kappa = kappa;
sol.phiR = sol.y(1,end);
sol.Z = Z;

% kPB2 = k2*cosh(sol.phiR);
% kPB = sqrt(kPB2);
% sol.Z_eff = radius/l_bjerrum*tanh(sol.phiR)/kPB*((kPB2*R-1)*sinh(kPB*(R- ...
%                                                   1))+kPB*(R- ...
%                                                   1)*cosh(kPB*(R-1)));
% sol.kappa_PB = kPB/radius;
% 
% 4) nested sub-functions used

   function dydx = jelliumequ_sphere(x, y)
      %    x: r
      % y(1): the potential in unit of KT/e
      % y(2): y(1)', -E
      %z_bkg: the background charge defined in Jellium model
      
      dydx = [ y(2)
               factor_z_bkg*z_bkg + kappa^2*sinh(y(1)) - 2*y(2)/x ];
   end   
   function res = jelliumbc_sphere(yr, yR)

   res = [yR(1) - phi_D - z_bkg*l_bjerrum/(1+kappa*2*radius)/R*exp(-kappa*(R-2*radius))
          yr(2)+E0];

        
   end
   function yinit = jelliuminit_sphere(x)
      yinit = [R*R/x/x*0.1
               +0.01 - R*R/x/x*0.01];
   end
end
