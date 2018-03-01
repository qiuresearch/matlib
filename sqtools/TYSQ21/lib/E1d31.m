function data=E1d31()


global z;
global k;
global phi;

E=exp(1);
e=E;

data=(((12.*c12FD.*phi.*sigma_d10(z(1)) + ...
      12.*c1F21.*phi.*sigma_d10(z(1)) +  ...
      12.*c1F10.*phi.*sigma_d21(z(1)) -  ...
      12.*c1F21.*e^(-z(1)).*phi.*tau_d10(z(1)) -  ...
      12.*c1F10.*e^(-z(1)).*phi.*tau_d21(z(1)))));