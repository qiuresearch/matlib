function [iq, iq2] = iqcalc_coreshellcylinderff(radius, thickness, ...
                                                height, varargin)
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
% $Id: iqcalc_coreshellcylinderff.m,v 1.1 2012/01/17 00:35:38 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

coreSLD = 1e-6;
shellSLD = 4e-6;
solventSLD = 1e-6;
q = 0.0:0.002:1.0;
delta_alpha = 0.0005;
alpha = 0.00001:delta_alpha:pi/2;
parse_varargin(varargin);

% 2) apply the formula

iq(:,1) = q; % this is the square mean
iq(:,2) = 0; 
iq2 = iq; % this is the mean square
qhcosa = iq(:,1);
qrsina = iq(:,1);
qrtsina = iq(:,1);
fqa = iq(:,1);

% set up parameters
Vcore = pi*radius^2*height;
Vshell = pi*(radius+thickness)^2*height;

% sum over the angle
for i=1:length(alpha)
   a=alpha(i);
   qhcosa(:) = height/2*cos(a)*iq(:,1);
   qrsina(:)=radius*sin(a)*iq(:,1);
   qrtsina(:)=(radius+thickness)*sin(a)*iq(:,1);
   
   fqa(:) = 2*sin(qhcosa)./qhcosa.*((coreSLD-shellSLD)*Vcore* ...
             besselj(1,qrsina)./qrsina +(shellSLD-solventSLD)*Vshell* ...
            besselj(1,qrtsina)./qrtsina);
   
   if iq(1,1) == 0
      fqa(1) = (coreSLD-shellSLD)*Vcore+(shellSLD-solventSLD)*Vshell;
   end
   
   iq(:,2) = iq(:,2) + fqa.^2*sin(a);
   iq2(:,2) = iq2(:,2) + fqa*sin(a);
end 
iq(:,2)  = delta_alpha*iq(:,2);
iq2(:,2) = (delta_alpha*iq2(:,2)).^2;
