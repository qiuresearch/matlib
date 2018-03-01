function [pwa,err]=gfpk(pw, Showit, Method)
%GFPK      [GUI] fit of the Lorentz [default] or Gaussian peak with
%    a background. Click next to the peak position, GFPK works on the
%    current line object
%[PWA,ERR]=GFPK(PW),
%    where PWA is [POS WIDTH AREA], ERR is sum of squares
%    PW interval width used for peak fitting and AREA integration
%    if PW has 2 elements, the first one is used as initial position
%    and no gui is required
%PWA=GFPK(PW, 1) plots the fitted function
%PWA=GLOW(PW, 0, FNC) uses FNC as a peak function, which can be:
%		'lorenzbg' (default)
%		'lorenz' 
%		'gaussbg'
%		'gauss'

showit=0; method='lorenzbg';
if nargin>1; showit=Showit; end
if nargin>2; method=Method; end

hl=gco;
if ~strcmp(get(hl,'type'), 'line')
    hl=findobj(gca, 'type', 'line');
    hl=hl(1);
end
x=get(hl, 'xdata');
y=get(hl, 'ydata');
if length(pw)<2
    X0=ginput(1); X0=X0(1);
    iw=abs(pw(1));
else
    X0=pw(1);
    iw=abs(pw(2));
end
l=X0-iw/2;
h=X0+iw/2;
x1=x(x>l & x<h); x1=x1(:).';
y1=y(x>l & x<h); y1=y1(:).';
%get approximate FWHM:
Y0=interp1(x1,y1,X0);
YB0=interp1(x1([1 end]), y1([1 end]), X0); %background Y0
Itop=find(y1>(Y0+YB0)/2);
Ibrk=[0 find(diff(Itop)>1) length(Itop)];
n=1; ok=0;
while ~ok
    itop=Itop((Ibrk(n)+1) : Ibrk(n+1));
    ok= X0>x1(itop(1)) & X0<x1(itop(end));
    n=n+1;
end
W0=x1(itop(end))-x1(itop(1));

p0=[X0 W0];
[pl,ignore,ERR]=curvefit('fnpeak',p0,x1,y1,[],[],y1,method);
[y1l,pl]=fnpeak(pl,x1,y1,method);
Al=fnarea(pl, method, pl(1)-iw/2, pl(1)+iw/2);
pwa=[pl(1:2) Al];
if showit
    x1l=[x1(1) x1 x1(end)];
    y1l=[0 y1l 0];
    if length(pl)>3
	y1l([1 end])=pl(4)*x1([1 end])+pl(5);
    end
    ih0=ishold;
    hold on;
    hp=patch(x1l, y1l, .9*[1 1 1]);
    figure(gcf);
    disp('any key...'); pause;
    delete(hp);
    if ~ih0
	hold off;
    end
end
if nargout>1
    err=sum(ERR.^2);
end
