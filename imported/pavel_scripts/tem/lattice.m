function [X,Y,Z]=LATTICE(mno, compound, element)
%LATTICE   vrati mriezku elementarnych buniek v kartezskych suradniciach
%          [x,y,z]=LATTICE([m n o], compound, element)
%          [m n o]  - rozmer mriezky
%          compound - specifikuje monokrystal
%          element  - prvok monokrystalu
%          [x,y,z]=LATTICE([m n o], compound, 'grid') vrati obrys mriezky

% Pavol 1997

if nargin<2
        error('Not enough input arguments');
elseif nargin==2
        if strcmp(compound, 'grid')
                error('Undefined compound');
        end
        element=feval(compound, 'elements');
        element=element(1,:);
end

%Calculate fundamental lattice vectors
a=feval(compound, 'abc'); a(4:6)=a(4:6)*pi/180;
alpha=a(4);beta=a(5);gamma=a(6);
b=a(2);c=a(3);a=a(1);
a1=a * [1               0                                               0];
a2=b * [cos(gamma)      sin(gamma)                                      0];
a3=    [cos(beta)       (cos(alpha)-cos(beta)*cos(gamma))/sin(gamma)    0];
a3(3) = sqrt(1-a3*a3');
a3=c * a3;

%Now here we start...
mno=round(mno);
m=mno(1); n=mno(2); o=mno(3);
if strcmp(lower(element), 'grid')
        %y-grid
        u=zeros(3*n+3,1); v=u;
        u(2:3:3*n+3) = m*ones(n+1,1);
        u(3:3:3*n+3) = NaN+zeros(n+1,1);
        v(1:3:3*n+3) = 0:n;
        v(2:3:3*n+3) = 0:n;
        v(3:3:3*n+3) = NaN+zeros(n+1,1);
        %x-grid
        U=zeros(3*m+3,1); V=U;
        U(1:3:3*m+3) = 0:m;
        U(2:3:3*m+3) = 0:m;
        U(3:3:3*m+3) = NaN+ones(m+1,1);
        V(2:3:3*m+3) = n*ones(m+1,1);
        V(3:3:3*m+3) = NaN+ones(m+1,1);
        u=[u;U]; v=[v;V];
        len = length(u);
        u(1:(o+1)*len) = u(:,ones(o+1,1));
        v(1:(o+1)*len) = v(:,ones(o+1,1));
        w=(0:o);
        w(1:(o+1)*len) = w(ones(1,len),:);
        [U,V]=meshgrid(0:m,0:n);
        U=U(:); V=V(:);
        len = (n+1)*(m+1);
        U(2:3:3*len)=U(:);
        U(3:3:3*len)=U(2:3:3*len);
        V(2:3:3*len)=V(:);
        V(3:3:3*len)=V(2:3:3*len);
        W=zeros(3*len, 1);
        W(1:3:3*len)=NaN+zeros(len,1);
        W(3:3:3*len)=o*ones(len,1);
        if o~=0
                u=[u;U]; v=[v;V]; w=[w(:);W];
        else    
                w=0*u;
        end
else
        [u0,v0,w0]=feval(compound, element);
        [U,V,W]=meshgrid(0:m, 0:n, 0:o);
        U=U(:); V=V(:); W=W(:);
	u=[]; v=[]; w=[];
        for q=1:length(u0)
                u=[u; u0(q)+U];
                v=[v; v0(q)+V];
                w=[w; w0(q)+W];
        end
        i = find(abs(u)>abs(m) | abs(v)>abs(n) );
        if o~=0
                i=[i;find(abs(w)>abs(o))];
        end
        u(i)=[]; v(i)=[]; w(i)=[];
end
%Now transfer to Cartesian co-ordinates
xyz = [u v w] * [a1 ; a2 ; a3];
X=xyz(:,1); Y=xyz(:,2); Z=xyz(:,3);

