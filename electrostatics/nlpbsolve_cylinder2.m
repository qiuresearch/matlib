function sol = nlpbsolve_cylinder2(varargin)
% --- Usage:
%        sol = nlpbsolve_cylinder2(varargin)
% --- Purpose:
%        Numerically solve the non-linear PB equation in a cylindrical
%        Wigner-Seitz cell, and then predict the effective charge
%        after charge renormalization following Alexander's
%        prescription (following Trizac et al. Langmuir 2003, 19,
%        4027-4033).
%
%        The only diffference from nlpbsolve_cylinder.m is just that
%        the rescaled coordinates are used here.
% --- Parameter(s):
%
% --- Return(s):
%        results -
%
% --- Example(s):
%
% $Id: nlpbsolve_cylinder2.m,v 1.7 2015/06/09 19:12:52 xqiu Exp $
%

% 1) the parameters
Z = -48;            % bare charge
lambda = -2/3.4;    % the bare charge density (default is DNA)
radius=10;          % radius of the molecule
n = 0.6;            % concentration of macroion in mM to calculate
                    % the equivalent "R" (not used if R is set)

concen = [10,10];   % concentration of salts in mM, can be more than two
valence = [1,-1];   % valence of salt accordingly

R_factor = 1;       % the factor to multiply the used cell radius

% OPTIONAL
height = 0;         % can be derived
l_bjerrum = 7.1139; % Bjerrum length
num_points = 2000;
RelTol = 3e-4;
NMax = 500000;

parse_varargin(varargin);

% height for information only (not used in the actual calculation)
if (height == 0)
   height = abs(Z/lambda);
end

% the inverse Debye screening length
kappa = 1/debye_length(0.5*total(concen.*valence.^2));

% 2) initilize parameters the NLPB equation 
% a) to have the same macroion charge concentration
% R_con = sqrt(abs(lambda/(pi*n*Z*6.023e-7)));

if ~exist('R', 'var') || isempty(R)
   R = (3/4/pi/(6.023e-7*n))^(1/3);
end
R = R*R_factor;

E0 = 2*lambda*l_bjerrum/radius; % the electric field at the surface
kappa2 = kappa^2;

% 3) solve the NLPB equation with scaled distances
R_equ = R/radius; % rescaling parameters
E0_equ = E0*radius;
kappa2_equ = kappa2*radius*radius;
solopt = bvpset('Stats', 'on', 'FJacobian', @nlpbejacobian_cylinder, ...
                'BCJacobian', @nlpbebcjacobian, 'RelTol',RelTol, ...
                'NMax',NMax);
solinit = bvpinit(logspace(log10(1), log10(R_equ), num_points), ...
                  @nlpbeinit_cylinder);
sol = bvp4c(@nlpbequ_cylinder, @nlpbebc_cylinder, solinit, solopt);

sol.yinit = nlpbeinit_cylinder(sol.x);
sol.x = sol.x*radius;

% 4) save results & calculate the total number of ions in one cell

sol.lambda = lambda;
sol.radius = radius;
sol.height = height;
sol.n = n;
sol.eta = (radius/R)^2; % rescaled inverse distance square
sol.concen = concen;
sol.valence = valence;

% calculate the total concentration of each ion
for i=1:length(sol.concen)
   density(i,:) = sol.concen(i)*exp(-sol.valence(i)*sol.y(1,:));
   if (R_factor == 1)
      sol.concen_total(i) = total(density(i,:)*2*pi.*sol.x.*([diff(sol.x) ...
                          sol.x(end)-sol.x(end-1)]))/(pi* (sol.x(end) ...
                                                        ^2- sol.x(1)^2));
      sol.num_total(i) =  total(density(i,:)*2*pi.*sol.x.*([diff(sol.x) ...
                          sol.x(end)-sol.x(end-1)]))*6.023e-7/abs(lambda);
   else % the radius used in the solution is sometimes smaller than
        % computed directly from the concentration. Then, the total
        % average concentration needs to be corrected.
      sol.concen_total(i) = (total(density(i,:)*2*pi.*sol.x.*([diff(sol.x) ...
                          sol.x(end)-sol.x(end-1)])) + ...
                             sol.concen(i)*pi*sol.x(end)^2* ...
                             (R_factor^2-1))/(pi*(sol.x(end) ...
                                                  ^2*R_factor^2- sol.x(1)^2));
   end
end

% check charge neutrality
sol.chargeneutrality = total(sol.valence.*sol.concen_total)*pi* ...
    (sol.x(end)^2-sol.x(1)^2)*6.023e-7/sol.lambda;

sol.kappa = kappa;
sol.Z = Z;
sol.R = R;
sol.phir = sol.y(1,1);
sol.phiR = sol.y(1,end);

