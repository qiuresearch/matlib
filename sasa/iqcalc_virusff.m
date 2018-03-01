function [iq, iq2] = iq_virusff(r1, r2, rt, h, rhoc, rhos, rhot, rhoSol, q, delta_alpha)
% --- Usage:
%        [iq, iq2] = iq_virus(r1, r2, rt, height, q, delta_alpha)
% --- Purpose:
%        Calculate the form factor of a right cylinder with uniform
%        scattering density according to:
%        [http://www.ncnr.nist.gov/resources/sansmodels/Cylinder.html]
%        
% --- Parameter(s):
%        r1:           inner radius
%        r2:           outer radius                       
%        rt:           tail radius                       
%        height:       tail height ( height = length /2 )
%        q:            q range                           
%        delta_alpha:  angle step size                   
%
% --- Return(s):
%        iq  - the <f(theta)^2>
%        iq2 - the <f(theta)>^2
%
% --- Example(s):
%
% $Id: iqcalc_virusff.m,v 1.1 2011-10-16 22:25:40 xqiu Exp $
%

if (nargin < 1)
   help iq_virusff
   return
end

if (rt < 0 | r1 < 0 | r2 < 0)
   disp(['radius must be a positive number!'])
   rt = abs(rt);
   r1 = abs(r1);
   r2 = abs(r2);
end
if (nargin < 10)
    delta_alpha = 0.001;
    if (nargin < 9)
        q = 0.001:0.001:0.5;
    end   
end

% 2) apply the formula

v1=4/3*pi*r1^3;
v2=4/3*pi*r2^3; % treating the core shell as two spheres, one with scattering rhos and the other with scattering rhoc
vt=pi*rt^2*2*h;
dz=r2+h;
iq(:,1) = q; % this is the square mean
iq(:,2) = 0; 
iq2 = iq; % this is the mean square

% sum over the angle
alpha = 0.00001:delta_alpha:pi/2;
for i=1:length(alpha)
   a=alpha(i);
   if iq(1,1) <= 1e-8 % if Q=0, the limit value is 0.5 (analytical form will give an error!)
       fqc = [0.5; 3./(sqrt(2)*iq(2:end,1).^3)*v1*(rhoc-rhos).*(sin(iq(2:end,1)*r1)-iq(2:end,1)*r1.*cos(iq(2:end,1)*r1))/r1^3];
       fqs = [0.5; 3./(sqrt(2)*iq(2:end,1).^3)*v2*(rhos-rhoSol).*(sin(iq(2:end,1)*r2)-iq(2:end,1)*r2.*cos(iq(2:end,1)*r2))/r2^3];
       fqt = [0.5; 2*(rhot-rhoSol)*vt*sinc(h*cos(a)./pi*iq(2:end,1)).*besselj(1,rt*sin(a)*iq(2:end,1))./(rt*sin(a)*iq(2:end,1)).*exp(1i*iq(2:end,1)*dz*cos(a))];
   else
       % need the "/pi" in the argument "sinc(q H cos(a)/pi)" because in matlab sinc(x)=sin(pi x)/(pi x)
       fqc = 3./(sqrt(2)*iq(:,1).^3)*v1*(rhoc-rhos).*(sin(iq(:,1)*r1)-iq(:,1)*r1.*cos(iq(:,1)*r1))/r1^3;
       fqs = 3./(sqrt(2)*iq(:,1).^3)*v2*(rhos-rhoSol).*(sin(iq(:,1)*r2)-iq(:,1)*r2.*cos(iq(:,1)*r2))/r2^3;
       fqt = 2*(rhot-rhoSol)*vt*sinc(h*cos(a)/pi*iq(:,1)).*besselj(1,rt* sin(a)*iq(:,1))./(rt*sin(a)*iq(:,1)).*exp(1i*iq(:,1)*dz*cos(a));
   end
   iq(:,2) = iq(:,2) + (fqc+fqs+fqt).*conj(fqc+fqs+fqt)*sin(a);
   iq2(:,2) = iq2(:,2) + (fqc+fqs+fqt)*sin(a);
end 
 iq(:,2)  = delta_alpha*iq(:,2);
 iq2(:,2) = (delta_alpha*iq2(:,2)).*conj(delta_alpha*iq2(:,2));
