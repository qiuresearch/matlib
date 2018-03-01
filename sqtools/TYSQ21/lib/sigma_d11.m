function data=sigma_d11(s)

global z;
global k;
global phi;

E=exp(1);
e=E;

data=(aFNumd11./(abFDend11.*s.^3) + bFNumd11./(abFDend11.*s.^2) -  ... 
    aFNumd11./(2.*abFDend11.*s) -  ... 
    bFNumd11./(abFDend11.*s) + (E.^(-z(2)).*Ccd2_12.* ... 
Cd1_1)./(s.*((Ccd1_21.*Ccd2_12 - Ccd1_11.*Ccd2_22))) - ( ... 
E.^(-z(1)).*Ccd2_22.*Cd1_1)./(s.*((Ccd1_21.*Ccd2_12 - Ccd1_11.*Ccd2_22))) - (E.^(-z(2)).*Ccd1_11.* ... 
Cd2_2)./(s.*((Ccd1_21.*Ccd2_12 - Ccd1_11.*Ccd2_22))) + ( ... 
E.^(-z(1)).*Ccd1_21.*Cd2_2)./(s.*((Ccd1_21.*Ccd2_12 - Ccd1_11.*Ccd2_22))) + (Ccd2_22.*Cd1_1)./(((Ccd1_21.* ... 
Ccd2_12 - Ccd1_11.*Ccd2_22)).*((s + z(1)))) - (Ccd1_21.* ... 
Cd2_2)./(((Ccd1_21.*Ccd2_12 - Ccd1_11.*Ccd2_22)).*((s +  ... 
z(1)))) - (Ccd2_12.*Cd1_1)./(((Ccd1_21.*Ccd2_12 - Ccd1_11.* ... 
Ccd2_22)).*((s + z(2)))) + (Ccd1_11.*Cd2_2)./(((Ccd1_21.* ... 
Ccd2_12 - Ccd1_11.*Ccd2_22)).*((s + z(2))))) ; 
