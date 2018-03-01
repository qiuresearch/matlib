function rotdifr(No, alpha)
%ROTDIFR   Rotate specified DIFR plot and its indexes by angle alpha
%	   ROTDIFR(N, ALPHA) rotates number N DIFR plot and indexes
%  	   text through angle ALPHA about an diffraction zone axis
%	   ROTDIFR(ALPHA) rotates all DIFR plots

%	1997 by Pavol

if nargin < 2
	alpha=No;
	No = gdn;
	if length(No)==0
	   return;
	end
end
if length(alpha)~=length(No)
	alpha = 0*No+alpha(1);
end
if length(No)>1
	for i=1:length(No)
		rotdifr(No(i), alpha(i))
	end
	return
end

h=hdifr(No,'plot');
t=hdifr(No,'text');
alpha=alpha*pi/180;
R=[	cos(alpha)	-sin(alpha)
	sin(alpha)	 cos(alpha)];

%rotate image
for i=1:length(h)
	x = get(h(i),'xdata');
	y = get(h(i),'ydata');
	xy=R*([x(:) y(:)])';
	x(:)=xy(1,:);
	y(:)=xy(2,:);
	set(h(i),'xdata',x,'ydata',y);
end

%rotate text
for i=1:length(t)
	xy=get(t(i),'Position');
	xy=R*[xy(1);xy(2)];
	set(t(i),'Position',xy);
end
