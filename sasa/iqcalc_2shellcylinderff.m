function [iq, iq2] = iqcalc_2shellcylinderff(radius1, thickness1, ...
                                             radius2, thickness2, ...
                                             height, varargin)
% --- Usage:
%        [iq, iq2] = iqcalc_hollowcylinderff(core_radius, shell_radius, height, q, delta_alpha)
% --- Purpose:
%        Calculate the form factor of a double shell cylinder. 
%
%
% --- Parameter(s):
%
% --- Return(s):
%        iq  - the <f(theta)^2>
%        iq2 - the <f(theta)>^2
%
% --- Example(s):
%
% $Id: iqcalc_2shellcylinderff.m,v 1.1 2012/01/17 00:35:38 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

shellSLD1 = 4e-6;
shellSLD2 = 4e-6;
solventSLD = 1e-6;
q = 0.0:0.002:1.0;
delta_alpha = 0.0005;
alpha = 0.00001:delta_alpha:pi/2;
parse_varargin(varargin);

% 2) apply the formula

% set up parameters
if (radius1 > radius2)
   tmp=radius2; radius2=radius1; radius1=tmp;
   tmp=thickness2; thickness2=thickness1; thickness1=tmp;
   tmp=shellSLD2; shellSLD2=shellSLD1; shellSLD1=tmp;
end

V1= pi*(radius2+thickness2)^2*height;
V2= pi*radius2^2*height;
V3= pi*(radius1+thickness1)^2*height;
V4= pi*radius1^2*height;

SLD1=shellSLD2-solventSLD;
SLD2=solventSLD-shellSLD2;
SLD3=shellSLD1-solventSLD;
SLD4=solventSLD-shellSLD1;

iq(:,1) = q; % this is the square mean
iq(:,2) = 0; 
iq2 = iq; % this is the mean square
qhcosa = iq(:,1);
qrsina1 = iq(:,1);
qrsina2 = iq(:,1);
qrsina3 = iq(:,1);
qrsina4 = iq(:,1);
fqa = iq(:,1);

alpha
% sum over the angle
for i=1:length(alpha)
   a=alpha(i);
   qhcosa(:) = height/2*cos(a)*iq(:,1);
   qrsina1(:)=(radius2+thickness2)*sin(a)*iq(:,1);
   qrsina2(:)=radius2*sin(a)*iq(:,1);
   qrsina3(:)=(radius1+thickness1)*sin(a)*iq(:,1);
   qrsina4(:)=radius1*sin(a)*iq(:,1);

   fqa(:) = 2*sin(qhcosa)./qhcosa.*(SLD1*V1* besselj(1,qrsina1)./qrsina1+ ...
                                    SLD2*V2* besselj(1,qrsina2)./qrsina2+ ...
                                    SLD3*V3* besselj(1,qrsina3)./qrsina3+ ...
                                    SLD4*V4* besselj(1,qrsina4)./qrsina4);
   
   if iq(1,1) == 0
      fqa(1) = SLD1*V1+SLD2*V2+SLD3*V3+SLD4*V4;
   end
   
   iq(:,2) = iq(:,2) + fqa.^2*sin(a);
   iq2(:,2) = iq2(:,2) + fqa*sin(a);
end 
iq(:,2)  = delta_alpha*iq(:,2);
iq2(:,2) = (delta_alpha*iq2(:,2)).^2;
