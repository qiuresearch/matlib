function r=pdens(m,d,t)
%PDENS     calculates density of cylindrical sample
%PDENS(M,D,T)
%   M     mass in g
%   D,T   diameter and thickness in Inch

r=m./(pi/4*d.^2.*t*1e-3);
