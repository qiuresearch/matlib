function r=pidens(m,d,t)
%PIDENS    calculates density of cylindrical sample, sizes in Inches
%PIDENS(M,D,T)
%   M     mass in g
%   D,T   diameter and thickness in Inch

r=m./(pi/4*d.^2.*t*2.54^3);
