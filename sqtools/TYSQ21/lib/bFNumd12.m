function data=bFNumd12()

global z;
global k;
global phi;

data=Ccd2_22*Cdd1_12*x(1) - Ccd1_21*Cdd2_22*x(1) - ...
    Ccd2_12*Cdd1_12*x(2) + Ccd1_11 * Cdd2_22*x(2) + Ccd1_21*Ccd2_12*y(2) - Ccd1_11*Ccd2_22*y(2);