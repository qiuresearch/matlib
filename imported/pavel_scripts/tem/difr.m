function NO=difr(compound, mno, hkl, S)
%DIFR      Shows electron diffraction in pole mno
%          DIFR(compound, mno)  
%          compound is function describing crystal unit cell
%          mno is lattice direction, 100 works as well as [1 0 0]
%
%          DIFR(compound, mno, S) 
%          uses S as plot style (see PLOT), where
%          marker size is propotianal to the logarithm of intensity
%
%          DIFR(compound, mno, hkl) or DIFR(compound, mno, hkl, S)
%          uses only diffracion indexes in 3-column matrix hkl
%          if hkl is 3-element vector, then its elements are taken
%          as ranges for indexes
%
%	   DIFR returns DIFR plot number

% 1997 by Pavol

%%%%%%%% konstanty %%%%%%%%%
tol = .1; 	%tolerancia sedenia v zone mno
Rmax = 2;	%maximalna vzdialenost reflexie v cm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin==2
      S='w.'; hkl=[];
elseif nargin==3
      if isstr(hkl)
         S=hkl;
         hkl=[];
      else
         S='w.';
      end
end
if length(mno)==1
   if mno<=999 & mno>0
	o=rem(mno, 10);
	n=rem(mno-o, 100)/10;
	m=(mno-o-10*n)/100;
	mno=[m n o];
   else
	error('Cannot understand mno argument');
   end
end
mno=mno(1:3); mno=mno(:);
mno=mno/norm(mno);

%get lattice parameters ...
abcABG=feval(compound, 'abc');
abcABG(4:6)=abcABG(4:6)*pi/180;
a=abcABG(1); b=abcABG(2); c=abcABG(3);
alpha=abcABG(4);beta=abcABG(5);gamma=abcABG(6);
lL=lambdal;

%Calculate fundamental lattice vectors
a1=a * [1               0                                               0];
a2=b * [cos(gamma)      sin(gamma)                                      0];
a3=    [cos(beta)       (cos(alpha)-cos(beta)*cos(gamma))/sin(gamma)    0];
a3(3) = sqrt(1-a3*a3');
a3=c * a3;

%Calculate base vectors of reciprocal lattice
ainv=inv([a1;a2;a3]);   %columns of ainv are base vectors

%Get diffraction indexes...
Hmax=ceil(a*Rmax/lL);
Kmax=ceil(b*Rmax/lL);
Lmax=ceil(c*Rmax/lL);
if prod(size(hkl))==3
        hkl=abs(hkl);
        Hmax=min(Hmax,hkl(1));
        Kmax=min(Kmax,hkl(2));
        Lmax=min(Lmax,hkl(3));
end
if prod(size(hkl))>3
        h=hkl(:,1); k=hkl(:,2); l=hkl(:,3);
else
        [h, k, l]=meshgrid(-Hmax:Hmax, -Kmax:Kmax, -Lmax:Lmax);
        h=h(:); k=k(:); l=l(:);
end

%Remove off-zone indexes
i=find(abs([h k l]*mno)>3*tol);
h(i)=[]; k(i)=[]; l(i)=[];

%Remove distant indexes
R=[h k l]*(ainv');
R=lL*sqrt((sum((R.^2)'))');
i=find(R>Rmax);
h(i)=[]; k(i)=[]; l(i)=[];

%Calculate intensities ...
hkli=intdif(compound, [h k l]);
i=find(hkli(:,4)<5);
hkli(i,:)=[];
if isempty(hkli)
	error('No reflexies to plot');
end
[hkli(:,4),i]=sort(hkli(:,4));
hkli(:,1:3)=hkli(i,1:3);
Ilog=log10(hkli(:,4));
Q0=Ilog(length(Ilog));                   %intensity of 000

%Now calculate plot positions...
mno=([a1' a2' a3']*mno);
mno=mno/norm(mno);
theta=acos(mno(3));
phi=-pi/2;
if theta>eps
        phi=atan2(mno(2),mno(1));
end
x0=[-sin(phi); cos(phi); 0];
y0=[-cos(phi)*cos(theta); -sin(phi)*cos(theta); sin(theta)];
X=hkli(:,1:3)*(ainv')*x0;
Y=hkli(:,1:3)*(ainv')*y0;
X=X*lL;
Y=Y*lL;
if find(S=='.')
        Q=12;
else 
        Q=5;
end

%Find free difr-plot number
No=1;
holdstate=get(gca, 'NextPlot');
if strcmp(holdstate,'add')
        No=1;
        N=gdn;
        while length(find(N==No))>0
                No=No+1;
        end
end

PlotTag=sprintf('DIFR plot No. %i',No);
TextTag=sprintf('DIFR indexes No. %i',No);

n=1;
L=length(Ilog);
h=[];
while n<=L
        i = find(Ilog==Ilog(n));
        ms=Q*Ilog(n)/Q0;
        h=[h; plot(X(i), Y(i), S, 'MarkerSize', ms, 'Tag', PlotTag) ];
        set(gca, 'NextPlot', 'add');
        n=i(length(i))+1;
end
txt=ones(L,8)*' ';
for a=1:L
        t=sprintf('%i',hkli(a,1:3));
        txt(a,1:length(t))=t;
end
txt=setstr(txt);
ht=text(X,Y,txt,'FontSize',8,'tag',TextTag,'Color',get(h(1),'Color'),...
   'HorizontalAlignment','Left',...
   'VerticalAlignment','Bottom');
for a=1:L
	set(ht(a),'UserData', hkli(a,1:3));
end
if No>1
   i=find(X==0 & Y==0);
   delete(ht(i));
end
axis equal;
set(gca, 'NextPlot', holdstate, 'Xlim', [-1 1]*Rmax,...
   'Ylim', [-1 1]*Rmax);
if nargout~=0
        NO=No;
end
