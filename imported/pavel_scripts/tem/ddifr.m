function H=ddifr(a,b)
%DDIFR	  Utility for a double diffraction plot
%         DDIFR(a,b) combines line objects with handles a, b

m=length(a); n=length(b);
for i=1:m
	if ~strcmp(get(a(i),'type'),'line')
		error('Objects must be of line type.');
	end
end
for i=1:n
	if ~strcmp(get(b(i),'type'),'line')
		error('Objects must be of line type.');
	end
end
X=[];Y=[];
for i=1:m
	X=[X get(a(i),'XData')];
	Y=[Y get(a(i),'YData')];
end
P=get(a(1),'parent');
i=find(X==0 & Y==0);
X(i)=[]; Y(i)=[];
h=zeros(length(X),n);
for j=1:n
   x=get(b(j),'xdata');
   y=get(b(j),'ydata');
   for i=1:length(X)
	hh=copyobj(b(j),P); 
	set(hh, 'xdata', x+X(i),...
		     'ydata', y+Y(i));
	h(i,j)=hh;
   end
end
if nargout>0
	H=h;
end
