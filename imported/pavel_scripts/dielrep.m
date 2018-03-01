function [Sout, t_e_tdisp_tdiff]=dielrep(fname,flag)
%DIELREP   report on peaks and diffuseness of the dielectric data
%[Sout, t_e_tdisp_tdiff] = DIELREP(FNAME, FLAG) changes the output according to
%FLAG string:
%    'v'  plots the data
%    's'  uses short report
%    'hx' change the height for dieldif from 0.9 to x

if nargin<2
    flag='';
end
isshow=0; isshort=0;
if ~isstruct(fname)
    fname=rted(fname);
end
s=fname;
fno=length(s.f);
ind=1:fno;
flag=[flag ' '];
if any(flag=='v'), isshow=1; end
if any(flag=='s'), isshort=1; end
if isshow
    figure;
end
dt=dieldif(s,ind, flag);
[t,e]=dielpk(s,ind);
tdisp=t(end)-t(1);
dat=zeros(3,fno);
dat(1,:)=t;
dat(2,:)=e;
dat(3,:)=dt;
dat=[s.f';dat];
if isshort
    sout=sprintf('Tmax=%.1f, emax=%.0f, Tdisp=%.1f, Tdiff=%.1f',...
	t(end), e(end), tdisp, dt(end));
else
    sout = [  ...
    sprintf('  %s\n', s.fname) ...
    sprintf('  f         Tmax      emax      dT(90%%)\n') ...
    sprintf('  --------------------------------------\n') ...
    sprintf('  %-10.0g%-10.1f%-10.0f%-10.1f\n', dat) ...
    sprintf('  --------------------------------------\n') ...
    sprintf('  dTdisp = %.1f', tdisp) ...
    ];
end
if isshow
    hold on;
    plot([t;t], [e;e], '*')
    ylim(.8*min(e), 1.1*max(e))
    xlim auto
end
if nargout>0
    Sout=sout;
    t_e_tdisp_tdiff = [ t(end), e(end), tdisp, dt(end) ];
else
    fprintf('\n%s\n',sout);
end
