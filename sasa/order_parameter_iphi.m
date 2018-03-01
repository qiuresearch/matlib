function [order_parameter, iphi] = order_parameter_iphi(iphi)
% --- Usage:
%        [order_parameter, iphi] = order_parameter_iphi(iphi)
%
% --- Purpose:
%        calculate the order parameter from I(phi), the angular
%        distribution of scattering intensity
%
% --- Return(s): 
%
% --- Parameter(s):
%        var   - 
%
% --- Example(s):
%
% $Id: order_parameter_iphi.m,v 1.1 2013/08/18 04:10:55 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

% remove all negative I(phi) values
izero = find(iphi(:,2)<0);
iphi(izero,:) = [];

% reset the zero phi position to be at the maximum
[ymax, imax] = max(iphi(:,2));
iphi(:,1) = iphi(:,1)-iphi(imax,1);

% calculate <cos(phi)^2>
cosphi2 = total(iphi(:,2).*abs(sin(iphi(:,1))).*cos(iphi(:,1)).^2)/ ...
          total(iphi(:,2).*abs(sin(iphi(:,1))));

order_parameter = 0.5*(3*cosphi2-1);
