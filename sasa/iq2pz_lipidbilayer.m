function [pz, aq, signiq] = iq2pz_lipids(iq, varargin)
% --- Usage:
%        [pz, aq, signiq] = iq2pz_lipids(iq, varargin)
%
% --- Purpose:
%
% --- Parameter(s):
%        iq   - nx4 column data. 4th column is error bar.  May need
%               to interpolate first.
%        varargin - "smoothspan" width of Sgolay smoothing
%                   "dmax" to avoid local minimums too close
%                   "sphere" to interpolate the central maximum
%                   with sphere
%                   "forceminimum" the index of forced minimums
%
%
% --- Return(s): 
%
% --- Example(s):
%
% $Id: iq2pz_lipidbilayer.m,v 1.1 2014/06/12 15:07:45 xqiu Exp $
%
if (nargin < 1)
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   error('at least one parameter is required, please see the usage! ')
end

% set default parameter values
verbose = 1;
noplot = 0;
dspacing = 52.36;
qmin = iq(1,1);
npeaks = 4;
qwidth = 0.03;
signs = [-1,-1,1,-1]';

parse_varargin(varargin);

% 1) initialize the peakdata
q001 = 2*pi/dspacing;
peakdata(:,1) = floor(qmin/q001)+(1:npeaks);
peakdata(:,2) = q001*peakdata(:,1);
peakdata(:,3) = q001*peakdata(:,1);
qmax = q001*(peakdata(end,1)+1);

% 2) fit the peaks
for i=1:length(peakdata(:,1))
   fitres(i) = fit_onepeak(iq, peakdata(i,3)-qwidth, ...
                           peakdata(i,3)+qwidth, 'gauss');
   peakdata(i,[3,4,5]) = fitres(i).par_fit(1:3);
   peakdata(i,5) = fitres(i).par_fit(3)*fitres(i).scalefactor;
end

% 3) get A(Q), normalize, and multiply the sign
aq = peakdata(:,[2,5]);
aq(:,2) = sqrt(aq(:,2).*aq(:,1).^2);
aq(:,2) = aq(:,2)/sqrt((2*pi/dspacing*total(aq(:,2).^2)));
aq(:,2) = aq(:,2).*signs;

% 4) convert A(Q) to P(z)

z=linspace(-0.5,0.5,501)'*dspacing;
pz(:,1) = z;
pz(:,2) = 0;
for i = 1:length(aq(:,1))
   pz(:,2) = pz(:,2)+aq(i,2)*cos(aq(i,1)*z);
end

% 5) calculate F(Q) from P(Z);
q = linspace(0,qmax,501)';
fq(:,1) = q;
fq(:,2) = (z(2)-z(1))*2/dspacing*cos(q*z')*pz(:,2);

figure(1);
subplot(2,2,3); hold all; title('(b) Electron density profile');
xylabel('pz');
hline=xyplot(pz);
thiscolor = get(hline, 'color');

subplot(2,1,1); hold all; 
title('(a) XRD peak fit (Gaussian)');
hplot=plot(iq(:,1), iq(:,2).*iq(:,1).^2, '.', 'Color', thiscolor);
for i=1:length(fitres)
   plot(fitres(i).x, fitres(i).y_fit*fitres(i).scalefactor.*fitres(i).x.^2, ...
        '-', 'color', thiscolor);
end
xylabel('iq');
set(gca, 'yscale', 'linear');
axis tight; xlim([qmin,qmax]); ylim auto

%subplot(2,2,2); hold all; title('peak position');
%plot(peakdata(:,2), 's');
%plot(peakdata(:,3), 'o');

subplot(2,2,4); hold all; title('(c) Scattering form factor');
xylabel('pq');
xyplot(aq, 's', 'Color', thiscolor);
xyplot(fq, 'Color', thiscolor);
xlim([0,qmax]);


