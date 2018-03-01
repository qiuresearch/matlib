function xmvline(h, dx)
%XMVLINE     shift specified line(s) in X direction by DX
%  XMVLINE(HL,DX)  HL can be a line handle or an index of
%    the most recent line
%  XMVLINE ALL 10  shifts first line by 10, second by 20 etc.
%  XMVLINE IND  show line indices and do nothing

%  $Id: xmvline.m 26 2007-02-27 22:45:38Z juhas $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
if isstr(dx)
    dx=eval(dx,'[]');
end
if length(dx)==1 & length(h)>1
    if isall
	dx=(0:length(h)-1)*dx;
	dx=dx-min(dx);
    else
	dx=ones(size(h))*dx;
    end
end

ii=find(h>0 & floor(h)==h);
h(ii)=hall(h(ii));
for i=1:length(h)
    hc=h(i);
    xc=get(hc,'XData');
    set(hc, 'XData', xc+dx(i));
end
