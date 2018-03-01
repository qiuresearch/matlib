function data = SQ_0 (z1,z2,a,b,c1,c2,d1,d2)

data=a/3+b/2+c1*exp(-z1)+c2*exp(-z2)-c1/z1-d1/z1+c1*exp(-z1)/z1-c2/z2-d2/z2+c2*exp(-z2)/z2;

data=data.^2;

end