function data=d_coe4_2(d2)


global z;
global k;
global phi;

e=exp(1);
E=e;

data=(((12.*aNumd2(d2).*phi.*cNumd2_2(d2))./(aDend1(d2).*cDend1_2(d2).*z(2).^3) - ...
          (12.*aNumd2(d2).*e.^(-z(2)).*phi.*cNumd2_2(d2))./(aDend1(d2).* ...
              cDend1_2(d2).*z(2).^3) +  ...
          (12.*bNumd2(d2).*phi.*cNumd2_2(d2))./(bDend1(d2).*cDend1_2(d2).*z(2).^2) -  ...
          (12.*aNumd2(d2).*e.^(-z(2)).*phi.*cNumd2_2(d2))./(aDend1(d2).* ...
              cDend1_2(d2).*z(2).^2) -  ...
          (12.*bNumd2(d2).*e.^(-z(2)).*phi.*cNumd2_2(d2))./(bDend1(d2).* ...
              cDend1_2(d2).*z(2).^2) -  ...
          (6.*aNumd2(d2).*phi.*cNumd2_2(d2))./(aDend1(d2).*cDend1_2(d2).*z(2)) -  ...
          (12.*bNumd2(d2).*phi.*cNumd2_2(d2))./(bDend1(d2).*cDend1_2(d2).*z(2)) -  ...
          (12.*E.^(-z(1)).*phi.*cNumd2_1(d2).*cNumd2_2(d2))./(cDend1_1(d2).* ...
              cDend1_2(d2).*z(2)) +  ...
          (6.*phi.*cNumd2_2(d2).^2)./(cDend1_2(d2).^2.*z(2)) +  ...
          (6.*e.^((-2).*z(2)).*phi.*cNumd2_2(d2).^2)./(cDend1_2(d2).^2.* ...
              z(2)) -  ...
          (12.*E.^(-z(2)).*phi.*cNumd2_2(d2).^2)./(cDend1_2(d2).^2.*z(2)) +  ...
          (12.*phi.*cNumd2_2(d2))./(cDend1_2(d2).*((z(1) + z(2)))) +  ...
          (12.*phi.*cNumd2_1(d2).*cNumd2_2(d2))./(cDend1_1(d2).*cDend1_2(d2).* ...
              ((z(1) + z(2)))) +  ...
          ((12.*e.^((-z(1)) - z(2)).*phi.*cNumd2_1(d2).*cNumd2_2(d2).*z(1)) ...
              )./((cDend1_1(d2).*cDend1_2(d2).*z(2).*((z(1) + z(2))))))); 