function [hsel,hrest]=seltext(hin)
%SELTEXT   smart mouse-based text selection within specified handles
%[HSEL,HREST]=SELTEXT([HIN])
%   HSEL  - handles to selected text objects
%   HREST - handles to not selected text objects
%   click right mouse button to finish selecting
%HSEL=SELTEXT('ALL')  get all text objects
%HSEL=SELTEXT(1)    select last inserted text object
%HSEL=SELTEXT(1:3)  select last 3 text objects
%SELTEXT IND	    shows text objects indexes and does nothing

% 1997 by Pavol

%hsel=[]; hrest=[];
if nargin==0
	if isempty(findobj('type','axes'))
		return;
	end
   hin=findobj(gca,'type','text','visible','on','units','data');
end

hall=findobj(gca,'type','text','visible','on','units','data');

if isempty(hin)
	return;
end
if isstr(hin)
    hin=lower(hin);
    if strcmp(hin, 'all')
	hsel=hall;
	hrest=[];
	return;
    elseif strcmp(hin, 'ind')
	for i=1:length(hall)
	    s0{i}=get(hall(i),'string');
	    s1=s0{i};
            if iscell(s1)
               s1=s1{1}; 
            elseif size(s1,1)
               s1=s1(1,:);
            end
	    set(hall(i),'string',sprintf('^{%i)} %s', i, s1));
	end
	drawnow;
	figure(gcf);
	pause;
	for i=1:length(hall)
	    set(hall(i),'string',s0{i});
	end
	return;
    else
	hin=eval(hin);
    end
end

if all(hin==floor(abs(hin))) 
    hin(hin<1 | hin>length(hall))=[];
    hsel=hall(hin);
    hrest=hall;
    hrest(hin)=[];
    return
end

%csel=[1     1     0
%      1     0     1
%      0     1     1
%      1     0     0
%      0     1     0
%      0     0     1];
csel=get(gca, 'ColorOrder');
hsel=[];
hrest=hin;

xtol=diff(get(gca,'xlim'))/25;
ytol=diff(get(gca,'ylim'))/25;
N=length(hin); txtpos=[]; txtc=[];
for i=1:N
	pp=get(hin(i), 'Position');
	pp=[pp zeros(1,3-length(pp))];
	txtpos=[txtpos; pp];
	txtc=[txtc; get(hin(i), 'Color')];
end
for i=1:size(csel,1)
	c=csel(i*ones(N,1),1:3);
	cdist(i,:)=sum(((txtc-c).^2).');
end
[ignore,itxtcinv]=sort(-cdist);
itxtcinv=itxtcinv(1,:);

[x,y,button]=ginput(1);
warning off
while button==1
	r2=(x-txtpos(:,1)).^2 + (y-txtpos(:,2)).^2;
	[ignore,i]=sort(r2); i=i(1);
	if abs(txtpos(i,1)-x)<xtol & abs(txtpos(i,2)-y)<ytol
		h=hin(i);
		k=find(h==hsel);
		l=find(h==hrest);
		if length(k)==0		%select
		   hsel=[hsel; h];
		   hrest(l)=[];
		   set(h,'Color', csel(itxtcinv(i),:));
		else			%unselect
		   hsel(k)=[];
		   hrest=[hrest; h];
		   set(h,'Color', txtc(i,:));
		end
	end
	[x,y,button]=ginput(1);
end
warning on

%restore colors
for i=1:length(hsel)
	k=find(hin==hsel(i));
	set(hsel(i),'color',txtc(k,:));
end

% vim:ts=4:
