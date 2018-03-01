function [r,eCr]=Cr(a00,b00,v1,v2,r)

global z;
global k;
global phi;

bigK(1)=k(1)*exp(-z(1));
bigK(2)=k(2)*exp(-z(2));

rou = phi *6/pi;

%eCr=zeros(length(r),1);

index = find(r<1 | r==1);

eCr(index)=a00*r(index)+b00*r(index).^2 + 1/2 * phi * a00* r(index).^4 + v1/z(1) *(1-exp(-z(1)*r(index)))+v2/z(2)*(1-exp(-z(2)*r(index))) + ...
    v1^2/(2*k(1)*z(1)^2) *(cosh(z(1)*r(index))-1)+ v2^2/(2*k(2)*z(2)^2) * (cosh(z(2)*r(index))-1);;

eCr(index)=-eCr(index);

index = find(r>1);
eCr(index)= (k(1)*exp(-z(1)*r(index)) + k(2)*exp(-z(2)*r(index))) ;

eCr=eCr./r;