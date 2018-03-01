function data=c_Numd1_1(d2)

global z;
global k;
global phi;

data=Ccd2_22*Cd1_1*d2-Ccd1_21*Cd2_2*d2+Ccd2_22*Cdd1_12*d2.^2-Ccd1_21*Cdd2_22*d2.^2+Ccd1_21*k(2);

%y=-Ccd1_21*Cdd2_12+Ccd2_22*Cd1_1*d2...
%    -Ccd1_21*Cd2_2*d2+Ccd2_22*Cdd1_12*d2.^2-Ccd1_21*Cdd2_22*d2.^2+Ccd1_21*k(2);