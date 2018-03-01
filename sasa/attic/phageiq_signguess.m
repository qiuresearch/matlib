function [rr, iq, signiq] = phageiq_signguess(iq, varargin)
% --- Usage:
%        [avgdata, imgdata] = template(var)
%
% --- Purpose:
%   data should be already interpolated to Qmin =0, or probaby cut
%
% --- Parameter(s):
%        var   - 
%
% --- Return(s): 
%
% --- Example(s):
%
% $Id: phageiq_signguess.m,v 1.1 2014/06/12 15:07:07 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   error('at least one parameter is required, please see the usage! ')
end

% set default parameter values
smoothspan = 9; % data will be smoothed by Sgolay method
dmax = 600;     % determine the mininum interval of successive minimums
sphere = 1;     % use sphere or shell to model the central maximum
shell = 0;
parse_varargin(varargin);


% initialize first 
q = iq(:,1);
iq = iq(:,2);
if (q(1) > 0.01)
   showinfo('Qmin is not close to zero, consider to interpolate first!');
end

% 
figure(1); clf; 
subplot(2,1,1); hold all, set(gca, 'Yscale', 'log', 'Xscale', 'linear');
plot(q, iq);
legend('original data');

% 1) smoothen it
iq = smooth(q, iq, smoothspan, 'sgolay');
hp = plot(q, iq);
legend_add(hp, 'smoothed data');

% 2) take derivative, get sign, find the mininum
signiq = sign([diff(iq); -1]);
signiq = [-2; diff(signiq)];
%plot(q, signiq.*iq/2, 's');

imin = find(signiq == 2);
if isempty(imin)
   showinfo('No local minimum found, sign guessing can not proceed!');
   return
end
showinfo([num2str(length(imin)) ' local minimums found.']);

% redo points that are closer than deltaqmin
deltaqmin = pi/dmax;
mindif = diff([0;q(imin)]);
iclose = find(mindif <= deltaqmin);
while ~isempty(iclose)
   i = iclose(1); % deal with the first one only
   [dummy, k] = min(iq(imin(i-1):imin(i)));
   imin(i-1) = imin(i-1)+k-1;
   imin(i) = [];
   mindif = diff([0;q(imin)]);
   iclose = find(mindif <= deltaqmin);
end
hp=plot(q(imin), iq(imin), 'o');
legend_add(hp, 'local minimums');

showinfo(['reduced to ' num2str(length(imin)) ' local minimum points']);

% 3) find the optimal sphere or shell approximation.

% for sphere, just try to find out whether they are the solutions to
% tan(x)=x. So just find the zero value of ((tan(x)-x).^2)' using
% Newton's method.

radius = 4.5/q(imin(1));
showinfo(['Estimated radius: ' num2str(radius)]);
q8 = q(imin(1:8));
deltar = 100;
while (abs(deltar) > 0.05)
   
   f1 = tan(q8*radius)-q8*radius;
   f2 = tan(q8*radius).^2.*q8;
   funcvalue = sum(f1.*f2);
   gradient = sum(f2.^2 + f1.*(2*tan(q8*radius).*(q8+f2)).*q8);
   deltar = -funcvalue/gradient*0.5;
   radius = radius + deltar;
end
showinfo(['Fitted radius: ' num2str(radius)]);

% 4) fit background
iq_bkg = interp1(q(imin), iq(imin), q, 'pchip');
hp=plot(q, iq_bkg);
legend_add(hp, 'fitted background');

% 5) remove background, and interpolate the central maximum
iq = iq - iq_bkg;
iq_model = iq_sphereff(radius, q);
iq_model = match(iq_model, [q,iq], [q(imin(1)), q(imin(2))]);

hp=plot(q, iq);
legend_add(hp, 'bkg removed');
hp=plot(q, iq_model(:,2));
legend_add(hp, 'model I(Q)');

legend boxoff
axis tight

% 6) assign signs and do the fourier transform
iq(1:imin(1)) = iq_model(1:imin(1),2);
iq = sqrt(abs(iq));
imin = [1;imin;length(q)];
isign = 1;
for i=1:(length(imin)-1)
   iq(imin(i):imin(i+1)) = iq(imin(i):imin(i+1))*isign;
   isign = isign*-1;
end

r = linspace(0,radius*1.5, 500);
rr = sinft([q,iq.*q], r);

subplot(2,1,2); hold all;
plot(rr(:,1), rr(:,2));

iq(:,2) = iq;
iq(:,1) = q;
