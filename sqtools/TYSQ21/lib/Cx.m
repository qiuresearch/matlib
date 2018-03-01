function data=Cx(a0,b0,v1,v2,x)

global z;
global k;
global phi;

data = a0 + b0 * x +phi*a0*x.^3 /2 + v1*(1-exp(-z(1)*x))./(z(1)*x) + v2*(1-exp(-z(2)*x))./(z(2)*x) + ...
    v1^2 *(cosh(z(1)*x)-1)./(2*k(1)*exp(z(1))*z(1)^2.*x) + v2^2*(cosh(z(2)*x)-1)./(2*k(2)*exp(z(2))*z(2)^2.*x);
data=-data;
