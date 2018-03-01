function data=Cdd1_11(d2)

global z;
global k;
global phi;

data=-6*phi + 6*phi*w(1) + 12*phi*y(1)-12*phi*w(1)/z(1)^2 + ...
    12*exp(-z(1))*phi*w(1)/z(1)^2 + 12*exp(-z(1))*phi*w(1)/z(1)-12*phi*y(1)/z(1)+12*exp(-z(1))*phi*y(1)/z(1);