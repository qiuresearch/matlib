function data=Cd1_1(d2)

global z;
global k;
global phi;

data=6*a0*phi+12*b0*phi-12*a0*phi/z(1)^2+12*a0*exp(-z(1))*phi/z(1)^2-12*b0*phi/z(1)+12*a0*exp(-z(1))*phi/z(1)+12*b0*exp(-z(1))*phi/z(1)+z(1);