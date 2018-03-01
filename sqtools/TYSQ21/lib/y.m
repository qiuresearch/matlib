function data = y(i)

global z;
global k;
global phi;

data = -12*phi*(-1+4*phi)/(1-2*phi+phi^2)/z(i)^2 + ...
    18*phi^2/(1-2*phi+phi^2)/z(i);