function [iq, aq] = iqcalc_sphereff(radius,varargin)
% --- Usage:
%        [iq, aq] = iq_sphereff(radius, q)
% --- Description:
%        radius - radius of the sphere; 
%        varargin - the Q value array (0:0.001:0.5)
%
%        returns the form factor of a perfect sphere with uniform
%        scattering density. 
%            iq - has 2 columns: Q vs I(Q)
%            aq - the amplitude
%
% $Id: iqcalc_sphereff.m,v 1.2 2012/04/04 19:37:16 xqiu Exp $
%
%

if nargin < 1
   help iq_sphereff
   return
end
parse_varargin(varargin);

if nargin < 2
   q = 0.0:0.001:0.5;
end

% 2) apply the formula

iq(:,1) = q;
aq(:,1) = q;
qr = iq(:,1) * radius;  % a temporary factor
if qr(1) == 0.0
   qr(1) = 5;
end

aq(:,2) = 3*(sin(qr)-qr.*cos(qr))./qr.^3;
iq(:,2) = aq(:,2).^2;
if qr(1) == 5
   iq(1,2) = 1.0;
   aq(1,2) = 1.0;
end
