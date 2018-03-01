function data=Cdd2_12(d2)

global z;
global k;
global phi;

data=6*phi*w(1)+12*phi*y(1)-12*phi*w(1)/z(2)^2+12*exp(-z(2))*phi*w(1)/z(2)^2+12*exp(-z(2))*phi*w(1)/z(2)-12*phi*y(1)/z(2)...
    +12*exp(-z(2))*phi*y(1)/z(2)-12*phi*z(2)/(z(1)+z(2));