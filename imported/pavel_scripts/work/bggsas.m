function [yb,pp]=bggsas(x0, y0, ni, dm, p)
%[yb,pp]=bggsas(x0, y0, ni, dm, p)
%    ni  number of iteration
%    dm  use only points, for which (yb-y0) < dm*std(yb-y0)
%    p	 smoothing parameter for CSAPS
%
%open this file to see the procedure for background fitting...

%there are no peaks for 12<th2<13, let's evaluate sig there...
sl = [8 9];
fprintf('sigma evaluated on (%.2f,%.2f)\n', sl);
is = find(x0>sl(1) & x0<sl(2));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ib = (1:length(x0))';
w = 1./sqrt(y0);
w = ones(size(y0));
figure('Units', 'normalized', 'Position', [0 .6 1 .38])
plot(x0,y0); hold on;
hd = plot(NaN,NaN,'r.');
hb = plot(NaN,NaN,'k');
ylim(0, 2*mean(y0));
ylim 0 75
for iter=1:ni
    fprintf('%i of %i\n', iter, ni);
    set(hd, 'XData', x0(ib), 'YData', y0(ib));
    drawnow
    pp = csaps(x0(ib), y0(ib), p, [], w(ib));
    yb = ppval(pp, x0);
    set(hb, 'XData', x0, 'YData', yb)
    drawnow
    sig = std(y0(is)-ppval(pp,x0(is)));
    ib = ib( abs(y0(ib)-yb(ib)) < dm*sig );
end
zoom on

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%you may want to try this:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%lam = 0.699917;
%%d(hkl)/a
%da = [  0.57848045949600 0.50090951447683 0.35355339059327 0.30124290124543 ...
%	0.28845343580234 0.24968936429557 0.22887537833988 0.22329774591964 ...
%	0.20379330614877 0.19195486728430 0.17642876946546 0.16864041966324 ...
%	0.16635123270891 0.15777265923192 0.15039522705167 0.14399565894642 ...
%	0.13331159656061 0.12468226214019 0.11755804588567 0.11150693906749 ...
%	0.10633194314402 0.10180261614209 0.09779204891296 0.09261474605564 ...
%	0.09102079566063 0.08694510067106 0.08562352902261 ...
%	0.08434771232581 0.08311256166161 0.08191885797346 0.08083187776787 ];
%fn='c35tm1.gsas';
%[x0,y0]=rgsas(fn);
%a=0; [i,im]=max(y0); a=th2d(x0(im), lam)*sqrt(8)
%s0.th2=d2th2(da*a,lam); s0.xy=[x0 y0];
%s1=refpks(s0, 'iw',.6,'fw',.05,'v','mx');
%i=find(s1.irel < .05);
%s1=pksind(s1,i,'v');
%k=2.5;l=s1.th2-k*s1.fwhm; r=s1.th2+k*s1.fwhm;
%ib=1:length(x0);for i=1:length(l); ib(x0>l(i) & x0<r(i))=0; end; ib=ib(ib~=0);
%[yb,pp]=bggsas(x0(ib(1:2:end)),y0(ib(1:2:end)),4,2.5,.20);
%hold on;plot(x0,y0,'g')
%yc=y0-ppval(pp,x0); yc = yc+mean(y0)-mean(yc);
%wgsas(fn, strrep(fn, '.gsas', 'b.gsas'), yc);
