function data = CheckList(a,b,c1,c2,d1,d2)

global z;
global k;
global phi;

ch1=12*phi*(-a/8-b/6+c1*(1/z(1)^2 -((1+z(1))/z(1)^2+0.5)*exp(-z(1)))+d1/z(1)^2+c2*(1/z(2)^2 -((1+z(2))/z(2)^2+0.5)*exp(-z(2)))+d2/z(2)^2)-b;
ch2=12*phi*(-a/3-b/2+c1*(1/z(1)-(1+z(1))/z(1) * exp(-z(1))) +d1/z(1) + c2*(1/z(2)-(1+z(2))/z(2) * exp(-z(2))) +d2/z(2))-1+a;

ch3=z(1)*d1*(1-12*phi*q(a,b,c1,d1,c2,d2,z(1)))-k(1);
ch4=z(2)*d2*(1-12*phi*q(a,b,c1,d1,c2,d2,z(2)))-k(2);

ch5=12*phi*(sigma(a,b,c1,d1,c2,d2,z(1))*(c1+d1)-tau(a,b,c1,d1,c2,d2,z(1))*c1*exp(-z(1)))-c1-d1;
ch6=12*phi*(sigma(a,b,c1,d1,c2,d2,z(2))*(c2+d2)-tau(a,b,c1,d1,c2,d2,z(2))*c2*exp(-z(2)))-c2-d2;

data=[ch1,ch2,ch3,ch4,ch5,ch6];