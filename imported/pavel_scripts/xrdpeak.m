%XRDPEAK   xrd peaks fitting script
%   operates on data in x,y; specify l and h by mouse

HPF=gcf;
HRF=findobj(0, 'type', 'figure', 'tag', 'ReportFigure');
if isempty(HRF)
    HRF=figure('tag', 'ReportFigure');
end
if HPF==HRF
    HPF=get(0,'children');
    HPF=HPF(2);
end
figure(HPF);
if exist('HL')~=1 | ~ishandle(HL) |...
   get(get(HL,'parent'),'parent')~=HPF
    HL=findobj(gca,'type','line');
    if isempty(HL), return, end
    if length(HL)>1
	i=input(sprintf('which line (%i .. %i)? ', 1, length(HL)));
	HL=HL(i);
    end
end
%here HL is a scalar
x=get(HL, 'xdata');
y=get(HL, 'ydata');

oldtit=get(1,'Name');
set(1,'Name', 'SELECT LIMITS');
lh=ginput(2);
set(1,'Name', oldtit);
lh=sort(lh(:,1)); l=lh(1); h=lh(2);
p0=[mean(lh) (h-l)/3];
x1=x(x>=l & x<=h);
y1=y(x>=l & x<=h);
pl=curvefit('fnpeak',p0,x1,y1,[],[],y1,'lorenz');
[y1l,pl]=fnpeak(pl,x1,y1,'lorenz');
Al=fnarea(pl, 'lorenz', l, h);
%pg=curvefit('fnpeak',p0,x1,y1,[],[],y1,'gauss');
%[y1g,pg]=fnpeak(pg,x1,y1,'gauss');
%Ag=fnarea(pg, 'gauss', l, h);

figure(HRF);clf
hlp=plot(x1,y1,'k',x1,y1l,'r',x1,x1*pl(4)+pl(5),'r');
title( 'Lorenz peak fit' );
disp('Lorenz:'); pl, Al,
