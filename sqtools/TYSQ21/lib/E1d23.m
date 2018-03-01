function data= E1d23()

global z;
global k;
global phi;

E=exp(1);
e=E;

data=((((-c1F12) + 12.*c1F12.*phi.*sigma_d11(z(1)) +  ... 
      12.*c1F11.*phi.*sigma_d12(z(1)) -  ... 
      12.*c1F12.*e.^(-z(1)).*phi.*tau_d11(z(1)) -  ... 
      12.*c1F11.*e.^(-z(1)).*phi.*tau_d12(z(1))))) ; 