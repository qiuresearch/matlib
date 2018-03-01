function DT=dieldif(fname, ind, flags)
%DIELDIF   find diffuseness of dielectric peaks
%DT=DIELDIF(FNAME, IND, FLAGS) finds diffuseness of dielectric peaks
%   i.e. peak width at 0.9 of the dielectric maximum
%   DT=[DT1 DT2 ...], for IND curves
%   use IND='all' for all curves
%   FLAGS if contain
%   	v    view the diffuseness plot
%   	hx   change the height from 0.9 to x (example: h0.95)

%constants:
%width of parabola for better maxima determination
atheight=0.9; %get dT at atheight of maxima
%%%%%%%%%%%%%%
if nargin==1
    ind=[];
end
if isstr(ind)
    if strcmp(ind,'all')
	ind=[];
    else
	ind=eval(ind);
    end
end
if nargin<3
    flags=' ';
end
isshow=0;
if any(flags=='v')
    isshow=1;
end
hpos=findstr(flags,'h');
if ~isempty(hpos)
    atheight=sscanf(flags(hpos(end)+1:end), '%f', 1);
end

for indf=1:size(fname,1)
    if ~isstruct(fname(indf,:))
	s=rted(fname(indf,:));
    else
	s=fname(indf,:);
    end
    if isempty(ind)
	jnd=1:length(s.f);
    else
	jnd=ind;
    end
    t0=s.t;
    if isshow
	cla; shted(s,'e'); hold on;
    end
    for j=1:length(jnd)
	k0=s.k(:,jnd(j));
	km=max(k0);
	k1=k0(k0>km*0.5*atheight);
	t1=t0(k0>km*0.5*atheight);
	[km,i1]=max(k1);
	[kl1,il]=sort(k1(1:i1));
	tl1=t1(il);
	iout=(diff(kl1)==0);
	kl1(iout)=[]; tl1(iout)=[];
	[kh1,ih]=sort(k1(i1:end));
	th1=t1(ih+i1-1);
	iout=(diff(kh1)==0);
	kh1(iout)=[]; th1(iout)=[];
	tl=interp1(kl1,tl1,atheight*km);
	th=interp1(kh1,th1,atheight*km);
	dt=abs(th-tl);
	DT(indf,j)=dt;
	if isshow
	    plot([tl,th],[km km]*atheight, 'color', ncol(j));
	    text((tl+th)/2,km*atheight, num2str(dt,'%.1f'), 'color', ncol(j),...
	    'verticalalignment','baseline');
	end
    end
end
