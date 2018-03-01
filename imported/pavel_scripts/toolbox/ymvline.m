function ymvline(h, dy)
%YMVLINE   shift specified line(s) in Y direction by DY
%   YMVLINE(HL,DY) 
%   HL  can be line handle or an integer referring to
%   last inserted line
%   YMVLINE ALL 10  shifts first line by 10, second by 20 etc.
%   YMVLINE IND  shows line indexes and does nothing

hall=findobj(gca,'type','line');
isall=0;
if isstr(h)
    if strcmp(h, 'ind')
	ht=0*hall;
	xl=get(gca,'xlim');
	yl=get(gca,'ylim');
	for i=1:length(hall)
	    h=hall(i);
	    x=get(h,'xdata');
	    y=get(h,'ydata');
	    ind=(x>=xl(1) & x<=xl(2) & y>=yl(1) & y<=yl(2));
	    if any(ind)
		x=x(ind); y=y(ind);
	    end
	    j=ceil((i-.5)*length(x)/length(hall));
	    ht(i)=text(x(j),y(j), sprintf('%i', i), 'color', get(h,'color'));
	end
	figure(gcf); pause
	delete(ht)
	return;
    elseif strcmp(h,'all')
	h=hall;
	isall=1;
    else
	h=eval(h,'[]');
    end
end
if isstr(dy)
    dy=eval(dy,'[]');
end
if length(dy)==1 & length(h)>1
    if isall
	dy=(0:length(h)-1)*dy;
	dy=dy-min(dy);
    else
	dy=ones(size(h))*dy;
    end
end

ii=find(h>0 & floor(h)==h);
h(ii)=hall(h(ii));
for i=1:length(h)
    hc=h(i);
    yc=get(hc,'ydata');
    set(hc, 'ydata', yc+dy(i));
end
