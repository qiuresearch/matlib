function pr = tikhonov_regsinft(iq, r, lambda)
% --- Usage:
%        pr = tikhonov_regsinft(iq, r, lambda_tk)
%
% --- Purpose:
%        Regularize the fourier transform to deal with finite data
%        range and avoid overfitting.
%
% --- Parameter(s):
%        iq   - orginal nx2 data for transform
%        r_tk    - r vector in the transformed matrix
%        lambda_tk - the regularization parameter
%
% --- Return(s): 
%        pr - the regularized fourier transform
%
% --- Example(s):
%
% $Id: tikhonov_regsinft.m,v 1.1 2013/08/17 17:00:50 xqiu Exp $
%

verbose = 1;
global r_tk deltar q_tk iq_tk iqe_tk lambda_tk sinqr

% 1) Check input parameters
if (nargin < 1)
   help tikhonov_regsinft
   return
end
if (nargin < 2)
   r = 1:2:200;
end
if (nargin < 3)
   lambda = 1.0;
end

% 2) initialize parameters

% q; q*I(q); and r
if (iq(1,1) == 0)
   iq = iq(2:end,:);
end
num_qpoints = length(iq(:,1));
q_tk = iq(:,1);
iq_tk = iq(:,2);
deltaq = [q_tk(2)-q_tk(1); diff(q_tk)];
if (length(iq(1,:)) > 3)
   iqe_tk = iq(:,4);
else % estimate the error
   iqe_tk = error_estimate(iq, 2, 9);
end

num_rpoints = length(r);
r_tk = reshape(r, num_rpoints, 1);
deltar = r_tk(2)-r_tk(1);
% the tranform matrix
sinqr = sin(q_tk*r_tk');

% the EXACT pr = sqrt(8*pi^3)*r*pho(r)
pr = ((sqrt(2/pi)*deltaq.*iq_tk)'*sinqr)';

lambda_tk = lambda;

% 3) fit it
%  
fitopts = optimset('Display', 'iter', 'MaxIter',100, 'LargeScale', ...
                   'on', 'LevenbergMarquardt', 'off', 'LineSearchType', ...
                   'quadcubic', 'DiffMaxChange', 0.8);
  
%pr_fit = lsqnonlin(@tikhonov_optfun, pr, 1.0e-3, [], fitopts);

pr_fit = fminunc(@tikhonov_optfun, pr, fitopts);


% 4) plot them

figure(2); clf;
subplot(2,1,1); hold all
xyeplot(q_tk, iq_tk, iqe_tk);
plot(q_tk, sinqr*(sqrt(2/pi)*deltar*pr), 'g');
plot(q_tk, sinqr*(sqrt(2/pi)*deltar*pr_fit), 'r-');
legend('original data', 'error bar', 'initial guess', 'final fit');
legend boxoff

subplot(2,1,2); hold all
plot(r_tk, pr); 
plot(r_tk, pr_fit);
legend('initial guess', 'final fit');
legend boxoff

pr(:,2) = pr_fit;
pr(:,1) = r_tk;


% the residue function
function residue = tikhonov_optfun(pr)

global r_tk deltar q_tk iq_tk iqe_tk lambda_tk sinqr

iq = sinqr*(sqrt(2/pi)*deltar*pr);

residue = sqrt(mean(((iq-iq_tk)./iqe_tk).^2)) + 2e7*lambda_tk* ...
          sum((diff(pr)./sqrt(r_tk(2:end))).^2);

%          100000*lambda_tk*sum((pcf./sqrt(r_tk)).^2) + ...
%          + lambda_tk*mean(diff(pcf).^2) + 100*sum(pcf(1:20).^2);
