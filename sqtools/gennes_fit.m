function [sq_fit,sq_expt] = gennes_fit(sq_expt, par, varargin)
% --- Usage:
%        [sq_fit,sq_expt] = gennes_fit(sq_expt, par, varargin)
% --- Purpose:
%        fit structure factor S(Q) with the de Gennes model (see
%        sq_gennes.m for model details).
% --- Parameter(s):
%        sq_expt - nxm (m>=2) data
%            par - parameter to sq_gennes.m
%       varargin - 'Q_range': 
%                  'autoplot': 
% --- Return(s):
%        sq_fit  - nx2 fitted data
%        sq_expt - original data but probably truncated and scaled
% --- Example(s):
%
% $Id: gennes_fit.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $
%

% 1) process input parameters
if (nargin < 1)
   help gennes_fit
   return
end
Q = sq_expt(:,1)';
Q_range = [Q(1), Q(end)];
autoplot = 1;
parse_varargin(varargin);

if ~exist('par', 'var')
   par = [3.4*25, 3, 0.55, 1.0];
end

% 2) 
i_min = locate(Q, Q_range(1));
i_max = locate(Q, Q_range(2));
sq_expt = sq_expt(i_min:i_max,:);
Q = Q(i_min:i_max);

sq_fit = sq_expt;
sq_fit(:,2) = sq_gennes(par, {Q});
sq_expt = match(sq_expt, sq_fit);

fitpar = lsqcurvefit(@sq_gennes, par, {Q}, sq_expt(:,2)')
sq_fit(:,2) = sq_gennes(fitpar, {Q});

if (autoplot == 1)
   clf
   xyplot(sq_expt), hold all, xyplot(sq_fit)
end
