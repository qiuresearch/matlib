function [pk,resnorm]=nkfit(pk0, xdata, ydata, isbg, verbose)
%NPKFIT    curve fit of Lorenz, Gauss or Pseudo-Voigt multi-peak function
%    [PK,RES]=NPKFIT(PK0, XDATA, YDATA, ISBG, VERBOSE)
%    	   PK0 initial function parameters
%	   see NPKFN for the definition of PK structure
%	   set PK0.FN to 'gauss' for Gaussian fit
%	   'lorenz' for lorenz function
%	   or real number 0<gamma<1 for Pseudo-Voigt function
%	   ISBG if zero - don't add background
%	   VERBOSE if nonzero - show iterations
%
%See also NPKFN, NPKAR

%maxFWHM=1;
maxFWHM=Inf;
if nargin < 5
    verbose=0;
end
if nargin < 4
    isbg=1;
end

xdata=xdata(:);
ydata=ydata(:);
n=length(pk0.p);
x0=[pk0.p pk0.w];
lb(1:n)=min(xdata);
ub(1:n)=max(xdata);
ub(n+1:2*n)=ones(1,n)*maxFWHM;
if isnumeric(pk0.fn)
    if length(pk0.fn)==1
	pk0.fn=pk0.fn+0*pk0.p;
    end
    x0=[x0 pk0.fn];
    lb(2*n+1:3*n)=0+1e-7;
    ub(2*n+1:3*n)=1-1e-7;
end

if verbose
    opts=optimset('Display','iter','Jacobian','off');
else
    opts=optimset('Display','off','Jacobian','off');
end
x=lsqnonlin('npkfitfn',x0,lb,ub,opts,xdata,ydata,pk0,isbg);
[res, ignore, xlin]=npkfitfn(x,xdata,ydata,pk0,isbg);
resnorm=sum(res.^2)./length(xdata);
pk=pk0;
pk.p=x(1:n);
pk.w=x(n+1:2*n);
if isnumeric(pk0.fn)
    pk.fn=x(2*n+1:3*n);
end
pk.a=xlin(1:n);
pk.AB=xlin(n+1:n+2);

if any(diff(pk.p)<0)
    [pk.p,ind]=sort(pk.p);
    pk.w=pk.w(ind);
    pk.a=pk.a(ind);
end
