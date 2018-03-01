function data=Ccd2_12(d2)

global z;
global k;
global phi;

data=12*exp(-z(1))*phi+6*phi*v(1)+12*phi*x(1)-12*phi*v(1)/z(2)^2+12*exp(-z(2))*phi*v(1)/z(2)^2+12*exp(-z(2))*phi*v(1)/z(2)...
    -12*phi*x(1)/z(2)+12*exp(-z(2))*phi*x(1)/z(2)-12*phi*z(2)/(z(1)+z(2))-12*exp(-z(1)-z(2))*phi*z(1)/(z(1)+z(2));