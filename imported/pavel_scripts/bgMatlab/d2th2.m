function th2 = d2th2(d, lambda);
%D2TH2       converts D to TH2
%  TH2 = D2TH2(D, LAMBDA)  parameter LAMBDA is optional, the default
%    wavelength corresponds to Cu Kalpha1 = 1.5406 Angstrom
%
%  D2TH2('plt', LAMBDA)  converts D to TH2 in axis GCA
%
%  See also TH2D, PHCONST

%  1999 by Pavol
%  $Id: d2th2.m 26 2007-02-27 22:45:38Z juhas $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<2
    lambda=phconst('cuka1');    %Cu Kalpha1
end
if strcmp(d, 'plt')
    h=findobj(gca,'type','line');
    for i=1:length(h)
       set(h(i), 'xdata', d2th2(get(h(i),'xdata'),lambda));
    end
    set(gca, 'xdir', 'normal');
    return;
end

th2=2*180/pi*asin(lambda./2./d);
