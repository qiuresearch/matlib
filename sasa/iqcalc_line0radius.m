function iq = iqcalc_line0radius(height, varargin)
% --- Usage:
%        iq = iqcalc_line0radius(height)
%
% --- Purpose:
%
% --- Return(s): 
%
% --- Parameter(s):
%        var   - 
%
% --- Example(s):
%
% $Id: iqcalc_line0radius.m,v 1.1 2012/04/04 19:38:29 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

q = 0.0:0.002:0.3;
delta_gamma=0.0005;
parse_varargin(varargin);

gamma = linspace(0, 1, ceil(1/delta_gamma));
iq(:,1) = q;
iq(:,2) = 0;
qh = reshape(q, length(q),1)*height/2;
for i=1:length(gamma)
   iq(:,2) = iq(:,2) + sinc(qh*gamma(i)).^2;
end

iq(:,2) = iq(:,2)*height^2*delta_gamma;
