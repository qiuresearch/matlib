function i=selpts(hin)
%SELPTS    find data points within mouse-specified limits
%   I=SELPTS(HLINE)
%   HLINE - handle to line object
%   I=SELPTS   select a line with the mouse
%   click right mouse button to proceed



oldname=get(gcf,'Name');
if nargin==0
     if isempty(findobj('type','axes'))
             i=[];
             return;
     end
     hin=findobj(allchild(gca),'type','line','visible','on');
     if length(hin)>1
         set(gcf, 'Name', 'SELECT YOUR LINE');
         selected=0;
         while(~selected)
            ginput(1);
            selected=strcmp(get(gco,'type'),'line') & any(hin==gco);
         end
         hin=gco;
     end
end
if isempty(hin)
     i=[];
     return;
end

yl=get(gca,'ylim');
cin=get(hin,'color');
xin=get(hin,'xdata');
yin=get(hin,'ydata');
cax=get(gca, 'ColorOrder');
clm=find(all(cax==cin(ones(size(cax,1),1),:),2));
clm=rem(clm,size(cax,1))+1;
clm=cax(clm,:);

hlm=line(NaN,NaN,'Color',clm,'Parent',gca);

set(gcf, 'Name', 'SELECT FIRST X-LIMIT');
[x,y,button]=ginput(1); button=1;
while button==1
        xlm(1)=x;
        xdata=xlm([1 1]);
        ydata=yl(1:2);
        set(hlm, 'xdata', xdata, 'ydata', ydata);
        [x,y,button]=ginput(1);
end
set(gcf, 'Name', 'SELECT SECOND X-LIMIT');
button=1;
while button==1
        xlm(2)=x;
        i=find(xin>=min(xlm) & xin<=max(xlm));
        xdata=[xdata(1:2) NaN xlm([2 2]) NaN xin(i)];
        ydata=[ydata(1:2) NaN yl(1:2) NaN yin(i)];
        set(hlm, 'xdata', xdata, 'ydata', ydata);
        [x,y,button]=ginput(1);
end

delete(hlm);
set(gcf,'Name',oldname);
