function data=E1d12()

global z;
global k;
global phi;

E=exp(1);
e=E;

data=((-c1F01) + 12.*c1F11.*phi.*sigma_d01(z(1)) +  ... 
    12.*c1F01.*phi.*sigma_d11(z(1)) -  ... 
    12.*c1F11.*e.^(-z(1)).*phi.*tau_d01(z(1)) -  ... 
    12.*c1F01.*e.^(-z(1)).*phi.*tau_d11(z(1))) ; 
