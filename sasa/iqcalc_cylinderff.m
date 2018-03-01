function [iq, iq2] = iqcalc_cylinderff(radius, height, varargin)
% --- Usage:
%        [iq, iq2] = iq_cylinderff(radius, height, varargin)
% --- Purpose:
%        Calculate the form factor of a right cylinder with uniform
%        scattering density according to:
%        [http://www.ncnr.nist.gov/resources/sansmodels/Cylinder.html]
%        
% --- Parameter(s):
%
% --- Return(s):
%        iq  - the <f(theta)^2>
%        iq2 - the <f(theta)>^2
%
% --- Example(s):
%
% $Id: iqcalc_cylinderff.m,v 1.2 2012/01/17 00:35:38 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

SLD = 3e-6;
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
fqa = iq(:,1);

Vcyl = pi*radius*radius*height;

% sum over the angle
for i=1:length(alpha)
   a=alpha(i);
   qhcosa(:) = height/2*cos(a)*iq(:,1);
   qrsina(:)=radius*sin(a)*iq(:,1);
   
   fqa(:) = sin(qhcosa)./qhcosa.*besselj(1,qrsina)./qrsina;

   % if Q=0, the limit value is 0.5
   if iq(1,1) <= 1e-8
      fqa(1) = 0.5;
   end
   iq(:,2) = iq(:,2) + fqa.^2*sin(a);
   iq2(:,2) = iq2(:,2) + fqa*sin(a);
end 
iq(:,2)  = 4*Vcyl*delta_alpha*iq(:,2);
iq2(:,2) = 4*Vcyl*(delta_alpha*iq2(:,2)).^2;
