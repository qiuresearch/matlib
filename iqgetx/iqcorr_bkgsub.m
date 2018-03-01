function [iq, bkg2] = iqcorr_bkgsub(iq, bkg, varargin);
% --- Usage:
%        [iq, bkg2] = iqcorr_bkgsub(iq, bkg, varargin);
%
% --- Purpose:
%        Subtract background scattering containing a peak. The
%        criteria is to end up wth a straight line
%
% --- Parameter(s):
%        varargin   - 'peakrange'
%
% --- Return(s): 
%
% --- Example(s):
%
% $Id: iqcorr_bkgsub.m,v 1.1 2013/09/18 00:34:13 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

% most common peaks are from 
%    Kapton
%    Mylar: [1.05, 1.25]
%    vacuum grease
%    water,
%    quartz?
peakrange = [1.05, 1.25]; % for mylar peak
method = 'linreg'; % or 'xyfit'
parse_varargin(varargin);

% 1) interpolate bkg and find imin and imax
bkg2(:,1) = iq(:,1);
bkg2(:,2) = interp1(bkg(:,1), bkg(:,2), bkg2(:,1), 'pchip');
switch length(bkg(1,:))
   case 2
      bkg2(:,3) = 1;
   case 3
      bkg2(:,3) = interp1(bkg(:,1), bkg(:,3), bkg2(:,1), 'pchip');
   otherwise
      bkg2(:,3) = interp1(bkg(:,1), bkg(:,4), bkg2(:,1), 'pchip');
end

imin = locate(iq(:,1), peakrange(1));
imax = locate(iq(:,1), peakrange(2));

% 2) search for the optimal scale
switch method
   case 'linreg'
      ab = linfit_reg(bkg2(imin:imax,2), iq(imin:imax,2), bkg2(imin:imax, 3));
      scale = ab(1,1);
      offset = ab(2,1);
   case 'xyfit'
      if ~exist('Display', 'var');
         Display = 'iter';
      end
      sOpt = optimset('Display', Display, 'MaxIter', 500, 'LargeScale', ...
                      'off', 'Algorithm', 'Levenberg-Marquardt', ...
                      'DerivativeCheck', 'off', 'Jacobian', 'off', ...
                      'LineSearchType', 'quadcubic');
      scale = fminsearch(@(x) bkgsub2linear(iq(imin:imax,:),bkg2(imin:imax,:),x), ...
                         mean(iq(imin:imax,2))/mean(bkg2(imin:imax,2)), sOpt);
      offset = 0;
   otherwise
end

iq(:,2) = iq(:,2) - bkg2(:,2)*scale -offset;

function residue = bkgsub2linear(iq, bkg, scale)
iq(:,2) = iq(:,2)-bkg(:,2)*scale;
[ab, covar, chi2] = linfit_reg(iq(:,1), iq(:,2));
residue = chi2;

