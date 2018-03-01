function data=bFNumd11()

global z;
global k;
global phi;

data=b0*Ccd1_21*Ccd2_12 - ...
    b0*Ccd1_11*Ccd2_22 + Ccd2_22*Cd1_1*x(1) - Ccd1_21*Cd2_2*x(1) - Ccd2_12*Cd1_1*x(2) + Ccd1_11*Cd2_2*x(2);