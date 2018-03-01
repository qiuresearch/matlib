function peakdata=cryst_peaks(latconst, spcgrp)
% --- Usage:
%        peakdata=cryst_peaks(latconst, spcgrp)
% --- Purpose:
%        calculate the peak positions of each (hkl)
% --- Parameter(s):
%        latconst - [a, b, c]
%        spcgrp   - 'hexagonal' (default)
% --- Return(s):
%        peakdata    - an array
% --- Example(s):
%
% $Id: cryst_peaks.m,v 1.2 2011-10-31 20:54:52 xqiu Exp $
%

if ~exist('spcgrp', 'var')
   spcgrp='hexagonal';
end

invconst(1,:) = [2*pi/latconst(1)*2/sqrt(3),0,0];
invconst(2,:) = [invconst(1,1)/2, invconst(1,1)/2*sqrt(3),0];
invconst(3,:) = [0, 0, 2*pi/latconst(3)];

ipeak = 1;
for k=0:3
   for i=0:3
      for j=0:i
         peakdata(ipeak,1) = i;
         peakdata(ipeak,2) = j;
         peakdata(ipeak,3) = k;
         peakdata(ipeak,4) = norm([i,j,k]*invconst);
         ipeak = ipeak+1;
      end
   end
end
peakdata(:,5) = 2*pi./peakdata(:,4);
