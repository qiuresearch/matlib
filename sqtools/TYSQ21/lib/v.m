function y=v(i)

global z;
global k;
global phi;

y=-12*phi*(1+2*phi)*(1-exp(-z(i))*(1+z(i)))/z(i)/(1-2*phi+phi^2) ...
    +8*(1/z(i)^2 - exp(-z(i))*(1/2 + (1+z(i))/z(i)^2)) ...
    +(8*(1+2*phi)*(-1+4*phi)*(1/z(i)^2 - exp(-z(i))*(1/2+(1+z(i))/z(i)^2)))/(1-2*phi+phi^2);