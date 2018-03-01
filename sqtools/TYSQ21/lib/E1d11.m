function data=E1d11()

global z;
global k;
global phi;

E=exp(1);
e=E;

data=(((12.*c1F10.*phi.*sigma_d01(z(1)) +  ... 
      12.*c1F01.*phi.*sigma_d10(z(1)) -  ... 
      12.*c1F10.*e.^(-z(1)).*phi.*tau_d01(z(1)) -  ... 
      12.*c1F01.*e.^(-z(1)).*phi.*tau_d10(z(1))))) ; 