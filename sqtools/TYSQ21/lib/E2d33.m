function data=E2d33()

global z;
global k;
global phi;

E=exp(1);
e=E;

data= ((12.*c2F21.*e.^z(2).*phi.*sigma_d12(z(2)) +  ... 
          12.*c12FD.*e.^z(2).*phi.*sigma_d21(z(2)) +  ... 
          12.*c2F12.*e.^z(2).*phi.*sigma_d21(z(2)) -  ... 
          12.*c2F21.*phi.*tau_d12(z(2)) -  ... 
          12.*c2F12.*phi.*tau_d21(z(2)))) ; 
