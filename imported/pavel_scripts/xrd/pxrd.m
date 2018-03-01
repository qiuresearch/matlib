function [I, th2]=pxrd(compound,hkl)
%PXRD      calculates intensity of powder xrd reflection
%	   [I, TH2]=XRD(COMPOUND,HKL) returns a column vector of intensities
%	   and corresponding Bragg angles TH2 for diffraction indexes HKL 
%	   in 3-column matrix. HKL multiplicity and LP factor are included.
%	   COMPOUND is a function describing crystal unit cell

% 1999 Pavol

%constants:
Kerr=1e-5;	%relative error in K
lam=phconst('cuka1');

if length(hkl)==1
   if hkl<=999 & hkl>0
	l=rem(hkl, 10);
	k=rem(hkl-l, 100)/10;
	h=(hkl-l-10*k)/100;
	hkl=[h k l];
   else
	error('Cannot understand hkl argument');
   end
end
if size(hkl,2)~=3
    error('HKL must be Nx3 matrix')
end
if exist(compound)==0
    error('Specified compound not found');
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

%base vectors of reciprocal lattice
ainv=inv([a1;a2;a3]);   %columns of ainv are base reciprocal vectors

%loop for more than 1 hkl's...
if size(hkl,1)>1
    I=zeros(size(hkl,1),1);
    th2=I;
    for i=1:size(hkl,1)
	[I(i),th2(i)]=pxrd(compound, hkl(i,:));
    end
    return;
end

%now hkl is 1 by 3 - let's multiply...
K0=ainv*hkl';
K0=sqrt(sum(K0.^2));
hkl=xmult(hkl);
K=hkl*ainv';
K=sqrt(sum(K.^2,2));
%throw away out-of-limit HLK's and K's:
i=(abs((K-K0)/K0)>Kerr);
K(i)=[];
hkl(i,:)=[];

%And now, let's sum structure factors:
els = feval(compound, 'elements');
ne = size(els,1);
row0 = zeros(1, size(hkl,1));
F = row0;
for i=1:ne
    el = deblank(els(i,:));
    [x,y,z]=feval(compound, el);
    fel=xsf(el);	%scattering factor
    F=F + fel*sum([row0; exp( 2i*pi*( ([x,y,z]) * hkl' ))]);
end
F2=F.*conj(F);		%vector of structure factors
mF2=sum(F2);		%multiplicity * F2...

%let's get LP
th=asin(lam*K0/2);
th2=2*th;
LP=(1+cos(th2).^2)./(sin(th).*sin(th2));

%we're done!!!
I=mF2*LP;
th2=180/pi*th2;
I(I<1)=0;

function outhkl=xmult(hkl)
%returns all different equivalent hkl indexes

hkl=hkl(:)';
hkl=hkl(1:3);
hkl=hkl([1 2 3;1 3 2;2 1 3;2 3 1;3 1 2;3 2 1]);
outhkl=[];
for i1=0:1, for i2=0:1, for i3=0:1
    outhkl=[outhkl; hkl*diag((-1).^([i1 i2 i3]))];
end, end, end
outhkl=sortrows(outhkl);
d=diff(outhkl);
r=find(all(d==0,2));
outhkl(r,:)=[];
