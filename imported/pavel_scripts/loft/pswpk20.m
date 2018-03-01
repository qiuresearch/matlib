function [FPWA,XSC,PK]=pswpk2(pswxfiles, varargin)
%PSWPK2    fitting of PSW ordering peaks with double 100 peak
%    [FPWA,XSC,PK]=PSWPK2(XRDFILES, p1, p2, ...) 
%    possible additional arguments p:
%    'iw'  interval width, must be followed by number
%    'fn'  peak function, must be followd by 'l', 'g', or 0<gamma<1
%    'pk'  initial peak parameters
%    'v'   view the fit details
%    'i'   show iterations

%defaults and constants
iw=2.4;
deffn='l';
pk0.fn=deffn;
pk0.p=[18.8	21.4	21.8]; %positions
pk0.w=[.3	.1	.2];   %FWHM's
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
viewplot=0;
showiter=0;
if nargin>1
    setfun='';
    i=1;
    while i<=length(varargin)
	curarg=varargin{i};
	switch(curarg)
	    case 'iw',
	    i=i+1;
	    iw=varargin{i}(1);
	    case 'fn',
	    i=i+1;
	    setfun=sscanf(varargin{i}, '%f', 1);
	    if isempty(setfun)
		setfun=varargin{i}(1);
	    end
	    case 'pk',
	    i=i+1;
	    pk0=varargin{i}(1);
	    case 'v',
	    viewplot=1;
	    case 'i',
	    showiter=1;
	    otherwise,
	    error(sprintf('unknown switch %s', curarg))
	end
	i=i+1;
    end
    if ~isempty(setfun)
	pk0.fn=setfun;
    end
end

if isstr(pswxfiles) & size(pswxfiles,1)==1
    pswxfiles=sscanf(pswxfiles(pswxfiles>='0' & pswxfiles<='9'), '%i');
end
pswxfiles=pswxfiles(:);
fN=length(pswxfiles);
pN=2;
%FPWA - results matrix File Pos1 Fwhm1 Area1...
FPWA=[ pswxfiles , zeros(fN, 3*pN) ];

%scaling constant vector
XSC=zeros(fN,1);

row=1;
for f=pswxfiles'
    [x,y]=rraw(f);
    l=pk0.p-iw/2;
    h=pk0.p+iw/2;
    for i=1:length(l)
	ind=find(x>=l(i) & x<=h(i));
	[ig,j]=max(y(ind));
	l(i)=x(ind(j))-iw/2;
	h(i)=x(ind(j))+iw/2;
    end
    ind=0*x;
    for i=1:length(pk0.p)
	ind = ind | (x>=l(i) & x<=h(i));
    end
    x=x(ind); y=y(ind);
    if showiter
	disp(sprintf('Fitting Z%.5i.RAW...', f));
    end
    pk=npkfit(pk0, x, y, 1, showiter);
    PK(row)=pk;
    l=pk.p-iw/2;
    h=pk.p+iw/2;
    A=npkar(pk, l, h, 1:length(pk.p));
    if A(2)/A(3)>.2 & pk.p(3)-pk.p(2)<sum(pk.w(2:3))
	A(3)=A(2)+A(3);
    end
    FPWA(row,2:end)=[pk.p(1) pk.w(1) A(1) pk.p(3) pk.w(3) A(3)];
    %NO RENORMALIZATION
    %renormalize by 100:
    XSC(row)=1000/FPWA(row,3*2+1);
    FPWA(row,4:3:end)=FPWA(row,4:3:end)*XSC(row);
    row=row+1;
    if viewplot
	figure; 
	yy=npkfn(pk, x, 'fit');
	yy=cat(2, yy{:});
	plot(x,y,'.',x,npkfn(pk,x),x,yy)
	title(sprintf('%s fit for Z%i', mfilename, f));
	pk
	A=npkar(pk, l, h, 1:length(pk.p))
    end
end
if nargout==0
    fprintf('%i  %12.3f%12.4f%12.2f\n', FPWA(:,1:4)');
    clear FPWA
end
