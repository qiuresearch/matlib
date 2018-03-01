function h=hdifr(N, what)
%HDIFR	  returns handles to DIFR plots or diffraction indexes 
%	  H=HDIFR(N,'plot') returns only plot handles
%	  H=HDIFR(N,'text') returns only text handles
%	  H=HDIFR(N) returns both handles
%         N vector specifying DIFR plot(s) in current axis

% 1997 by Pavol

if nargin==0
	N=gdn;
	what='all';
elseif nargin==1
	if isstr(N)
		what=N;
		N=gdn;
	else
		what='all';
	end
end
if length(N)==1
	PlotTag=sprintf('DIFR plot No. %i',N);
	TextTag=sprintf('DIFR indexes No. %i',N);
	h=findobj(gca,'Type','line','Tag',PlotTag);
	t=findobj(gca,'Type','text','Tag',TextTag);
	what=lower(what);
	if strcmp(what,'text')
		h=t;
	elseif strcmp(what,'all')
		h=[h;t];
	end
else
   h=[];
	for i=1:length(N)
		h=[h;hdifr(N(i),what)];
	end
end
