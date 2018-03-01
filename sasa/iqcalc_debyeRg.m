function iq = iq_debyeRg(rg, q)
% --- Usage:
%        iq = iq_debyeRg(rg, q)
% --- Description:
%        calculate I(Q) using debye approximation more applicable to
%        extended structures than the Guinier approximation. Q<1.4/Rg
%        iq - has 2 columns: Q vs I(Q)
%
% $Id: iqcalc_debyeRg.m,v 1.1 2012/04/04 19:44:49 xqiu Exp $
%
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

% 1) default Q range

if nargin < 2
   q = linspace(0, 2/rg, 51);
end

% 2) apply the formula

x = (rg*q).^2;

iq(:,1) = q;
iq(:,2) = 2./x.^2.*(x-1+exp(-x));

if x(1) == 0
   iq(1,2) = 1;
end
