function sPar = gnom_guess(pr, iq, varargin)
%
% Guess the expected values of parameters such as OSCILL, POSITV,
% VALCEN, given the P(r), usually from a known
% structure model.
%
% SYSDEV and DISCRP are calculated if I(Q) out from GNOM is provided.
%

parse_varargin(varargin);

if (nargin < 1)
   help gnom_guess
   return
end

if ~exist('Rmax', 'var')
   Rmax = pr(end,1);
end
if ~exist('Rmin', 'var')
   Rmin = pr(1,1);
end

d_r = [pr(2:end,1) - pr(1:(end-1),1); pr(end,1)-pr(end-1,1)];
norm_pr = sqrt(total(pr(:,2).^2.*d_r));

% Predict the oscillation ideal value
d_pr = [(pr(2:end,2) - pr(1:(end-1),2))./(d_r(1:(end-1),1)); 0];

sPar.OSCILL = sqrt(total(d_pr.^2.*d_r))/norm_pr;
sPar.OSCILL = sPar.OSCILL/pi*(Rmax-Rmin);

% Predict the positivity
pr_tmp = pr;
pr_tmp(find(pr(:,2) < 0), 2) = 0;
sPar.POSITV = sqrt(total(pr_tmp(:,2).^2.*d_r(:,1)))/ norm_pr;

% Predict the ValCen value
imin = locate(pr(:,1), Rmin+(Rmax-Rmin)/4);
imax = locate(pr(:,1), Rmax-(Rmax-Rmin)/4);
sPar.VALCEN = sqrt(total(pr(imin:imax,2).^2.*d_r(imin:imax,1)))/ norm_pr;


if exist('iq', 'var')

   % the systematic deviation
   diff_iq = iq(:,4)-iq(:,2);
   Ns = total(diff_iq(2:end).*diff_iq(1:end-1) <= 0);
   sPar.SYSDEV = Ns/length(iq(:,1))*2;
   
   % the descrepancy
   sPar.DISCRP = sqrt(mean((diff_iq./iq(:,3)).^2));
end

