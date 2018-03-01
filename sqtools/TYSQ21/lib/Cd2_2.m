function data=Cd2_2(d2)

global z;
global k;
global phi;

data=6*a0*phi+12*b0*phi-12*a0*phi/z(2)^2+12*a0*exp(-z(2))*phi/z(2)^2-12*b0*phi/z(2)+12*a0*exp(-z(2))*phi/z(2)+12*b0*exp(-z(2))*phi/z(2)+z(2);