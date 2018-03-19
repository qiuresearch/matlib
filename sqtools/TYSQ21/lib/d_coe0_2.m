function data=d_coe0_2(d2)

global z;
global k;
global phi;

e=exp(1);
E=e;

aNumd0d2=aNumd0(d2);
cNumd0_2d2=cNumd0_2(d2);
cDend1_2d2=cDend1_2(d2);
aDend1d2=aDend1(d2);
bNumd0d2=bNumd0(d2);
bDend1d2=bDend1(d2);
cDend1_1d2=cDend1_1(d2);
cNumd0_1d2=cNumd0_1(d2);

data=(12.*aNumd0d2.*phi.*cNumd0_2d2)./(aDend1d2.*cDend1_2d2.*z(2).^3) - ...
        (12.*aNumd0d2.*e.^(-z(2)).*phi.*cNumd0_2d2)./(aDend1d2.*cDend1_2d2.* ...
            z(2).^3) +  ...
        (12.*bNumd0d2.*phi.*cNumd0_2d2)./(bDend1d2.*cDend1_2d2.*z(2).^2) -  ...
        (12.*aNumd0d2.*e.^(-z(2)).*phi.*cNumd0_2d2)./(aDend1d2.*cDend1_2d2.* ...
            z(2).^2) -  ...
        (12.*bNumd0d2.*e.^(-z(2)).*phi.*cNumd0_2d2)./(bDend1d2.*cDend1_2d2.* ...
            z(2).^2) -  ...
        (6.*aNumd0d2.*phi.*cNumd0_2d2)./(aDend1d2.*cDend1_2d2.*z(2)) -  ...
        (12.*bNumd0d2.*phi.*cNumd0_2d2)./(bDend1d2.*cDend1_2d2.*z(2)) -  ...
        (12.*E.^(-z(1)).*phi.*cNumd0_1d2.*cNumd0_2d2)./(cDend1_1d2.* ...
            cDend1_2d2.*z(2)) +  ...
        (6.*phi.*cNumd0_2d2.^2)./(cDend1_2d2.^2.*z(2)) +  ...
        (6.*e.^((-2).*z(2)).*phi.*cNumd0_2d2.^2)./(cDend1_2d2.^2.* ...
            z(2)) -  ...
        (12.*E.^(-z(2)).*phi.*cNumd0_2d2.^2)./(cDend1_2d2.^2.*z(2)) +  ...
        (12.*phi.*cNumd0_1d2.*cNumd0_2d2)./(cDend1_1d2.*cDend1_2d2.* ...
            ((z(1) + z(2)))) +  ...
        (12.*e.^((-z(1)) - z(2)).*phi.*cNumd0_1d2.*cNumd0_2d2.* ...
            z(1))./(cDend1_1d2.*cDend1_2d2.*z(2).*((z(1) + z(2)))) ;
            
            return
            