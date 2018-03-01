function [sam2det, fitres] = sam2det_iqpeak(iq, dspacing, qmin, qmax)
% --- Usage:
%        [sam2det, fitres] = sam2det_iqpeak(iq, dspacing, qmin, qmax)
%
% --- Purpose:
%        A quick way to obtain the sample to detector distance        
%
% --- Parameter(s):
%        var   - 
%
% --- Return(s): 
%
% --- Example(s):
%
% $Id: sam2det_iqpeak.m,v 1.1 2010-05-25 19:55:50 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

global X_Lambda Spec_to_Phos

qbragg = 2*pi/dspacing;

fitres = fit_onepeak(iq, qmin, qmax, 'display', 0);

d_x_square = (4*pi/fitres.par_fit(1)/X_Lambda)^2-1;

dnew_old_ratio = sqrt(((4*pi/qbragg/X_Lambda)^2-1)/d_x_square);

sam2det = Spec_to_Phos*dnew_old_ratio;

showinfo(sprintf('Old Sam2Det: %9.4f, New Sam2Det: %9.4f', Spec_to_Phos, ...
                 sam2det));

%figure; xyfit_plot(fitres);
