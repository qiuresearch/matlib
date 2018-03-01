function corxrd(hax)
%CORXRD         UI correct of XRD pattern to Si peaks (CuKA)
%CORXRD(H)      corrects XRD patterns in axis H

% 1998 by Pavol

%Silicon data
t2Sihkl = [ 28.443    1 1 1
            47.304    2 2 0
            56.122    3 1 1
            69.132    4 0 0
            76.380    3 3 1
            88.029    4 2 2
            94.951    5 1 1
            106.719   4 4 0
            114.092   5 3 1
            127.547   6 2 0
            136.897   5 3 3];

%1:1 ordered perovskite data:
phkl=[	1/2 	1/2 	1/2
	1	0	0
	1	1	0
	3/2	1/2	1/2
	1	1	1
	2	0	0
	3/2	3/2	1/2
	2	1	0
	2	1	1
	2	2	0
	3	1	0];
pq2=sum(phkl.^2,2)./sum(phkl(1,:).^2);
	
t2Si=t2Sihkl(:,1);
hkl=t2Sihkl(:,2:4);

if nargin==0
    hax=gca;
end
hax=hax(1);

hpl=findobj(hax,'type','line','visible','on');
if isempty(hpl)
    error('No spectra within current axis');
end

set(hax,'Selected','on');
figure(get(hax,'Parent'));
%Now find line with most points...
ll=0*hpl;
for i=1:length(hpl)
    ll(i)=length(get(hpl(i),'xdata'));
end
[ll,i]=max(ll);
hl=hpl(i);
%and go onto it...
t2=get(hl,'xdata');
xl0=get(hax,'xlim');
yl0=get(hax,'ylim');
i=find(t2Si<max(t2) & t2Si>min(t2));
t2Si=t2Si(i); hkl=hkl(i,:);
ht=text(xl0(1),yl0(1),'','FontSize',13,'Color','r');
set(hax,'ylimmode','auto');
t2old=0*t2Si; j=[];
for i=1:length(t2Si)
    set(hax,'xlim',[-1.25 1.25]+t2Si(i));
    set(ht,'Position',[t2Si(i), mean(get(hax,'ylim'))],...
           'String',sprintf(['Select Si %i%i%i peak (%.3f°),',...
                    '\nright button to skip'],hkl(i,:),t2Si(i)) );
    drawnow;
    [x,y,butt]=ginput(1);
    if butt==1
       t2old(i)=x;
    else
       j=[j i];
    end
end
t2Si(j)=[];
t2old(j)=[];
for i=1:length(hpl)
    h=hpl(i);
    set(h,'xdata',myinterp(t2old,t2Si,get(h,'xdata')));
end
set(hax,'xlim',xl0,'ylim',yl0,'Selected','off');
delete(ht);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function yi=myinterp(x,y,xi)
L=length(x);
switch(L)
   case 0,     yi=xi;
   case 1,     yi=xi+y-x;
   otherwise,  yi=0*xi;
               i=find(xi<=x(1));
               yi(i)=(y(2)-y(1))/(x(2)-x(1))*(xi(i)-x(1))+y(1);
               i=find(xi>x(L));
               yi(i)=(y(L)-y(L-1))/(x(L)-x(L-1))*(xi(i)-x(L-1))+y(L-1);
               for u=1:L-1
                   i=find(xi>x(u) & xi<=x(u+1));
                   yi(i)=(y(u+1)-y(u))/(x(u+1)-x(u))*(xi(i)-x(u))+y(u);
               end
end


