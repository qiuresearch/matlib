function pfill(fig, isoff)
%PFILL     set paper position of GCF to fill the entire page
%PFILL(FIGS, ['OFF'])  set paper position for figures FIGS
%PFILL ALL [OFF]  sets paper position for all figures
%PFILL OFF reverts to the default paper position

if nargin==0
   fig=gcf;
   isoff=0;
elseif nargin==1
    if strcmp(fig, 'off')
	isoff=1; fig=gcf;
    else
	isoff=0;
	if strcmp(fig, 'on')
	    fig=gcf;
	end
    end
else
    isoff=strcmp(isoff,'off');
end
if strcmp(fig,'all')
    fig=findobj('type','figure');
elseif isstr(fig)
    fig=eval(fig);
end

for i=1:length(fig)
    if ~isoff
	if strcmp(get(fig(i),'PaperOrientation') , 'portrait')
	   set(fig(i), 'PaperUnits', 'inches',...
	   'PaperPosition', [0.25 0.25 8 10.5]);
	else
	   set(fig(i), 'PaperUnits', 'inches',...
	   'PaperPosition', [0.25 0.25 10.5 8]);
	end
    else
	set(fig(i), 'PaperPosition', 'default');
    end
end
