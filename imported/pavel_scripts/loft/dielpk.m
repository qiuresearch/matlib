function [T,E]=dielpk(fname, ind, isshow)
%DIEPK     find maxima of the dielectric peaks...
%[T,E]=DIEPK(FNAME, IND, ISSHOW)
%   returns TE matrix of [t1 epsmax1 t2 epsmax2 ...] of IND
%   curves with an optional plot of maxima if ISSHOW==1
%   use IND='all' for all curves

%constants:
%width of parabola for better maxima determination
parabwidth=5;
parabheight=15;
%%%%%%%%%%%%%%
if ~isstruct(fname)
    s=rted(fname);
else
    s=fname;
end
if nargin==1 | isempty(ind)
    ind=1:length(s.f);
end
if isstr(ind)
    if strcmp(ind,'all')
	ind=1:length(s.f);
    else
	ind=eval(ind);
    end
end
if nargin<3
    isshow=0;
end

[E,i]=max(s.k(:,ind));
T=(s.t(i))';
%do parabola fit for better Tm precision
for i1=1:length(ind)
    i2=(s.t>T(i1)-parabwidth/2 & s.t<T(i1)+parabwidth/2)|...
	(s.k(:,ind(i1)) > E(i1)-parabheight);
    t1=s.t(i2);
    k1=s.k(i2, ind(i1));
    p=polyfit(t1, k1, 2);
    T(i1)=-p(2)/(2*p(1));
    E(i1)=polyval(p,T(i1));
end
if isshow
    cla;shted(s,'e');hold on;
    plot([T;T],[E;E],'*')
end
