function eps=dielpol(fname, flags)
%DIELPOL   calculate relative permittivity from polarization hysterezis
%EPS=DIELPOL(FNAME, FLAGS) does permittivity calculation at half cycle
%   and zero field
%   if FLAGS contain
%   	v    view the diffuseness plot

%constants:
%number of points for line fit
nplf=10;
%%%%%%%%%%%%%%
if nargin==1
    flags=' ';
end

if ~isstruct(fname)
    sp=rpol(fname);
else
    sp=fname;
end

N=length(sp.e);
%return part of the curve
ind1=floor(3/8*N):ceil(5/8*N);
%absolute index of "zero field point"
ie0=find(sp.e(ind1)>0);
ie0=ie0(end)-1+floor(3/8*N);
%fit points:
ifit=ie0+(1:nplf)-round(nplf/2);
ef=sp.e(ifit);
pf=sp.p(ifit);
[a,b]=linreg(ef,pf);
%[ef]=kV/cm, [pf]=uC/cm2
eps=a*1e-11/phconst('eps0')+1; %1 is pro forma...

if any(flags=='v')
    %let's do the show
    cla; shpol(sp); hold on;
    plot(ef, pf, '.', ef, a*ef+b);
end
