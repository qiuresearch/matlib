function centax(h, how)
%CENTAX    center axis within the figure
%          CENTAX(H, HOW)
%          H is vector of axis handles
%	   HOW can be either 'hor' (default) for horizontal or
%	   'vert' for vertical center
%          CENTAX(HOW) applies to the current axis

if nargin==0
	h=gca; how='hor';
elseif nargin==1
	if isstr(h)
		how=h;
		h=gca;
	else
		how='hor';
	end
end

p=zeros(prod(size(h)),4);
for i=1:prod(size(h))
	p(i,:)=get(h(i), 'Position');
end

if strcmp(how, 'hor')
	newp=[(1-p(:,3))/2 , p(:,2:4)];
elseif strcmp(how, 'vert')
	newp=[p(:,1) (1-p(:,4))/2 , p(:,3:4)];
else
	error('How the hell should I center that axis?');
end

for i=1:prod(size(h))
	set(h(i),'Position', newp(i,:));
end
