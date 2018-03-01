function [iq, aq] = iq_shellff(innerradius, outerradius, q)
% --- Usage:
%        [iq, aq] = iq_shellff(innerradius, outerradius, q)
% --- Description:
%        radius - radius of the sphere; q - the Q value array (0:0.001:0.5)
%        returns the form factor of a perfect sphere with uniform
%        scattering density. "iq" has 2 columns: Q vs I(Q)
%      
% $Id: iqcalc_shellff.m,v 1.1 2011-10-16 22:25:40 xqiu Exp $
%
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

if nargin < 3
   q = 0.0:0.001:0.5;
end

% 2) apply the formula

aq(:,1) = q;
iq(:,1) = q;
qr1 = iq(:,1) * innerradius;
qr2 = iq(:,1) * outerradius;
if qr1(1) == 0.0
   qr1(1) = 5;
   qr2(1) = 5;
end

aq(:,2) = 3*(sin(qr2)-qr2.*cos(qr2))./qr2.^3 - (innerradius/ ...
                                                outerradius)^3*3* ...
          (sin(qr1)-qr1.*cos(qr1))./qr1.^3;
iq(:,2) = aq(:,2).^2;

if qr1(1) == 5
   aq(1,2) = 1.0;
   iq(1,2) = 1.0;
end
