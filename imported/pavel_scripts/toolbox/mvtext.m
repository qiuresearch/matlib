function mvtext(H, Dxy, Isabs)
%MVTEXT    select and move text objects with a mouse ...
%MVTEXT(HT)  move text object with handle H
%MVTEXT 1    move last inserted text
%MVTEXT 1:3  move last 3 inserted text objects
%MVTEXT ALL  move all text objects within gca
%MVTEXT ALL [DX DY] or
%MVTEXT(HT,[DX DY])  shift text objects by [DX DY]
%MVTEXT(HT, [X Y], 'abs')  move text to [X Y]
%MVTEXT(HT, [X DY], 'absx')  move text to [X Y+DY]
%MVTEXT(HT, [DX Y], 'absy')  move text to [X+DX Y]
%MVTEXT IND  shows indexes of the text objects and does nothing

h=[]; dxy=[]; isabs=0;
if nargin>0
    if strcmp(H,'show')
	updatepos;
	return;
    end
    h=H;
end
if nargin>1; dxy=Dxy; end
if nargin>2 & strmatch(Isabs, {'abs', 'absx', 'absy'})
    isabs=Isabs;
end

%get the text handles
if isempty(h)
    h=geth('text');
end
if isstr(h)
    if strcmp(lower(h),'all')
	h=seltext('all');
    elseif strcmp(lower(h),'ind')
	seltext ind;
	return;
    else
	h=eval(h);
    end
end
if all(h==floor(abs(h))) 
    ah=findobj(gca,'type','text');
    h(h<1 | h>length(ah))=[];
    h=ah(h);
end
if isempty(h)
    return;
end

%and now play with dxy:
if isempty(dxy)
    olduserdata=get(gcf,'UserData');
    oldwndfnc=get(gcf, 'WindowButtonMotionFcn');
    set(gcf,'WindowButtonMotionFcn', 'mvtext show',...
	'UserData', h)
    waitforbuttonpress;
    set(gcf, 'UserData', olduserdata,...
	'WindowButtonMotionFcn', oldwndfnc);
    return
end

if isstr(dxy)
    dxy=eval(dxy);
end
if isabs
    switch(isabs)
    case 'abs',
	if size(dxy,1)~=length(h)
	  error('sizes of HT and [X Y] must match')
	end
	for i=1:length(h)
	  set(h(i), 'Units','data','Position',dxy(i,1:2))
	end
    case 'absx',
	for i=1:length(h)
	  xy=get(h(i),'Position'); xy=xy(1:2);
	  xy = dxy + [0 xy(2)];
	  set(h(i),'Position',xy);
	end
    case 'absy',
	for i=1:length(h)
	  xy=get(h(i),'Position'); xy=xy(1:2);
	  xy = dxy + [xy(1) 0];
	  set(h(i),'Position',xy);
	end
    end
else
    for i=1:length(h)
      xy=get(h(i),'Position'); xy=xy(1:2);
      set(h(i),'Position',xy+dxy(1:2));
    end
end

function updatepos
h=get(gcf,'userdata');
xy=get(h(1),'position');
hax=get(h(1),'parent');
XY=get(hax,'CurrentPoint');
XY=XY([1 3]);
dx=XY(1)-xy(1); dy=XY(2)-xy(2);
for i=1:length(h)
    xy=get(h(i),'Position'); xy=xy(1:2);
    set(h(i),'Position',xy+[dx dy]);
end
