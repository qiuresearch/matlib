function fixsize(ax, ratio)
%FIXSIZE   sets printing scale of specified axis
%	   FIXSIZE(AX, RATIO)
%	   AX is axes handle (optional)
%	   RATIO is size of 1 in cm (by default 3 cm)

%DEFAULTS:
DEF_RATIO=3;

%PROLOGUE
if nargin<2
	ratio=DEF_RATIO;
end
if nargin<1
	ax=gca;
end
if length(ax)>1
	for i=1:length(ax)
	    fixsize(ax(i),ratio)
	end
	return;
end
ratio=ratio(1);
axis equal;

%END OF PROLOGUE
OrgAxUnits=get(ax, 'Units');
fig=get(ax,'Parent');
OrgFigPaperUnits=get(fig, 'PaperUnits');
set(ax, 'Units', 'Normalized');
set(fig, 'PaperUnits', 'Centimeters');
xlim=get(ax, 'Xlim');
ylim=get(ax, 'Ylim');
axpos=get(ax, 'Position');
figpp=get(fig, 'PaperPosition');
axpapersize=axpos(3:4).*figpp(3:4);
newaxpapersize=[xlim(2)-xlim(1) , ylim(2)-ylim(1)] * ratio;
q=newaxpapersize ./ axpapersize;
axsize=axpos(3:4);
s=axpos(1:2)+axsize/2;
newpos(1)=axpos(1);
newpos(2)=axpos(2) + axpos(4)*(1-q(2));
newpos(3:4)=q.*axsize;
set(ax, 'Position', newpos);
set(fig, 'PaperUnits', OrgFigPaperUnits);
set(ax, 'Units', OrgAxUnits);
