function rr = iq2rr(iq, rmax)
% --- Usage:
%        rr = iq2rr(iq, rmax)
%
% --- Purpose:
%     Use iterative refinement to obtain the sign of each I(q)
%     point, and then do fourier transform to obtain the radial
%     density distribution function R(r).
%
%     
%
% --- Parameter(s):
%        var   - 
%
% --- Return(s): 
%
% --- Example(s):
%
% $Id: iq2rr_oversampling.m,v 1.1 2008-07-20 22:51:47 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   error('at least one parameter is required, please see the usage! ')
end

% probably need to interpolate the data first
q = linspace(iq(1,1), iq(end,1), length(iq(:,1)));
deltaq = q(2)-q(1);
iq = interp1(iq(:,1), iq(:,2), q, 'linear');
sumiq2 = sum(iq.^2);
qaq = sqrt(iq).*q;
sumqaq2 = sum(qaq.^2);

r = linspace(0,rmax*2,501);
deltar = r(2)-r(1);

% the large matrix
sinqr = sin(q'*r);
showinfo('Initialize the matrix ...');

% guess the sign
rand('state',sum(100*clock));
signiq = sign(rand(1,length(q))-0.5);
signiq(1) = 1;

residue1 = 1;
residue2 = 1;

figure(2); clf; hold all
%plot(q, qaq);

rrr1 = deltaq/2/pi/pi*(signiq.*qaq)*sinqr;;
imax = locate(r, rmax)
niter = 0;
while (residue1 > 1e-3) || (residue2 > 1e-2)

   % do the fourier transform
   % q*A(q) = sinFT(r*R(r))*4*pi
   % r*R(r) = sinFT(q*A(q))/8/pi^2

   rrr2 = deltaq/2/pi/pi*(signiq.*qaq)*sinqr;
   residue2 = sum((rrr2-rrr1).^2)/sum(rrr1.^2);
   
   % smooth it
   rrr2 = smooth(r, rrr2, 11)';
   plot(r,rrr2);

   
   rrr2(1:5) = 0;
   rrr2(imax:end) = 0;
   qaq2 = sinqr*(deltar*4*pi*rrr2)';
   residue1 = sum((signiq.*qaq-qaq2').^2)/sumqaq2;


   % update the sign and rrr1
   signiq = sign(qaq2)';
   rrr1 = rrr2;
   niter = niter + 1;
   showinfo(['Iteration #' num2str(niter) ': R(r) residue: ' ...
             num2str(residue2) '; I(q) residue: ' num2str(residue1)]);
   
   if (niter > 20)
      signiq(1)=1;% = sign(rand(1,length(signiq))-0.5);
      niter = 0;
      break;
   end
end

figure(1); clf; hold all;
subplot(1,2,1);
plot(r,rrr2./r);
subplot(1,2,2); cla; hold all
plot(q, qaq2);
plot(q, signiq.*qaq);
plot(q, qaq);
rr = 1;
