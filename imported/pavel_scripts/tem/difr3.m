function difr3(hkli, S)
%DIFR3     Priestorovo zobrazi intenzity difrakcii
%	   DIFR3(hkli, S)  vyzaduje maticu hkli so 4 stlpcami,
%	   v ktorych su 3 indexy reflexii a vypocitana intenzita.
%	   S udava druh znaciek - tak ako pri prikaze PLOT
%	   velkost znaciek zavisi od intenzity logaritmicky

if nargin==1
      S='w.';
end
i=find(hkli(:,4)<5);
hkli(i,:)=[];
if all(hkli(:,1:3)>=0)	% potom prelozit do vsetkych "kubantov"
      hkli=[hkli;
	    hkli*diag([-1 1 1 1]);
	    hkli*diag([1 -1 1 1]);
	    hkli*diag([1 1 -1 1]);
	    hkli*diag([-1 -1 1 1]);
	    hkli*diag([-1 1 -1 1]);
	    hkli*diag([1 -1 -1 1]);
	    hkli*diag([-1 -1 -1 1])];
end
[hkli(:,4),i]=sort(hkli(:,4));
hkli(:,1:3)=hkli(i,1:3);
I=log(hkli(:,4)) / log(2);
if isempty(findobj('type','axes'))
	plot3([],[],[]);   %create 3D axes
end
if find(S=='.')
	Q=4;
else 
	Q=2;
end
holdstate=get(gca, 'NextPlot');
a=1; L=length(I);
while a<=L
	i = find(I==I(a));
	ms=6+Q*(I(a)-10);
	plot3(hkli(i,1), hkli(i,2), hkli(i,3), S, 'MarkerSize',ms);
	set(gca, 'NextPlot', 'add');
	a=i(length(i))+1;
end
x=min(hkli);
y=max(hkli);
h=x(1):2:y(1);
k=x(2):2:y(2);
l=x(3):2:y(3);
if strcmp(get(gca,'xgrid'),'on')
	set(gca, 'xtick', h, 'ytick', k, 'ztick', l);
end
set(gca, 'NextPlot', holdstate);
