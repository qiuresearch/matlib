function data=E2d13()

global z;
global k;
global phi;

E=exp(1);
e=E;

data= ((12.*c12FD.*e.^z(2).*phi.*sigma_d01(z(2)) +  ... 
          12.*c2F12.*e.^z(2).*phi.*sigma_d01(z(2)) +  ... 
          12.*c2F01.*e.^z(2).*phi.*sigma_d12(z(2)) -  ... 
          12.*c2F12.*phi.*tau_d01(z(2)) -  ... 
          12.*c2F01.*phi.*tau_d12(z(2)))) ; 