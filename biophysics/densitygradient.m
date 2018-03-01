function dengrad = densitygradient(omega, r1, r2, rho)
% --- Usage:
%        result = gnom_runcfg(config, cfgfile)
%
% --- Purpose:
%        calculate the density gradient of centrifuge conditions
%        
% --- Parameter(s):
%        omega    (RPM)
%        r1       (cm)
%        r2       (cm)
%        rho      (g/ml)
%        
% --- Return(s): 
%        dengrad
%
% --- Example(s):
%         
%
% $Id: densitygradient.m,v 1.3 2014/02/21 18:22:12 schowell Exp $


% convert RPM to radians/second
omega = omega*2*pi/60;
r = linspace(r1, r2, 2001);
rho0 = 1.00047;

%
%weightcon = linspace(0,1200,1001);
%plot(weightcon, sverdberg(weightcon));
%density = linspace(1,2.5,1001);
%plot(density, density2weightcon(density));
%return

mode = 2;
switch mode
   case 1 % assuming constant s/D=2.16005e-9 sec^2/cm^2
      y = exp((1.080025e-9)*omega^2*r.^2);

      A = (rho-rho0)/mean(y);

      y = rho0 + A*y;
   case 2 % using the concentration dependence from Minton 1992
      weightcon = density2weightcon(rho);
      y(1) = 0;
      factor = omega*omega*(r(2)-r(1));

      % try to approach the mean weightcon by iterative search
      while abs(mean(y)/weightcon-1) > 0.001
         y(1) = y(1) + (weightcon-mean(y))/3;
         for i=2:length(r)
            y(i) = y(i-1)*(1+sverdberg(y(i-1))/diffusionconst(y(i-1))* ...
                           r(i-1)*factor);
         end
         disp(['working... target: ' num2str(weightcon) ', current: ' ...
                             num2str(mean(y))])
      end
      y = weightcon2density(y);
      
   otherwise
end

dengrad = [r;y]';
xyplot(dengrad);
title('Resulting Density Gradient')
grid on

function D = diffusionconst(weightcon)
% weightcon in g/l
% D in cm^2/sec
A0 = 2.04;
A1 = 2.03;
A2 = 18.1;
A3 = 0.507;
A4 = -3.41e-2;
A5 = -0.614;

MolMass = 168.4; % g/mol
w = weightcon/MolMass;

D = A0 + (A1-A0)*exp(-A2*w)+A3*w+A4*w.*w+A5*sqrt(w);
D = D*1e-5;
end

function s = sverdberg(weightcon)
% weightcon in g/l
% s in sec
S0 = 5.96e-1;
S1 = 3.22e-4;
S2 = 6.33e-2;
S3 = 3.99e-3;

s = S0-S1*weightcon-S2*exp(-S3*weightcon);
s = s*1e-13;
end

function density = weightcon2density(weightcon)
% weightcon in g/l
% density in g/ml

rho0 = 1.00047;
rho1 = 7.34e-4;

density = rho0 + rho1*weightcon;
end

function weightcon = density2weightcon(density)
% weightcon in g/l
% density in g/ml

rho0 = 1.00047;
rho1 = 7.34e-4;

weightcon = (density - rho0)/rho1;
end


end
