function data=E2d31()

global z;
global k;
global phi;

E=exp(1);
e=E;

data=((12.*c2F21.*e.^z(2).*phi.*sigma_d10(z(2)) +  ... 
          12.*c2F10.*e.^z(2).*phi.*sigma_d21(z(2)) -  ... 
          12.*c2F21.*phi.*tau_d10(z(2)) -  ... 
          12.*c2F10.*phi.*tau_d21(z(2)))) ; 

     