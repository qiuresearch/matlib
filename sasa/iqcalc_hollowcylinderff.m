function [iq, iq2] = iqcalc_hollowcylinderff(core_radius, shell_radius, height, q, delta_alpha)
% --- Usage:
%        [iq, iq2] = iqcalc_hollowcylinderff(core_radius, shell_radius, height, q, delta_alpha)
% --- Purpose:
%        Calculate the form factor of a hollow cylinder with uniform
%        scattering density according to:
%        [http://www.ncnr.nist.gov/resources/sansmodels/HollowCylinder.html]
%        http://www.ncnr.nist.gov/resources/sansmodels/CoreShellCylinder.html
% --- Parameter(s):
%
% --- Return(s):
%        iq  - the <f(theta)^2>
%        iq2 - the <f(theta)>^2
%
% --- Example(s):
%
% $Id: iqcalc_hollowcylinderff.m,v 1.1 2012/01/17 00:35:38 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

if (nargin < 3)
   height = 3.0*radius;
end

if (nargin < 4)
   q = 0.0:0.001:0.5;
end

if (nargin < 5)
   delta_alpha = 0.001;
end

% 2) apply the formula

iq(:,1) = q; % this is the square mean
iq(:,2) = 0; 
iq2 = iq; % this is the mean square

% sum over the angle
alpha = 0.00001:delta_alpha:pi/2;
for i=1:length(alpha)
   a=alpha(i);
   if iq(1,1) <= 1e-8 % if Q=0, the limit value is 0.5 (analytical
                      % form will give an error!
       fqa = [0.5; sinc(height*cos(a)/pi*iq(2: end,1)).* besselj(1,radius*sin(a)*iq(2:end,1))./(radius*sin(a)* iq(2:end,1))];
   else
      fqa =  sinc(height*cos(a)/pi*iq(:,1))./(radius*sin(a)*iq(:,1)).*besselj(1,radius* sin(a)*iq(:,1));
   end
   iq(:,2) = iq(:,2) + fqa.^2*sin(a);
   iq2(:,2) = iq2(:,2) + fqa*sin(a);
end 
iq(:,2)  = 4.0*pi*radius*radius*height*delta_alpha*iq(:,2);
iq2(:,2) = 4.0*pi*radius*radius*height*(delta_alpha*iq2(:,2)).^2;
