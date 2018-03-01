function HKLXI=difrdist(comp, mno, order)
%DIFRDIST  Vypise vzdialenosti na negative pre elektr. difrakciu v pole mno
%          DIFRDIST(COMPOUND, MNO, ORDER)
%	   COMPOUND nazov funkcie, ktora definuje zluceninu
%          MNO je os zony v priamej mriezke (default [0 0 0]).
%	   ORDER je maximalny difrakcny index

% 1997 by Pavol

tol = .1; %tolerancia sedenia v zone mno
if nargin==1
      mno=[0 0 0];
end
if nargin<3
      hkli=intdif(comp);
elseif nargin==3
      hkli=intdif(comp,order);
end
abcABG=feval(comp,'abc');
i=find(hkli(:,4)<5);
hkli(i,:)=[];
if strcmp(abcABG, [[1 1 1]*abcABG(1), 90, 90, 90])
	%get rid off repeating indexes...
	i=find(hkli(:,2)<hkli(:,3));
	hkli(i,:) = [];
	i=find(hkli(:,1)<hkli(:,2));
	hkli(i,:) = [];
end
mno=mno(:); mno=mno(1:3);
i=find(abs(hkli(:,1:3)*mno)>3*tol);     %vyhodenie bodov mimo zony
hkli(i,:)=[];
[hkli(:,4),i]=sort(hkli(:,4));
hkli(:,1:3)=hkli(i,1:3);
I=log(hkli(:,4))-((hkli(:,1:3)*mno).^2)./(2*tol^2) / log(2);
hkli(:,4)=I;

%Calculate fundamental lattice vectors
a=abcABG(1);b=abcABG(2);c=abcABG(3);
abcABG(4:6)=abcABG(4:6)*pi/180;
alpha=abcABG(4);beta=abcABG(5);gamma=abcABG(6);
a1=a * [1               0                                               0];
a2=b * [cos(gamma)      sin(gamma)                                      0];
a3=    [cos(beta)       (cos(alpha)-cos(beta)*cos(gamma))/sin(gamma)    0];
a3(3) = sqrt(1-a3*a3');
a3=c * a3;
%Now calculate base vectors of reciprocal lattice
ainv=inv([a1;a2;a3]);   %columns of ainv are base vectors

hkl=hkli(:,1:3);
g=ainv*(hkl');
x=lambdal * sqrt(sum(g.^2));
[x,i]=sort(x); x=x(:);
hkli=hkli(i,:);
hklxi=[hkli(:,1:3) x hkli(:,4)];
if nargout==1
	HKLXI=hklxi;
else
	fprintf('\n\th\tk\tl\tx(cm)\tlog(Int)\n');
	fprintf('\t----------------------------------------\n');
	fprintf('\t%.0f\t%.0f\t%.0f\t%.2f\t%f\n', hklxi');
end
