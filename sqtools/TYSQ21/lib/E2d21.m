function data=E2d21()

global z;
global k;
global phi;

E=exp(1);
e=E;

data=(((-c2F10).*e.^z(2) +  ... 
          12.*c2F11.*e.^z(2).*phi.*sigma_d10(z(2)) +  ... 
          12.*c2F10.*e.^z(2).*phi.*sigma_d11(z(2)) -  ... 
          12.*c2F11.*phi.*tau_d10(z(2)) -  ... 
          12.*c2F10.*phi.*tau_d11(z(2)))) ;
 