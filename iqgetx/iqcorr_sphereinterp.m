function iq = iq_sphereinterp(iq, qmin, qmax, varargin)
% --- Usage:
%        rr = phageiq_interp(iq, qmin, qmax, varargin)
%
% --- Purpose:
%     Interpolate I(Q) to Qmin and Qmax for fourier transform. Low
%     Q region uses the form factor of a sphere. High Q region
%     assumes Q^-4 dependence.
%
% --- Parameter(s):
%        iq   - nx4 column data
%
% --- Return(s): 
%
% --- Example(s):
%
% $Id: iqcorr_sphereinterp.m,v 1.1 2013/09/17 03:02:58 xqiu Exp $
%

% default min and max of interpolation range
if ~exist('qmin', 'var') || isempty(qmin)
   qmin = 0.0;
end
if ~exist('qmax', 'var') || isempty(qmax)
   qmax = 0.5;
end
iguinier = 5; % only take the first few points for Guinier fit
verbose = 1;
parse_varargin(varargin);

fitres = gyration(iq, [iq(1,1), iq(iguinier,1)]);
showinfo(['Guinier region fit gives Rg=' num2str(fitres.rg), 'A'])

qgrid = iq(2,1)-iq(1,1);

% interpolate the low Q part
iq_sphere = iq_sphereff(fitres.rg/sqrt(0.8), linspace(qmin,iq(1,1),(iq(1,1)-qmin)/qgrid+1));
iq_sphere(:,2) = iq_sphere(:,2)/iq_sphere(end,2)*iq(1,2);

% interpolate the high Q part
imin = length(iq(:,1))-iguinier;
iq_q4(:,1) = iq(imin,1):qgrid:qmax;
iq_q4(:,2) = 1./iq_q4(:,1).^4;
iq_q4(:,2) = iq_q4(:,2)*mean(iq(imin:end,2))/mean(iq_q4(1:iguinier,2));
imin = locate(iq_q4(:,1), iq(imin,1));
imax = locate(iq_q4(:,1), iq(end,1));
iq_q4(imin:imax,2) = sqrt(iq_q4(imin:imax,2).*iq(end-imax+imin:end, 2));

%figure(1); clf; hold all
%xyplot(iq_sphere); xyplot(iq); xyplot(iq_q4); set(gca, 'yscale', 'log');

% patch them together
imax = locate(iq(:,1),iq_q4(1,1));
iq = [iq_sphere; iq(2:imax-1,1:2); iq_q4];
%xyplot(iq);
