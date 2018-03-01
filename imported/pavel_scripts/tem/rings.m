function NO=rings(compound, mno, hkl, S)
%RINGS     Shows electron diffraction with mno texture in pole mno
%          RINGS(compound, mno)  
%          compound is function describing crystal unit cell
%          mno is lattice direction, 100 works as well as [1 0 0]
%
%          RINGS(compound, mno, S) 
%          uses S as line style (see PLOT)
%          linewidth is proportional to the logarithm of intensity
%
%          RINGS(compound, mno, hkl) or RINGS(compound, mno, hkl, S)
%          uses only diffracion indexes in 3-column matrix hkl
%          if hkl is 3-element vector, then its elements are taken
%          as ranges for indexes
%
%          RINGS returns DIFR plot number

% 1997 by Pavol

%%%%%%%% konstanty %%%%%%%%%
tol = .1; 	%tolerancia sedenia v zone mno
Rmax = 2;	%maximalna vzdialenost reflexie v cm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin==2
      S='w-'; hkl=[];
elseif nargin==3
      if isstr(hkl)
         S=hkl;
         hkl=[];
      else
         S='w-';
      end
end
if length(mno)==1
   if mno<=999 & mno>=0
	o=rem(mno, 10);
	n=rem(mno-o, 100)/10;
	m=(mno-o-10*n)/100;
	mno=[m n o];
   else
	error('Cannot understand mno argument');
   end
end
mno=mno(1:3); mno=mno(:);
if norm(mno)>10*eps;
	mno=mno/norm(mno);
end

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
	i=find(h==0 & k==0 & l==0);
	if length(i)==0
	   h=[0;h]; k=[0;k]; l=[0;l];
	end
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
h(i)=[]; k(i)=[]; l(i)=[]; R(i)=[];

%Calculate intensities ...
hkli=intdif(compound, [h k l]);
i=find(hkli(:,4)<5);
hkli(i,:)=[]; 
R(i)=[];
[R,i]=sort(R); hkli=hkli(i,:);
i=[find(diff(R)>1000*eps) ; length(R)];
R=R(i); hkli=hkli(i,:);
I=hkli(:,4);

numI=diff([0;i]);
I=I.*numI;
len=length(I);
I(2:len)=I(2:len)./(2*pi*R(2:len));      %lebo R(1)==0
Ilog=log10(I);
Q0=Ilog(1);                              %intensity of 000

%Find free difr-plot number
No=1;
holdstate=get(gca, 'NextPlot');
if strcmp(holdstate,'add')
        No=1;
        N=[gdn -1];
        while length(find(N==No))>0
                No=No+1;
        end
end
PlotTag=sprintf('DIFR plot No. %i',No);
TextTag=sprintf('DIFR indexes No. %i',No);

%Now calculate plot positions...
X=cos(0:2*pi/150:2*pi);
Y=sin(0:2*pi/150:2*pi);
x=R(1); y=R(1); 
h=plot(x,y,'.', 'MarkerSize', 12);
set(gca, 'NextPlot', 'add');
txt=ones(len,8)*' '; 
txt(1,1:3)='000';
for i=2:len
   x=X*R(i); y=Y*R(i);
   lw=1.3*Ilog(i)/Q0;
   h=[h; plot(x, y, S, 'LineWidth', lw)];
   t=sprintf('%i',hkli(i,1:3));
   txt(i,1:length(t))=t;
end
col=get(h(2),'color');
set(h,'Tag', PlotTag, 'color', col);
txt=setstr(txt);
x=R*cos(pi/5); y=R*sin(pi/5);
ht=text(x,y,txt,'FontSize',8,'Tag',TextTag,'Color',col,...
   'HorizontalAlignment','Left',...
   'VerticalAlignment','Bottom');
for i=1:len
   set(ht(i), 'UserData', hkli(i,1:3));
end
if No>1
   delete(ht(1));
end
axis equal;
set(gca, 'NextPlot', holdstate, 'Xlim', [-1 1]*Rmax,...
   'Ylim', [-1 1]*Rmax);
if nargout~=0
        NO=No;
end
