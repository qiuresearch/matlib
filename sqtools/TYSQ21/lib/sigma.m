function data=sigma(a,b,c1,d1,c2,d2,s)

global z;
global k;
global phi;

data=a./s.^3 + b./s.^2 -(a/2 + b + c1.*exp(-z(1)) + c2.*exp(-z(2)) )./s + (c1+d1)./(z(1)+s)+(c2+d2)./(z(2)+s);