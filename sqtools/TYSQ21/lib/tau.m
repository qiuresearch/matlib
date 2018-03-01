function data=tau(a,b,c1,d1,c2,d2,s)

global z;
global k;
global phi;

data=a.*(1./s.^3 + 1./s.^2) + b./s.^2 -( z(1).*c1.*exp(-z(1))./(z(1)+s) + z(2).*c2.*exp(-z(2))./(z(2)+s) ) ./ s;