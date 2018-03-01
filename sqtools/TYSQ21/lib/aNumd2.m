function data=aNumd2(d2)

global z;
global k;
global phi;

data=Ccd2_22(d2)*Cdd1_11(d2)*d2*v(1)-Ccd2_12(d2)*Cdd1_11(d2)*d2*v(2)+Ccd1_21(d2)*Ccd2_12(d2)*d2*w(1)-Ccd1_11(d2)*Ccd2_22(d2)*d2*w(1);