% 5) calculate the linear PB accordingly, noting that the
% counterion valence is not relevant here, as being annealed into
% the kapp2.

kPB2 = kappa2/total(concen.*valence.^2)*total(concen.*valence.* ...
                                              valence.*exp(-valence*sol.phiR));
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
sol.phi_lpb = [sol.x', sol.phi_lpb'];

% calculate with the analytical formula from Aubouy J.Phys. A: 36
% (2003), 5835-3840
x= lambda*l_bjerrum/(kappa*radius+0.5);
tz = (sqrt(1+x^2)-1)/x;
sol.Z_ana = Z/lambda/l_bjerrum*(2*kappa*radius*tz + 0.5*(5-(tz^4+ ...
                                                  3)/(tz^2+1))*tz);

% calculate the osmotic pressure due to ions
sol.concen_r = sol.concen.*exp(-sol.valence*sol.phir);
sol.concen_R = sol.concen.*exp(-sol.valence*sol.phiR);
sol.osmopressure = log10(total(sol.concen_R-sol.concen)*22.4/1000*101325)+1;

% 5) nested sub-functions used

   function dydx = nlpbequ_cylinder(x, y)
      %    x: r
      % y(1): the potential in unit of KT/e
      % y(2): y(1)' (derivative of y(1))
      dydx = [ y(2), -kappa2_equ/total(concen.*valence.*valence)* ...
               total(concen.*valence.*exp(-valence*y(1)))-y(2)/x ];
      
%      switch valence(1)
%         case 0   % Salt free, monovalent counterions
%            dydx = [ y(2)
%                     -kappa2_equ*exp(-y(1))/2 - y(2)/x ];
%         otherwise
%            dydx = [ y(2) -kappa2_equ/total(abs(valence))*( ...
%                sign(valence(1))*exp(-valence(1)*y(1))+ ...
%                sign(valence(2))*exp(-valence(2)*y(1)))-y(2)/x ];
%         case 1   % Monovalent salt
%            dydx = [ y(2)
%                     kappa2_equ*sinh(y(1)) - y(2)/x ];
%         case 2   % Divalent cations salt
%            dydx = [ y(2)
%                     kappa2_equ/3*(-exp(-2*y(1))+exp(y(1))) - y(2)/x ];
%         case 3   % Trivalent cations salt
%            dydx = [ y(2)
%                     kappa2_equ/3*(-exp(-2*y(1))+exp(y(1))) - y(2)/x ];
%      end
   end
   function dfdy = nlpbejacobian_cylinder(x, y)
      % Just a derivative of dydx wrt y
      dfdy = [0, 1; -kappa2_equ/total(concen.*valence.*valence)* ...
              total(-concen.*valence.*valence.*exp(-valence*y(1))), -1/x];

%      switch valence(1)
%         case 0
%            dfdy = [0, 1; kappa2_equ*exp(-y(1))/2, -1/x];
%         case 188
%            dfdy = [0 1; kappa2_equ*cosh(y(1)) -1/x];
%         case 2
%            dfdy = [0 1; kappa2_equ/3*(2*exp(-2*y(1))+exp(y(1))) -1/x];
%         otherwise
%            dfdy = [0, 1; -kappa2_equ/sum(abs(valence))*( ...
%                -valence(1)*sign(valence(1))*exp(-valence(1)*y(1)) ...
%                -valence(2)*sign(valence(2))*exp(-valence(2)*y(1))), -1/x];
%      end
   end
   function res = nlpbebc_cylinder(yr, yR)
      % residue in the boundary conditions
      % yr: yr(1), yr(2) at the starting r
      % yR: at the ending R.

      switch valence(2)
         case 0   % No execss salt case (see the reference)
            res = [yR(1),          % No potential at the boundary???
                   yr(2)+E0_equ];
         otherwise
            res = [yR(2),          % derivative == 0
                   yr(2)+E0_equ];  % electric field at the surface
      end
   end
   function [dbcdyr, dbcdyR] = nlpbebcjacobian(yr, yR)
      % the derivative of boundary conditions to values of y at r
      % and R
      switch valence(2)
         case 0
            dbcdyr = [0 0; 0 1];
            dbcdyR = [1 0; 0 0];
         otherwise
            dbcdyr = [0 0; 0 1];
            dbcdyR = [0 1; 0 0];
      end
   end
   function yinit = nlpbeinit_cylinder(x)
      yinit = [-E0_equ/(1-R_equ)/2*(x-R_equ).^2-1; -E0_equ/(1-R_equ)*(x-R_equ)];
      %lambda/3/R_equ - lambda/3*R_equ^2/x/x/x];
   end
end
