function data=E1d21()


global z;
global k;
global phi;

E=exp(1);
e=E;

data=((-c1F10) + 12.*c1F11.*phi.*sigma_d10(z(1)) +  ... 
    12.*c1F10.*phi.*sigma_d11(z(1)) -  ... 
    12.*c1F11.*e.^(-z(1)).*phi.*tau_d10(z(1)) -  ... 
    12.*c1F10.*e.^(-z(1)).*phi.*tau_d11(z(1))) ; 