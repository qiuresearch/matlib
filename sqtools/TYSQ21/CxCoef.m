function data = CxCoef(d1,d2);

global z;
global k;
global phi;

bigK(1) = k(1)*exp(-z(1));
bigK(2) = k(2)*exp(-z(2));

a=myA(d1,d2);
b=myB(d1,d2);

c1 = myC1(d1,d2);
c2 = myC2(d1,d2);

a00=a^2;
b00=-12*phi*((a+b)^2/2+a*( c1*exp(-z(1))+c2*exp(-z(2)) ) );

v1=24*phi*bigK(1).*exp(z(1))*gHat(a,b,c1,d1,c2,d2,z(1));
v2=24*phi*bigK(2).*exp(z(2))*gHat(a,b,c1,d1,c2,d2,z(2));

data=[a00,b00,v1,v2,a,b,c1,d1,c2,d2];