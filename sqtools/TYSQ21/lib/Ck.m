function data=Ck(a00,b00,v1,v2,kk)

global z;
global k;
global phi;

bigK(1)=k(1)*exp(-z(1));
bigK(2)=k(2)*exp(-z(2));

rou = phi *6/pi;

Originkk=kk;
data=zeros(size(Originkk));

index=find(Originkk>0.0001-1e-8);

kk=Originkk(index);
data(index)=-24*phi*( a00*(-kk.*cos(kk)+sin(kk))./kk.^3 + b00./kk.^4 .*( -kk.^2 .* cos(kk) + 2*kk.*sin(kk) ...
    +2*(cos(kk)-1)) +1/2 *phi*a00./kk.^6 .*( -kk.^4.*cos(kk) + 4*kk.^3.*sin(kk) + 12.*kk.^2.*cos(kk) ...
    -24*kk.*sin(kk)-24.*(cos(kk)-1)) + multiTerm(v1,z(1),bigK(1),kk) + multiTerm(v2,z(2),bigK(2),kk));

data = data /rou;

index = find(Originkk<0.0001);
if ~isempty(index)
    data(index)=ones(size(data(index)))*(1-a00)/rou;
end
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = multiTerm(v,z,bigK,kk)

data=v./z *( 1./kk.^2 .* (1-cos(kk)) - 1./(z^2 + kk.^2) ...
    .*(1-exp(-z).*(z./kk .* sin(kk) + cos(kk)))) + v^2 ./ (4*bigK*z^2*exp(z)) .*( 1./(z^2 + kk.^2) ...
    .*(2-exp(z).*(-z./kk .* sin(kk) + cos(kk)) - exp(-z).*(z./kk .* sin(kk) + cos(kk))) ...
    -2./kk.^2 .*(1-cos(kk))) - bigK./(z^2+kk.^2).*(z./kk .* sin(kk) + cos(kk));

