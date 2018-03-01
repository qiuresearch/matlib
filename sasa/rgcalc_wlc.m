function rg = rg_wlc(L, Lp, varargin)
% --- Usage:
%        rg = rg_wlc(L, Lp, varargin)
% --- Purpose:
%        calculate the Rg from worm-like chain (wlc) model
% --- Parameter(s):
%        L  - chain contour length
%        Lp - persistent length
% --- Return(s):
%        rg -
%
% --- Example(s):
%
% $Id: rgcalc_wlc.m,v 1.1 2013/09/17 03:00:33 xqiu Exp $
%

% 1) Simple check on input parameters

if nargin < 2
   help rg_wlc
   return
end

% 2)
rg = sqrt(L.*Lp/3 - Lp.^2 + 2*Lp.^3./L - 2*Lp.^4./(L.^2).*(1-exp(-1*L./Lp)));
