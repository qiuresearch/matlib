function N=GDN(ax)
%GDN	  gets numbers of DIFR plots
%	  N=GDN(H) returns numbers in specified axes
%	  N=GDN returns numbers in current axes


% 1997 by Pavol

N=[];
if nargin==0
	ax = findobj('type','axes');
	if isempty(ax)
		return;
	end
end
ax=ax(1);
h=findobj(ax, 'type', 'line');
for i=1:length(h)
	txt = get(h(i), 'Tag');
	j=length(txt);
	if j>14
		if strcmp(txt(1:14),'DIFR plot No. ');
		   N = [N sscanf( txt(15:j), '%i')];
		end
	end
end
N=sort(N);
dN=diff(N);
if length(dN)>0
   i=find(dN==0);
	N(i)=[];
end
