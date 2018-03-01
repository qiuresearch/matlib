function crad(rcut)
%CRAD      deletes plot points and texts behind specified radius
%	   CRAD(R)

% Pavol 1997

if isstr(rcut)
	rcut=sscanf(rcut, '%f');
end
H=findobj(gca,'linestyle','none');
for i=1:length(H);
	h=H(i);
	x=get(h, 'XData');
	y=get(h, 'Ydata');
	r=sqrt(x.^2 + y.^2);
	j=find(r>rcut);
	if length(j)==length(x)
		delete(h);
	else
		x(j)=[]; y(j)=[];
		set(h, 'Xdata', x, 'Ydata', y);
	end
end
H=findobj(gca,'type','text');
for i=1:length(H);
	h=H(i);
	xy=get(h, 'Position');
	r=sqrt(sum(xy.^2));
	if r>rcut;
		delete(h);
	end
end
	
