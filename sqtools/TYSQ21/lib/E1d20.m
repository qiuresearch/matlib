function data=E1d20()


global z;
global k;
global phi;

E=exp(1);
e=E;

data=12*c1F10*phi*sigma_d10(z(1))-12*c1F10*exp(-z(1))*phi*tau_d10(z(1));