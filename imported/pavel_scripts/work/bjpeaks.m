function [FPWAI,PK]=bjpeaks(pswxfiles, varargin)
%BJPEAKS   fitting of Bostjan's peaks
%    [FPWA,PK]=BJPEAKS(XRDFILES, p1, p2, ...) 
%    possible additional arguments p:
%    'iw'  interval width, must be followed by number
%    'fn'  peak function, must be followd by 'l', 'g', or 0<gamma<1
%    'pk'  initial peak parameters
%    'v'   view the fit details
%    'i'   show iterations

%defaults and constants
iw=2.4;
deffn=0.5;
pk0.fn=deffn;
pk0.p=[18.8	21.73	30.93]; %positions
pk0.w=[.2	.2	.3];   %FWHM's
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
	    c_iw=sscanf(varargin{i}, '%f', 1);
	    if isempty(c_iw)
		c_iw=varargin{i}(1);
	    end
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
pN=length(pk0.p);
%FPWAI - results matrix File Pos1 Fwhm1 Amp1 Int1...
FPWAI=[ pswxfiles , zeros(fN, 4*pN) ];

row=1;
for f=pswxfiles'
    [x,y]=rraw(f);
    l=pk0.p-iw/2;
    h=pk0.p+iw/2;
    for i=1:length(l)
	ind=find(x>=l(i) & x<=h(i)); [ig,j]=max(y(ind));
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
    [pk,res]=npkfit(pk0, x, y, 1, showiter);
    l=pk.p-iw/2;
    h=pk.p+iw/2;
    A=npkar(pk, l, h, 1:length(pk.p));
    FPWAI(row,2:end)=[pk.p(1) pk.w(1) pk.a(1) A(1) ...
    pk.p(2) pk.w(2) pk.a(2) A(2) ...
    pk.p(3) pk.w(3) pk.a(3) A(3)];
    PK(row)=pk;
    row=row+1;
    if viewplot
	figure; 
	yy=npkfn(pk, x, 'fit');
	yy=cat(2, yy{:});
	plot(x,y,'.',x,npkfn(pk,x),x,yy)
	title(sprintf('%s fit for Z%i', mfilename, f));
	pk
	res
    end
end
if nargout==0
    fprintf('z%05i.raw\n', f);
    fprintf('pos\tfwhm\tI1/I2\n');
    fprintf('---------------------------\n');
    fprintf('%.3f\t%.4f\t%.4e\n',  [pk.p'   pk.w'   A'/A(3)]');
    fprintf('\n');
    clear FPWAI
end
