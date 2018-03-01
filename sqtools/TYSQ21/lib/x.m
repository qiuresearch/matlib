function y=x(i)

global z;
global k;
global phi;

y=18*phi^2*(1-exp(-z(i))*(1+z(i)))/z(i) - ...
    (12*phi*(-1+4*phi)*(1/z(i)^2-exp(-z(i))*(1/2+(1+z(i))/z(i)^2)));
y=y/(1-2*phi+phi^2);