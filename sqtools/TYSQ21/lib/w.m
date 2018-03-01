function y=w(i)

global z;
global k;
global phi;

y=8/z(i)^2 + 8*(1 + 2*phi)*(-1 + 4*phi)/(1-2*phi+phi^2)/z(i)^2 - 12*phi*(1+2*phi)/(1-2*phi+phi^2)/z(i); 