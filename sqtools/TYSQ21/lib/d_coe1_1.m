function data=d_coe1_1(d2)

global z;
global k;
global phi;

%data = (1./cDend1_1(d2).^2).*(12*phi*cNumd0_1(d2).*cNumd1_1(d2).*(1-2*exp(-z(1))+exp(-2*z(1))*z(1))/z(1)...
%    +cDend1_1(d2).*(cNumd0_1(d2).*(-1+12*bNumd1(d2)*phi.*(1-exp(-z(1))-z(1))./(bDend1(d2)*z(1)^2)...
%    +6*aNumd1(d2).*phi.*(2-z(1)^2-2*exp(-z(1))*(1+z(1)))./(aDend1(d2)*z(1)^3)+(1./(cDend1_2(d2)*z(1)*(z(1)+z(2))))...
%    .*(12*phi.*(cNumd1_2(d2)*z(1)-exp(-z(2))*cNumd1_2(d2)*z(1)+cDend1_2(d2).*d2.*z(1)...
%    -exp(-z(2))*cNumd1_2(d2)*z(2)+exp(-z(1)-z(2))*cNumd1_2(d2)*z(1)*z(2))))...
%    +(1/z(1)^3)*(6*phi*cNumd1_1(d2).*(aNumd0(d2).*(2-z(1)^2-2*exp(-z(1))*(1+z(1)))./aDend1(d2)...
%    +(2*z(1).*(-bNumd0(d2)*exp(-z(1)).*cDend1_2(d2).*(1+exp(z(1))*(-1+z(1)))*(z(1)+z(2))...
%    +bDend1(d2).*cNumd0_2(d2).*z(1).*(z(1)-exp(-z(2))*z(1)-exp(-z(2))*z(2)+exp(-z(1)-z(2))*z(1)*z(2))))./(bDend1(d2).*cDend1_2(d2)*(z(1)+z(2)))))));

    
e=exp(1);
E=e;

data=(((-(cNumd0_1(d2)./cDend1_1(d2))) + ...
          (12.*aNumd1(d2).*phi.*cNumd0_1(d2))./(aDend1(d2).*cDend1_1(d2).*z(1).^3) -  ...
          (12.*aNumd1(d2).*e.^(-z(1)).*phi.*cNumd0_1(d2))./(aDend1(d2).* ...
              cDend1_1(d2).*z(1).^3) +  ...
          (12.*aNumd0(d2).*phi.*cNumd1_1(d2))./(aDend1(d2).*cDend1_1(d2).*z(1).^3) -  ...
          (12.*aNumd0(d2).*e.^(-z(1)).*phi.*cNumd1_1(d2))./(aDend1(d2).* ...
              cDend1_1(d2).*z(1).^3) +  ...
          (12.*bNumd1(d2).*phi.*cNumd0_1(d2))./(bDend1(d2).*cDend1_1(d2).*z(1).^2) -  ...
          (12.*aNumd1(d2).*e.^(-z(1)).*phi.*cNumd0_1(d2))./(aDend1(d2).* ...
              cDend1_1(d2).*z(1).^2) -  ...
          (12.*bNumd1(d2).*e.^(-z(1)).*phi.*cNumd0_1(d2))./(bDend1(d2).* ...
              cDend1_1(d2).*z(1).^2) +  ...
          (12.*bNumd0(d2).*phi.*cNumd1_1(d2))./(bDend1(d2).*cDend1_1(d2).*z(1).^2) -  ...
          (12.*aNumd0(d2).*e.^(-z(1)).*phi.*cNumd1_1(d2))./(aDend1(d2).* ...
              cDend1_1(d2).*z(1).^2) -  ...
          (12.*bNumd0(d2).*e.^(-z(1)).*phi.*cNumd1_1(d2))./(bDend1(d2).* ...
              cDend1_1(d2).*z(1).^2) -  ...
          (6.*aNumd1(d2).*phi.*cNumd0_1(d2))./(aDend1(d2).*cDend1_1(d2).*z(1)) -  ...
          (12.*bNumd1(d2).*phi.*cNumd0_1(d2))./(bDend1(d2).*cDend1_1(d2).*z(1)) -  ...
          (6.*aNumd0(d2).*phi.*cNumd1_1(d2))./(aDend1(d2).*cDend1_1(d2).*z(1)) -  ...
          (12.*bNumd0(d2).*phi.*cNumd1_1(d2))./(bDend1(d2).*cDend1_1(d2).*z(1)) +  ...
          (12.*phi.*cNumd0_1(d2).*cNumd1_1(d2))./(cDend1_1(d2).^2.*z(1)) +  ...
          (12.*e.^((-2).*z(1)).*phi.*cNumd0_1(d2).* ...
              cNumd1_1(d2))./(cDend1_1(d2).^2.*z(1)) -  ...
          (24.*E.^(-z(1)).*phi.*cNumd0_1(d2).*cNumd1_1(d2))./(cDend1_1(d2).^2.* ...
              z(1)) -  ...
          (12.*E.^(-z(2)).*phi.*cNumd0_2(d2).*cNumd1_1(d2))./(cDend1_1(d2).* ...
              cDend1_2(d2).*z(1)) -  ...
          (12.*E.^(-z(2)).*phi.*cNumd0_1(d2).*cNumd1_2(d2))./(cDend1_1(d2).* ...
              cDend1_2(d2).*z(1)) +  ...
          (12.*phi.*cNumd0_2(d2).*cNumd1_1(d2))./(cDend1_1(d2).*cDend1_2(d2).* ...
              ((z(1) + z(2)))) +  ...
          (12.*phi.*cNumd0_1(d2).*cNumd1_2(d2))./(cDend1_1(d2).*cDend1_2(d2).* ...
              ((z(1) + z(2)))) +  ...
          (12.*phi.*cNumd0_1(d2).*d2)./(cDend1_1(d2).*((z(1) + z(2)))) +  ...
          ((12.*e.^((-z(1)) - z(2)).*phi.*cNumd0_2(d2).*cNumd1_1(d2).*z(2)) ...
              )./((cDend1_1(d2).*cDend1_2(d2).*z(1).*((z(1) + z(2))))) +  ...
          ((12.*e.^((-z(1)) - z(2)).*phi.*cNumd0_1(d2).*cNumd1_2(d2).*z(2)) ...
              )./((cDend1_1(d2).*cDend1_2(d2).*z(1).*((z(1) + z(2)))))));