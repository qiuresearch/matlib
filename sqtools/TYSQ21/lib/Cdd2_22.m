function data=Cdd2_22(d2)

global z;
global k;
global phi;

data=-6*phi+6*phi*w(2)+12*phi*y(2)-12*phi*w(2)/z(2)^2+12*exp(-z(2))*phi*w(2)/z(2)^2+12*exp(-z(2))*phi*w(2)/z(2)-12*phi*y(2)/z(2)...
    +12*exp(-z(2))*phi*y(2)/z(2);