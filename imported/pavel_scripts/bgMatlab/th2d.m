function d = th2d(th2,lam);
%TH2D        calculates D spacing from TH2
%  D = TH2D(TH2, LAMBDA)  parameter LAMBDA is optional, the default
%    wavelength corresponds to Cu Kalpha1 = 1.5406 Angstrom
%
%  TH2D('plt', LAMBDA)  converts TH2 to D in axis GCA
%
%  See also D2TH2, PHCONST

%  1999 by Pavol
%  $Id: th2d.m 26 2007-02-27 22:45:38Z juhas $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<2
    lam=phconst('cuka1');    %Cu Kalpha1
end
if strcmp(th2, 'plt')
    h=findobj(gca,'type','line');
    for i=1:length(h)
       set(h(i), 'xdata', th2d(get(h(i),'xdata'),lam));
    end
    set(gca, 'xdir', 'reverse','XLimMode', 'auto');
    return;
end

d=lam/2./sin(th2/2*pi/180);
