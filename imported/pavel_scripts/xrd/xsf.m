function f=xsf(element, lambda)
%XSF(ELEMENT, LAM)  finds x-ray scattering factor
%    LAM is x-ray wavelength by default (Cu KA1)

%constants/defaults:
DATADIR='SFDATA';
if nargin<2
    f=xsfdef(element);
    return;
end

E=phconst('hceV')/(lambda*1e-10);
fname=strrep(which('xsf.m'), 'xsf.m', [DATADIR '\' lower(element) '.nff']);
eff=rhead(fname);
f=interp1(eff(:,1),eff(:,2:3),E);
f=f(1)+i*f(2);

