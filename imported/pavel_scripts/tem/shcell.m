function [X,Y,Z]=SHCELL(compound, SZ)
%SHCELL    nakresli elementarnu bunku danej zluceniny
%          SHCELL(compound)

% Pavol 1997

if nargin==1
    SZ=1;
end
SZ=mean(SZ);
els=feval(compound, 'elements');
N=size(els,1);
styles=['o';'x';'*';'+';'o';'x';'+';'*'];
holdstate=get(gca, 'NextPlot');
co=get(gca,'ColorOrder');
oldw=get(gcf,'WindowButtonDownFcn');
for i=1:N
	[x,y,z]=lattice(SZ*[1 1 1], compound, els(i,:));
	plot3(x,y,z,styles(rem(i,size(styles,1)),:), 'Color', co(i,:));
	set(gca, 'NextPlot', 'add');
end
[x,y,z]=lattice(SZ*[1 1 1], compound, 'grid');
plot3(x,y,z,'k:');
h=gca;
set(h, 'NextPlot', holdstate, 'Visible', 'off');
legend(els);
axes(h);
axis equal
set(gcf,'WindowButtonDownFcn',oldw);
