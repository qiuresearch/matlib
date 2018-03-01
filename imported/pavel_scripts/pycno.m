function [ro,err]=pycno(m1, m2)
%PYCNO     calculates density from pycnometer measurement
%   [RO,ERR]=PYCNO(M1,M2)
%	M1 is the sample mass, M2 the change of the
%       pycnometer weight after immersion of the sample
%       ERR is the relative error of this measurement
%       weights should be in grams

%CONSTANTS:
ROH2O=0.998;    %density of water
DM1=2.3e-4;     %(g) absolute error in m1
DM2=2.5e-3;     %(g) absolute error in m2

ro=ROH2O*m1./(m1-m2);
err=1./(m1-m2).*sqrt(DM2.^2+(DM1.*m2./m1).^2);
