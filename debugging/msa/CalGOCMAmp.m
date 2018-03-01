function data=CalGOCMAmp(Zp,T,epsilon,k,volF,sigmaH)
%data=CalGOCMAmp(Zp,T,epsilon,k,volF,sigmaH)
%
%The potential form is : A exp(-k*sigmaH(r/sigmaH-1)) / (r/sigmaH).
%sigmaH: hardcore diameter
%volF: volume fraction
%T: temperature
%Zp: charge number 
%epsilon: dielectric constant
%
%data=A

k_B = 1.3807e-23;
e=1.6e-19;

beta=1/(k_B*T);

t02=24*beta*Zp^2*e^2*volF/epsilon/sigmaH/(4*pi);

data =  beta*Zp^2 * e^2 /(4*pi*epsilon * sigmaH);
data=data * (cosh(k/2) + U(k,volF,t02) .* (k/2 .* cosh(k/2) - sinh(k/2))).^2;

x= (cosh(k/2) + U(k,volF,t02) .* (k/2 .* cosh(k/2) - sinh(k/2))).^2;

data=data*exp(-k);

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = U(k,volF,t02)
data = mu(volF) *(k/2)^(-3)-gamma(k,volF,t02) / (k/2);
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = mu(volF)
data = 3*volF/(1 - volF);
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data=gamma(k,volF,t02)

if 1
    poly4=1/4;
    poly3=1+mu(volF);
    poly2=1-k.^2/4 + 2*mu(volF) + mu(volF)^2;
    poly1=-k^2-k^2*mu(volF);
    poly0=-k^2-t02-2*k^2*mu(volF)-k^2*mu(volF)^2;

    x=roots([poly4,poly3,poly2,poly1,poly0]);

else
    fprintf('Ooh!, used wrong equation');
    return
%    poly3=1/2;
%    poly2=1+mu(volF);
%    poly1=-k^2/2;
%    poly0=-k^2*(1+mu(volF))-t02;
    
%    x=roots([poly3,poly2,poly1,poly0]);
end

j=1;
for i=1:length(x)
    if imag(x(i)) ~= 0
        continue;
    end
    if x(i) < 0
        continue;
    end
    rootSet(j)=x(i);
    j=j+1;
end

G=min(rootSet);
data=(G/2 + mu(volF))/(1+G/2+mu(volF));