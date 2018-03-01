function data = myA (d1,d2)

global z;
global k;
global phi;

data=(aFNumd01*d2 + aFNumd21*d1^2*d2 + aFNumd10*d1 + aFNumd11*d1*d2 + ...
      aFNumd12*d1*d2^2)/(abFDend11*d1*d2);
      
%aNum = aNumd0(d2) + aNumd1(d2) .*d1 + aNumd2(d2) .*d1.^2
%aDen = aDend1(d2).*d1;  Correction needed for old a

%data = aNum./aDen;