function data=Cdd1_12(d2)

global z;
global k;
global phi;

data=6*phi*w(2)+12*phi*y(2)-12*phi*w(2)/z(1)^2+12*exp(-z(1))*phi*w(2)/z(1)^2+12*exp(-z(1))*phi*w(2)/z(1)-12*phi*y(2)/z(1)+12*exp(-z(1))*phi*y(2)/z(1)...
    -12*phi*z(1)/(z(1)+z(2));