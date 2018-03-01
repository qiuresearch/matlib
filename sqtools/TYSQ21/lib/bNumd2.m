function data=bNumd2(d2)

global z;
global k;
global phi;

data=Ccd2_22*Cdd1_11*d2*x(1)-Ccd2_12*Cdd1_11*d2*x(2)+Ccd1_21*Ccd2_12*d2*y(1)-Ccd1_11*Ccd2_22*d2*y(1);