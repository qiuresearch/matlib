function data=E1d24()

global z;
global k;
global phi;

E=exp(1);
e=E;

data=12*c1F12*phi*sigma_d12(z(1)) - 12*c1F12*exp(-z(1))*phi*tau_d12(z(1));