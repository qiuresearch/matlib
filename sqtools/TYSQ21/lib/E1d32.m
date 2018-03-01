function data=E1d32()


global z;
global k;
global phi;

E=exp(1);
e=E;

data=((-c12FD) - c1F21 + 12.*c12FD.*phi.*sigma_d11(z(1)) + ...
    12.*c1F21.*phi.*sigma_d11(z(1)) +  ...
    12.*c1F11.*phi.*sigma_d21(z(1)) -  ...
    12.*c1F21.*e^(-z(1)).*phi.*tau_d11(z(1)) -  ...
    12.*c1F11.*e^(-z(1)).*phi.*tau_d21(z(1)));