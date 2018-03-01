function data=myB(d1,d2)

global z;
global k;
global phi;

data=(bNumd01*d2 + bFNumd21*d1^2*d2 + bFNumd10*d1 + bFNumd11*d1*d2 + ...
      bFNumd12*d1*d2^2)/(abFDend11 *d1*d2);

%bNum = bNumd0(d2) + bNumd1(d2).*d1 + bNumd2(d2) .* d1.^2;
%bDen = bDend1(d2) .* d1;

%data = bNum./bDen;