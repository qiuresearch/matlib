function data=d_coe3_2(d2)

global z;
global k;
global phi;

e=exp(1);
E=e;

data=(((-(cNumd2_2(d2)./cDend1_2(d2))) +  ...
          (12.*aNumd2(d2).*phi.*cNumd1_2(d2))./(aDend1(d2).*cDend1_2(d2).*z(2).^3) -  ...
          (12.*aNumd2(d2).*e.^(-z(2)).*phi.*cNumd1_2(d2))./(aDend1(d2).* ...
              cDend1_2(d2).*z(2).^3) +  ...
          (12.*aNumd1(d2).*phi.*cNumd2_2(d2))./(aDend1(d2).*cDend1_2(d2).*z(2).^3) -  ...
          (12.*aNumd1(d2).*e.^(-z(2)).*phi.*cNumd2_2(d2))./(aDend1(d2).* ...
              cDend1_2(d2).*z(2).^3) +  ...
          (12.*aNumd2(d2).*phi.*d2)./(aDend1(d2).*z(2).^3) +  ...
          (12.*bNumd2(d2).*phi.*cNumd1_2(d2))./(bDend1(d2).*cDend1_2(d2).*z(2).^2) -  ...
          (12.*aNumd2(d2).*e.^(-z(2)).*phi.*cNumd1_2(d2))./(aDend1(d2).* ...
              cDend1_2(d2).*z(2).^2) -  ...
          (12.*bNumd2(d2).*e.^(-z(2)).*phi.*cNumd1_2(d2))./(bDend1(d2).* ...
              cDend1_2(d2).*z(2).^2) +  ...
          (12.*bNumd1(d2).*phi.*cNumd2_2(d2))./(bDend1(d2).*cDend1_2(d2).*z(2).^2) -  ...
          (12.*aNumd1(d2).*e.^(-z(2)).*phi.*cNumd2_2(d2))./(aDend1(d2).* ...
              cDend1_2(d2).*z(2).^2) -  ...
          (12.*bNumd1(d2).*e.^(-z(2)).*phi.*cNumd2_2(d2))./(bDend1(d2).* ...
              cDend1_2(d2).*z(2).^2) +  ...
          (12.*bNumd2(d2).*phi.*d2)./(bDend1(d2).*z(2).^2) -  ...
          (6.*aNumd2(d2).*phi.*cNumd1_2(d2))./(aDend1(d2).*cDend1_2(d2).*z(2)) -  ...
          (12.*bNumd2(d2).*phi.*cNumd1_2(d2))./(bDend1(d2).*cDend1_2(d2).*z(2)) -  ...
          (12.*E.^(-z(1)).*phi.*cNumd1_2(d2).*cNumd2_1(d2))./(cDend1_1(d2).* ...
              cDend1_2(d2).*z(2)) -  ...
          (6.*aNumd1(d2).*phi.*cNumd2_2(d2))./(aDend1(d2).*cDend1_2(d2).*z(2)) -  ...
          (12.*bNumd1(d2).*phi.*cNumd2_2(d2))./(bDend1(d2).*cDend1_2(d2).*z(2)) -  ...
          (12.*E.^(-z(1)).*phi.*cNumd1_1(d2).*cNumd2_2(d2))./(cDend1_1(d2).* ...
              cDend1_2(d2).*z(2)) +  ...
          (12.*phi.*cNumd1_2(d2).*cNumd2_2(d2))./(cDend1_2(d2).^2.*z(2)) +  ...
          (12.*e.^((-2).*z(2)).*phi.*cNumd1_2(d2).* ...
              cNumd2_2(d2))./(cDend1_2(d2).^2.*z(2)) -  ...
          (24.*E.^(-z(2)).*phi.*cNumd1_2(d2).*cNumd2_2(d2))./(cDend1_2(d2).^2.* ...
              z(2)) - (6.*aNumd2(d2).*phi.*d2)./(aDend1(d2).*z(2)) -  ...
          (12.*bNumd2(d2).*phi.*d2)./(bDend1(d2).*z(2)) -  ...
          (12.*E.^(-z(1)).*phi.*cNumd2_1(d2).*d2)./(cDend1_1(d2).*z(2)) +  ...
          (12.*phi.*cNumd2_2(d2).*d2)./(cDend1_2(d2).*z(2)) -  ...
          (12.*E.^(-z(2)).*phi.*cNumd2_2(d2).*d2)./(cDend1_2(d2).*z(2)) +  ...
          (12.*phi.*cNumd1_2(d2))./(cDend1_2(d2).*((z(1) + z(2)))) +  ...
          (12.*phi.*cNumd1_2(d2).*cNumd2_1(d2))./(cDend1_1(d2).*cDend1_2(d2).* ...
              ((z(1) + z(2)))) +  ...
          (12.*phi.*cNumd1_1(d2).*cNumd2_2(d2))./(cDend1_1(d2).*cDend1_2(d2).* ...
              ((z(1) + z(2)))) + (12.*phi.*d2)./(z(1) + z(2)) +  ...
          (12.*phi.*cNumd2_1(d2).*d2)./(cDend1_1(d2).*((z(1) + z(2)))) +  ...
          ((12.*e.^((-z(1)) - z(2)).*phi.*cNumd1_2(d2).*cNumd2_1(d2).*z(1)) ...
              )./((cDend1_1(d2).*cDend1_2(d2).*z(2).*((z(1) + z(2))))) +  ...
          ((12.*e.^((-z(1)) - z(2)).*phi.*cNumd1_1(d2).*cNumd2_2(d2).*z(1)) ...
              )./((cDend1_1(d2).*cDend1_2(d2).*z(2).*((z(1) + z(2))))))) ;