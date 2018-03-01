function y=c_Numd1_2(d2)

global z;
global k;
global phi;

y=-Ccd2_12*Cd1_1*d2+Ccd1_11*Cd2_2*d2-Ccd2_12*Cdd1_12*d2.^2+Ccd1_11*Cdd2_22*d2.^2-Ccd1_11*k(2);
%y=Ccd1_11*Cdd2_12-Ccd2_12*Cd1_1*d2...
%    +Ccd1_11*Cd2_2*d2-Ccd2_12*Cdd1_12*d2.^2+Ccd1_11*Cdd2_22*d2.^2-Ccd1_11*k(2);