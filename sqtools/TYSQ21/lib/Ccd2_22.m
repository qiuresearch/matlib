function data=Ccd2_22(d2)

global z;
global k;
global phi;

data=-6*phi+12*exp(-z(2))*phi+6*phi*v(2)+12*phi*x(2)-12*phi*v(2)/z(2)^2+12*exp(-z(2))*phi*v(2)/z(2)^2+12*exp(-z(2))*phi*v(2)/z(2)...
    -12*phi*x(2)/z(2)+12*exp(-z(2))*phi*x(2)/z(2)-6*exp(-z(2))*exp(-z(2))*phi;