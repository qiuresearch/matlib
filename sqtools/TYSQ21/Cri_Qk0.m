function data=Cri_Qk0(cri_x,K1,K2,Z1,Z2,volF)
%data=Cri_Qk0(cri_x,K1,K2,Z1,Z2,volF)

K1 = cri_x

Q=(0.000001:0.005:16*10)*2*pi;
choice =1;

[calSk,rootCounter,calr,calGr,errorCode,coe]=CalTYSk(Z1,Z2,K1,K2,volF,Q,choice);

a00=coe(1);
b00=coe(2);
v1=coe(3);
v2=coe(4);
a=coe(5);
b=coe(6);
c1=coe(7);
d1=coe(8);
c2=coe(9);
d2=coe(10);

if calSk(2) == 0 | sum(coe.^2) == 0
    data = 100 
    return
end;

data=a00
%data=a/3 + b/2 + c1*exp(-Z1) + c2*exp(-Z2) - c1/Z1 - d1/Z1 + c1 * exp(-Z1) / Z1 -c2/Z2 - d2/Z2 + c2*exp(-Z2)/Z2;

