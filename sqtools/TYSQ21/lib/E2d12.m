function data=E2d12()

global z;
global k;
global phi;

E=exp(1);
e=E;

data= (-c2F01).*e.^z(2) +  ... 
        12.*c2F11.*e.^z(2).*phi.*sigma_d01(z(2)) +  ... 
        12.*c2F01.*e.^z(2).*phi.*sigma_d11(z(2)) -  ... 
        12.*c2F11.*phi.*tau_d01(z(2)) -  ... 
        12.*c2F01.*phi.*tau_d11(z(2)) ; 
