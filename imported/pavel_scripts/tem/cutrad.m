function cutrad(rcut)
%CUTRAD    deletes plot points and texts behind specified radius
%	   CUTRAD(R)

% Pavol 1997

if isstr(rcut)
	rcut=sscanf(rcut, '%f');
end
H=hdifr('plot');
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
H=hdifr('text');
for i=1:length(H);
	h=H(i);
	xy=get(h, 'Position');
	r=sqrt(sum(xy.^2));
	if r>rcut;
		delete(h);
	end
end
	
