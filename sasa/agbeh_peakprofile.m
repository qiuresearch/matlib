function [fitres, peakdata] = agbehnate_peakprofile(iq)
% --- Usage:
%        [avgdata, imgdata] = template(var)
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
% $Id: agbeh_peakprofile.m,v 1.1 2014/03/15 04:22:37 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

dspacing = 58.38;
qpeak1 = 2*pi/dspacing;

qmin = iq(1,1);
qmax = iq(end,1);

peakdata = [ceil(qmin/qpeak1):floor(qmax/qpeak1)]';
peakdata(:,2) = qpeak1*peakdata(:,1);
peakdata(:,3) = qpeak1*peakdata(:,1);


for i=1:length(peakdata(:,1))
   fitres(i) = fit_onepeak(iq, peakdata(i,3)-0.03, peakdata(i,3)+0.03, ...
                           'gauss');
   peakdata(i,[3,4,5]) = fitres(i).par_fit(1:3);
   peakdata(i,5) = fitres(i).par_fit(3)*fitres(i).scalefactor;
end

figure(1); clf; 
subplot(2,2,1); hold all; title('peak fit (Gaussian shape)');
xyplot(iq);
for i=1:length(fitres)
   plot(fitres(i).x, fitres(i).y_fit*fitres(i).scalefactor);
end
set(gca, 'yscale', 'log');
subplot(2,2,2); hold all; title('peak position');
plot(peakdata(:,2), 's');
plot(peakdata(:,3), 'o');

subplot(2,2,3); hold all; title('peak width (SigmaQ)');
plot(abs(peakdata(:,4)), 's');

subplot(2,2,4); hold all; title('peak area');
plot(abs(peakdata(:,5)), 's');
