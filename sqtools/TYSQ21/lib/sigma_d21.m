function data=sigma_d21(s)


global z;
global k;
global phi;

E=exp(1);
e=E;

data=(aFNumd21./(abFDend11.*s.^3) + bFNumd21./(abFDend11.*s.^2) -  ... 
    aFNumd21./(2.*abFDend11.*s) -  ... 
    bFNumd21./(abFDend11.*s) + (E.^(-z(2)).*Ccd2_12.* ... 
Cdd1_11)./(s.*((Ccd1_21.*Ccd2_12 - Ccd1_11.*Ccd2_22))) -  ... 
(E.^(-z(1)).*Ccd2_22.*Cdd1_11)./(s.*((Ccd1_21.* ... 
Ccd2_12 - Ccd1_11.*Ccd2_22))) - (E.^(-z(2)).* ... 
Ccd1_11.*Cdd2_12)./(s.*((Ccd1_21.*Ccd2_12 - Ccd1_11.* ... 
Ccd2_22))) + (E.^(-z(1)).*Ccd1_21.*Cdd2_12)./(s ... 
.*((Ccd1_21.*Ccd2_12 - Ccd1_11.*Ccd2_22))) + (Ccd1_21.* ... 
Ccd2_12)./(((Ccd1_21.*Ccd2_12 - Ccd1_11.*Ccd2_22)).*((s +  ... 
z(1)))) - (Ccd1_11.*Ccd2_22)./(((Ccd1_21.*Ccd2_12 - Ccd1_11.*Ccd2_22)).*((s + z(1)))) + (Ccd2_22.*Cdd1_11)./(((Ccd1_21.*Ccd2_12 - Ccd1_11.*Ccd2_22)).*((s + z(1))) ... 
) - (Ccd1_21.*Cdd2_12)./(((Ccd1_21.*Ccd2_12 - Ccd1_11.* ... 
Ccd2_22)).*((s + z(1)))) - (Ccd2_12.*Cdd1_11)./(((Ccd1_21 ... 
.*Ccd2_12 - Ccd1_11.*Ccd2_22)).*((s + z(2)))) + (Ccd1_11.* ... 
Cdd2_12)./(((Ccd1_21.*Ccd2_12 - Ccd1_11.*Ccd2_22)).*((s +  ... 
z(2))))) ;