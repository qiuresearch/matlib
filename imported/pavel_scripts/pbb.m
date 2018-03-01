function p=pbb(x, s, pind)
% PBB(X,S) returns probability matrix for cation pairs
%   at composition X, order parameter S in a nx6 matrix
% PBB(X,S,PIND)
%   calculates PINDth probability, where PIND must be from 1:6
%   and X, S must have equal dimensions
%

if nargin < 3
    pind = 0;
else
    pind=pind(1);
    if ~isequal( size(x), size(s) )
	error( 'X and S must have the same size');
    end
    Pmat = zeros( size(x) );
end
if length(x)==1
    x=x+0*s;
elseif length(s)==1
    s=s+0*x;
end
x=x(:); s=s(:);
s1=0*x; w1=0*x; m1=0*x;
s2=0*x; w2=0*x; m2=0*x;
%x<=.25
il=(x <= 0.25);
%x>.25
ih=~il;
s1(il)=(2*x(il)+1)/3.*s(il) + 2/3*(1-x(il));
s2(il)=-(2*x(il)+1)/3.*s(il) + 2/3*(1-x(il));
s1(ih)=2/3*(1-x(ih)) .* (1+s(ih));
s2(ih)=2/3*(1-x(ih)) .* (1-s(ih));
w1=(1-x)/3.*(1-s);
w2=(1-x)/3.*(1+s);
m1(il)=x(il).*(1-s(il));
m2(il)=x(il).*(1+s(il));
m1(ih)=x(ih) - (1-x(ih))/3.*s(ih);
m2(ih)=x(ih) + (1-x(ih))/3.*s(ih);

p=zeros(length(x+s),6);
p(:,1)=s1.*s2;
p(:,2)=s1.*w2 + s2.*w1;
p(:,3)=s1.*m2 + s2.*m1;
p(:,4)=w1.*w2;
p(:,5)=w1.*m2 + w2.*m1;
p(:,6)=m1.*m2;

if pind
    Pmat(:) = p(:,pind);
    p = Pmat;
end
