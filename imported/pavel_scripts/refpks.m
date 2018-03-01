function [Sout,Rout] = refpks(file, varargin);
%REFPKS    refine peaks file by fitting pseudo-Voigt peak
%   [S,RES] = REFPKS(file, p1, p2, ...)   returns peak positions,
%   RES = sum(f-y)^2 / length(y)
%   S = REFPKS(file)   returns fitted peaks in a structure S with the
%   following fields: th2, d, irel, icps, fwhm, fn
%   icps  is intensity integrated over [xm-iw/2, xm+iw/2]
%   file  can be either pks file or structure
%   possible additional arguments p:
%    'xy', must be followed by [theta2, Int] data matrix
%    'iw', interval width, must be followed by number
%    'mx', reset initial peak position to the local maxima
%    'lam' wavelength, must be followed by number
%    'fn', peak function, must be followed by 'l', 'g', or 0<gamma<1
%    'fw', initial peaks FWHM, must be followed by number
%    'i',  show iterations
%    'v',  plot the fit details
%    'q',  for silent operation
%    'p',  print the fitted peaks (implicit if nargout==0)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%constants:
c_lam=phconst('cuka1');    %Cu Kalpha1
c_iw=2.4;		%interval width
c_fn=0.5;		%default function
c_fnset=0;		%use from file
c_fwset=0;		%use from file
c_i=0;			%do not show iterations
c_v=0;			%do not plot
c_q=0;			%report what is done
c_mx=0;			%do not search for lmx
c_fwhm=0.2;		%default...
c_fwhmset=0;		%use from file
c_xy=[];		%default...
c_p=(nargout==0);	%default...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin==0
  file='';
end
if nargin>1
    i=1;
    while i<=length(varargin)
	curarg=varargin{i};
	switch(curarg)
	    case 'lam',
	    i=i+1;
	    c_lam=varargin{i}(1);
	    case 'xy',
	    i=i+1; curarg=varargin{i};
	    c_xy=curarg;
	    if isempty(c_xy)
		error('empty XY matrix')
	    end
	    case 'iw',
	    i=i+1; curarg=varargin{i};
	    if isstr(curarg)
		c_iw=sscanf(curarg, '%f', 1);
	    else
		c_iw=curarg;
	    end
	    case 'fw',
	    i=i+1; curarg=varargin{i};
	    if isstr(curarg)
		c_fwhm=sscanf(curarg, '%f', 1);
	    else
		c_fwhm=curarg;
	    end
	    c_fwset=1;
	    case 'fn',
	    i=i+1; curarg=varargin{i};
	    if isstr(curarg)
		c_fn=sscanf(curarg, '%f', 1);
		if isempty(c_fn)
		    c_fn=curarg;
		end
	    else
		c_fn=curarg;
	    end
	    c_fnset=1;
	    case 'mx',
	    c_mx=1;
	    case 'v',
	    c_v=1;
	    case 'i',
	    c_i=1;
	    case 'q',
	    c_q=1;
	    case 'p',
	    c_p=1;
	    otherwise,
	    error(sprintf('unknown switch %s', curarg))
	end
	i=i+1;
    end
end

if isstr(file) & size(file,1)==1
    file=sscanf(file(file>='0' & file<='9'), '%i');
end
%read the data
if ~isstruct(file)
    sp=rpks(file);
    if ~exist('sp','var')
	return
    end
else
    sp=file;
end
sp.th2=sp.th2(:);
Np=length(sp.th2);

if ~isempty(c_xy)
    sp.xy=c_xy;
end
if ~isfield(sp, 'xy')
    if isnumeric(sp.fname)
	[xr,yr,sp.desc]=rraw(sp.fname);
	sp.fname = (sprintf('z%05i.raw', sp.fname));
    else
	[path, nam, ext]=fileparts(sp.fname);
	switch(lower(ext))
	case {'.raw', '.pks', ''},
	    rfile=fullfile(path, [ nam '.raw']);
	    [xr,yr,sp.desc]=rraw(rfile);
	case {'.gsas', '.gdat'},
	    rfile=sp.fname;
	    [xr,yr,ignore,sp.desc]=rgsas(rfile);
	end
    end
    sp.xy=[xr yr];
else
    xr=sp.xy(:,1);
    yr=sp.xy(:,2);
end

if ~isfield(sp, 'fname');
    sp.fname='';
end
if ~isfield(sp, 'fwhm') | c_fwset
    sp.fwhm = 0*sp.th2 + c_fwhm;
