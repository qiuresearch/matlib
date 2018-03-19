function data=tau_d10(s)

global z;
global k;
global phi;

E=exp(1);
e=E;

data=(aFNumd10./(abFDend11.*s.^3) + aFNumd10./(abFDend11.*s.^2) + ...
    bFNumd10./(abFDend11.*s.^2) -  ...
    (E.^(-z(1)).*Ccd1_21.*k(2).*z(1))./(s.* ...
        ((Ccd1_21.*Ccd2_12 - Ccd1_11.*Ccd2_22)).* ...
        ((s + z(1)))) +  ...
    (E.^(-z(2)).*Ccd1_11.*k(2).*z(2))./(s.* ...
        ((Ccd1_21.*Ccd2_12 - Ccd1_11.*Ccd2_22)).* ...
        ((s + z(2)))));