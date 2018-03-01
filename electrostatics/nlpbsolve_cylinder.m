function sol = nlpbsolve_cylinder(varargin)
% --- Usage:
%        sol = nlpbsolve_cylinder(varargin)
% --- Purpose:
%        numerically solve the non-linear PB equation in a cylindrical
%        Wigner-Seitz cell, and then predict the effective charge
%        after charge renormalization following Alexander's
%        prescription.
% --- Parameter(s):
%
% --- Return(s):
%        results -
%
% --- Example(s):
%
% $Id: nlpbsolve_cylinder.m,v 1.2 2013/02/28 16:52:10 schowell Exp $
%

% 1) the parameters
% REQUIRED
kappa = 0.05;  % the inverse Debye screening length
n = 0.6;      % concentration in mM
lambda = -2/3.4;  % the bare charge density (default is DNA)
radius=10;       % radius of the cylinder
height = 0;
% OPTIONAL
valence = 1;
Z = 48;        % bare charge
l_bjerrum = 7.1139; % Bjerrum length
num_points = 500;
parse_varargin(varargin);
if (height == 0)
   height = abs(Z/lambda);
end

% 2) solve the NLPB equation in real coordinates
%R = radius/sqrt(6.02e-7*n*pi*radius^2*height);  % Wigner-Seitz cell radius
R = (3/4/pi/(6.023e-7*n))^(1/3);
E0 = 2*lambda*l_bjerrum/radius; % the electric field at the surface

kappa2 = kappa^2;
solopt = bvpset('Stats', 'on', 'FJacobian', @nlpbejacobian_cylinder, ...
                'BCJacobian', @nlpbebcjacobian, 'RelTol', 1e-4, ...
                'NMax', 20000);
solinit = bvpinit(linspace(radius, R, num_points), @nlpbeinit_cylinder);
sol = bvp4c(@nlpbequ_cylinder, @nlpbebc_cylinder, solinit, solopt);

% 3) save results
sol.lambda = lambda;
sol.radius = radius;
sol.height = height;
sol.n = n;
sol.eta = (radius/R)^2;
sol.kappa = kappa;
sol.Z = Z;
sol.R = R;
sol.phi0 = sol.y(1,1);
sol.phiR = sol.y(1,end);

% calculate the kappa in linearized PB equations
switch valence
   case 0
      kPB2 = kappa2/2*exp(-sol.phiR);
   case 1
      kPB2 = kappa2*cosh(sol.phiR);
   case 2
      kPB2 = kappa2/3*(2*exp(-2*sol.phiR)+exp(sol.phiR));
   otherwise
end

kPB = sqrt(kPB2);
sol.lambda_eff = 0.5/l_bjerrum*kPB2*radius*R*tanh(sol.phiR)* ...
                 (besseli(1,kPB*R)*besselk(1,kPB*radius) - ...
                  besseli(1,kPB*radius)*besselk(1,kPB*R));
sol.Z_eff = sol.Z * sol.lambda_eff / sol.lambda;

sol.kappa_PB = kPB;

% calculate the potential from linear PB equation
sol.phi_lpb = sol.phiR + tanh(sol.phiR) *(kPB*R*(besseli(1,kPB*R)* ...
                                                 besselk(0,kPB*sol.x) ...
                                                 + besselk(1,kPB* ...
                                                  R)*besseli(0, ...
                                                  kPB*sol.x)) -1);

% 4) nested sub-functions used

   function dydx = nlpbequ_cylinder(x, y)
      %    x: r
      % y(1): the potential in unit of KT/e
      % y(2): y(1)'
      switch valence
         case 0   % Salt free, monovalent counterions
            dydx = [ y(2)
                     -kappa2*exp(-y(1))/2 - y(2)/x ];
         case 1   % Monovalent salt
            dydx = [ y(2)
                     kappa2*sinh(y(1)) - y(2)/x ];
         case 2   % Divalent cations salt
            dydx = [ y(2)
                     kappa2/3*(-exp(-2*y(1))+exp(y(1))) - y(2)/x ];
         otherwise
      end
   end   
   function dfdy = nlpbejacobian_cylinder(x, y)
      switch valence
         case 0
            dfdy = [0 1; kappa2*exp(-y(1))/2 -1/x];
         case 1
            dfdy = [0 1; kappa2*cosh(y(1)) -1/x];
         case 2
            dfdy = [0 1; kappa2/3*(2*exp(-2*y(1))+exp(y(1))) -1/x];
         otherwise
      end
   end
   function res = nlpbebc_cylinder(yr, yR)
      res = [yR(2)
             yr(2)+E0];

   end
   function [dbcdyr, dbcdyR] = nlpbebcjacobian(yr, yR)
      dbcdyr = [0 0; 0 1];
      dbcdyR = [0 1; 0 0];
   end
   function yinit = nlpbeinit_cylinder(x)
      yinit = [R*R/x/x*lambda/6
               lambda/3/R - lambda/3*R*R/x/x/x];
   end
end