else
    sp.fwhm = sp.fwhm(:);
end
if ~isfield(sp, 'fn') | c_fnset
    sp.fn = c_fn(ones(Np,1),1);
else
    sp.fn = sp.fn(:);
end
%sort the peaks...
[ignore, i] = sort(sp.th2);
sp=pksind(sp,i);

%let's play with local maxima
if c_mx
    lp=max([ sp.th2-c_iw/2, ...
	    [-inf; (sp.th2(1:end-1)+sp.th2(2:end))/2] ], [], 2);
    hp=min([ sp.th2+c_iw/2, ...
	   [(sp.th2(1:end-1)+sp.th2(2:end))/2; inf] ], [], 2);
    for i=1:length(sp.th2)
	ix = (xr>=lp(i) & xr<=hp(i));
	xp = xr(ix);
	yp = yr(ix);
	[ignore, i1]=max(yp);
	if (c_v | c_i) & ~c_q
	    fprintf('adjusting peak position: %.2f --> %.2f\n',...
		sp.th2(i), xp(i1));
	end
	sp.th2(i)=xp(i1);
    end
end
%sp.th2 is now adjusted
if ~isfield(sp, 'icps');
    sp.icps=interp1(xr, yr, sp.th2);
end

if ~c_q
    fprintf('file %s, fitting %i peaks...\n', sp.fname, Np);
end
dth2=diff(sp.th2);
ibrk=[0; find(dth2>c_iw); Np];
for i1=1:length(ibrk)-1
    indp{i1}=ibrk(i1)+1:ibrk(i1+1);
end
xv=[]; yv=[];
P=sp;  P.th2=[]; P.d=[]; P.irel=[];
P.icps=[]; P.fwhm=[]; P.a=[]; P.fn='';

if c_v
    %h_f=figure('Visible', 'off');
    h_f=figure;
    h_a=gca; hold on;
    h_r=plot(xr,yr,'-', 'LineWidth', .25, 'MarkerSize', 3, 'Parent', h_a);
    pkplt(sp)
    [ignore, nam]=fileparts(sp.fname);
    nam=lower(nam);
    title(sprintf('%s peaks refinment', nam));
end
res=0;
for i1=1:length(indp)
    ip=indp{i1};
    if ~c_q
	s0=sprintf('%i ', ip); s0(end)='';
	fprintf('[%s]\n', s0);
    end
    p0.fn=sp.fn(ip,:);
    p0.p=sp.th2(ip);
    p0.w=sp.fwhm(ip);
    ix=zeros(size(xr));
    for i2=ip
	lp=sp.th2(i2)-c_iw/2;
	hp=sp.th2(i2)+c_iw/2;
	ix = ix | (xr>=lp & xr<=hp);
    end
    xp=xr(ix);
    yp=yr(ix);
    [p,res0]=npkfit(p0, xp, yp, 1, c_i);
    res = res + res0 * length(xp);
    P.th2=[P.th2; p.p'];
    P.fn=[P.fn; p.fn'];
    P.fwhm=[P.fwhm; p.w'];
    P.a=[P.a; p.a'];
    P.icps=[P.icps; npkar(p, p.p-c_iw/2, p.p+c_iw/2, 'each')'];
    %P.icps=[P.icps; npkar(p, -inf, inf, 'each')'];
    if c_v
	yy=npkfn(p, xp, 'fit');
	yy=cat(2, yy{:});
	plot(xp, yy, 'r', 'Parent', h_a)
	plot(xp, npkfn(p, xp), 'Color', ncol(2), 'Parent', h_a)
	xlim(h_a, xp(1), xp(end)); 
	drawnow
	xv=[xv(:); NaN; xp];
	yv=[yv(:); NaN; npkfn(p, xp)];
    end
end
if c_v
    pause(.5)
    xlim(h_a, min(P.th2)-c_iw, max(P.th2)+c_iw )
    %set(h_r, 'Marker', 'x');
    zoom on
end
P.d=th2d(P.th2, c_lam);
P.irel=100*P.icps/max(P.icps);
if c_p
    fprintf(' #     th2    fwhm    ampl    irel\n');
    fprintf('----------------------------------\n');
    fprintf('%2i%8.3f%8.4f%8.0f%8.2f\n', ...
	[1:length(P.th2) ; [ P.th2  P.fwhm P.a P.irel ]' ] );
end
if nargout>0
    Sout=P;
    Rout=res;
end
