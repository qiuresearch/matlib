function data=Ccd1_11(d2)

global z;
global k;
global phi;

data=-6*phi -6*exp(-2*z(1))*phi+ 12*exp(-z(1))*phi + 6*phi*v(1) + 12*phi*x(1) - 12*phi*v(1)/z(1)^2 + 12*exp(-z(1))*phi*v(1)/z(1)^2 ...
    +12*exp(-z(1))*phi*v(1)/z(1) - 12*phi*x(1)/z(1) + 12*exp(-z(1))*phi*x(1)/z(1);