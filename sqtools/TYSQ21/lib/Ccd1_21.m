function data=Ccd1_21(d2)

global z;
global k;
global phi;

data=12*exp(-z(2))*phi+6*phi*v(2)+12*phi*x(2)-12*phi*v(2)/z(1)^2+12*exp(-z(1))*phi*v(2)/z(1)^2+12*exp(-z(1))*phi*v(2)/z(1)-12*phi*x(2)/z(1)...
    +12*exp(-z(1))*phi*x(2)/z(1)-12*phi*z(1)/(z(1)+z(2))-12*exp(-z(2))*exp(-z(1))*phi*z(2)/(z(1)+z(2));
