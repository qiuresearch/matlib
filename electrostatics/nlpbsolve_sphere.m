function sol = nlpbsolve_sphere(varargin)
% --- Usage:
%        sol = nlpbsolve_sphere(varargin)
% --- Purpose:
%        numerically solve the non-linear PB equation in a spherical
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
% $Id: nlpbsolve_sphere.m,v 1.3 2012/06/16 16:43:25 xqiu Exp $
%

debug = 0;

% 1) the parameters
radius=27;
n = 0.6;          % concentration in mM
Z = -48;       % the bare charge
l_bjerrum = 7.1139;
num_points = 2000;
concen = [50,50]; % salt concentration in mM
valence = [1,-1]; % salt valence
parse_varargin(varargin);

% the inverse Debye screening length
kappa = 1/debye_length(0.5*total(concen.*valence.^2));

if (debug == 1)
  sol =  nlpbsolve_sphere_debug();
  return
end

% 2) new scale: distance -> distance/radius, Z -> Z*Bejrrum/radius
kappa2_equ = (kappa * radius)^2;
R_equ = (3/4/pi/(6.023e-7*n))^(1/3)/radius;  % scaled by radius
E0 = Z*l_bjerrum/radius; % the electric field at the surface (scaled)
E0_equ = E0;             % not sure how this came out, maybe initial
                         % value (05/27/2012)
solopt = bvpset('Stats', 'on', 'NMax', min([100000, num_points]));
solinit = bvpinit(linspace(1, R_equ, num_points), @nlpbeinit_sphere);
sol = bvp4c(@nlpbequ_sphere, @nlpbebc_sphere, solinit, solopt);

sol.x = sol.x*radius;
% 3) save results
sol.Z = Z;
sol.radius = radius;
sol.n = n;
sol.R = R_equ * radius;
sol.concen = concen;
sol.valence = valence;
sol.kappa = kappa;
sol.phir = sol.y(1,1);   % potential at the surface
sol.phiR = sol.y(1,end); % potential at the cell model boundary
sol.phi_nlpb = [sol.x',sol.y'];
sol.phi_nlpb_colnames = {'spacing', 'phi (kT/e)', 'E'};

% calculate the effective charge based on NLPB solution
kPB2 = kappa2_equ/total(concen.*valence.^2)* ...
       total(concen.*valence.*valence.*exp(-valence*sol.phiR));
kPB = sqrt(kPB2);
sol.Z_eff = radius/l_bjerrum*tanh(sol.phiR)/kPB*((kPB2*R_equ-1)* ...
                                                 sinh(kPB*(R_equ- ...
                                                  1))+kPB*(R_equ- ...
                                                  1)*cosh(kPB*(R_equ-1)));

% calculate the effective charge with the analytical formula without
% solving NLPB equations from Aubouy J.Phys. A: 36 (2003), 5835-3840
x= Z*l_bjerrum/radius/(2*kappa*radius+2);
tz = (sqrt(1+x^2)-1)/x;
sol.Z_ana = radius/l_bjerrum*(4*kappa*radius*tz + 2*(5-(tz^4+3)/(tz^2+1))*tz);

sol.kappa_PB = kPB/radius;
sol.phi_lpb = sol.phiR+tanh(sol.phiR)*( -1 + (kPB*R_equ+ 1)/2/kPB* ...
                                        exp((+sol.x-R_equ)* kPB)./sol.x ...
                                        + (kPB*R_equ-1)/2/kPB* ...
                                        exp((R_equ- sol.x)*kPB)./sol.x);
sol.phi_lpb = [sol.x', sol.phi_lpb'];

% calculate the osmotic pressure due to ions
sol.concen_r = sol.concen.*exp(-sol.valence*sol.phir);
sol.concen_R = sol.concen.*exp(-sol.valence*sol.phiR);
sol.osmopressure = log10(total(sol.concen_R)*22.4/1000*101325)+1;

% 4) nested sub-functions used

   function dydx = nlpbequ_sphere(x, y)
      %    x: r/a
      % y(1): the potential in unit of KT/e
      % y(2): y(1)'
      dydx = [ y(2), -kappa2_equ/total(concen.*valence.*valence)* ...
               total(concen.*valence.*exp(-valence*y(1)))-2*y(2)/x ];
   end   
   function res = nlpbebc_sphere(yr, yR)
      switch valence(2)
         case 0   % No execss salt case (see the reference)
            res = [yR(1),          % No potential at the boundary???
                   yr(2)+E0_equ];
            otherwise
               res = [yR(2),
                      yr(2)+E0_equ];
      end
   end
   function yinit = nlpbeinit_sphere(x)
      yinit = [R_equ*R_equ/x/x*0.1,
               +0.2/R_equ - 2*R_equ*R_equ/x/x/x*0.1];
   end
   function data = nlpbsolve_sphere_debug()
      % this test aims to generate a plot similar to Fig.3 in E. Triza
      % et. al Langmuir Vol. 19, No. 9 page 4027

      radius = 25; 
      eta = 0.1;
      kappa = 2.0/radius;
      n = eta/(4*pi/3*radius^3)/6.02e-7;
      
      Z = [1:2:20, 30:10:150];
      
      for i=1:length(Z)
         sol = nlpbsolve_sphere('radius', radius, 'concen', [100,100], ...
                                'valence', [1,-1], 'n', n, 'Z', Z(i));
         data(i,:) = [sol.phiR, sol.Z_eff, sol.Z, sol.R, sol.kappa_PB, sol.kappa];
      end
      figure
      plot(data(:,1), data(:,[2,3]));
      
   end
end
