function Out=arcdifr(H, angle)
%ARCDIFR   changes point reflexies to arcs
%          ARCDIFR(H, ANGLE)
%	   H is DIFR plot number
%	   ANGLE is arc angle in degrees

%constant:
NPA=20;		%Number of points in arc
%

if nargin==1
	angle=H;
	H=gdn;
end
a=hdifr(H,'plot');
angle=pi/180*angle;
angle=((0:NPA-1)/(NPA-1) - .5) * angle;
angle=angle(:);
for i=1:length(a)
	b=a(i);
	x=get(b,'xdata');
	y=get(b,'ydata');
	r=sqrt(x.^2 + y.^2);
	fi=atan2(y,x);
	r=r(ones(NPA,1),:);
	fi=fi(ones(NPA,1),:);
	A=angle(:,ones(length(x),1));
	fi=fi+A;
	X=r.*cos(fi);
	Y=r.*sin(fi);
	X=[X;NaN*(1:length(x))];
	Y=[Y;NaN*(1:length(x))];
   set(b,'linestyle','-','xdata',X(:),'ydata',Y(:),...
       'Marker', 'none');
end
if nargout>0
	Out=a;
end
