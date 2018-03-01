function ccnt(ax)
%CCNT      centers plot points and texts to center of mass
%	   CCNT(HAX)

% Pavol 1997

if nargin==0
	ax=gca;
end
H=findobj(ax,'type','line');
x=[]; y=[]; z=[];
for i=1:length(H);
	h=H(i);
	xp=get(h, 'XData');
	yp=get(h, 'Ydata');
	zp=get(h, 'Zdata');
	x=[x;xp(:)];
	y=[y;yp(:)];
	z=[z;zp(:)];
end
i=isnan(x) | isnan(y) | isnan(z);
x(i)=[];y(i)=[];z(i)=[];
xc=mean(x); yc=mean(y); zc=mean(z);
for i=1:length(H);
    h=H(i);
    set(h, 'XData', get(h, 'XData')-xc);
    set(h, 'YData', get(h, 'YData')-yc);
    set(h, 'ZData', get(h, 'ZData')-zc);
end
	
