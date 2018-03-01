function FET=vogelfit( fname, isshow, t0 )
%VOGELFIT  fit of the Vogel-Fulcher relation to the dielectric data
%FET=VOGELFIT(FNAME, ISSHOW, T0 ) fits the formula
%   f=f0 * exp(-E0/( k*(Tm-Tf) ))
%   returns FET vector of [f0(GHz) E0(eV) Tf(K)]
%   T0 is the initial fitting temperature in K
%FET=VOGELFIT(FILE,1)   also plots the fitted function

%constants:
%width of parabola for better maxima determination
parabwidth=5;
fet0=[100 0.1 300];
%%%%%%%%%%%%%%
if nargin==1 | isempty(isshow)
    isshow=0;
end
isshow=~~isshow;

if ~isstruct(fname)
    s=rted(fname);
else
    s=fname;
end
%
%convert to K:
s.t=s.t+273.15;
%do parabola fit for better Tm precision
tm=dielpk(s);
if nargin < 3
    t0=min(tm)-15;
elseif isstr(t0)
    t0 = sscanf( t0, '%f', 1 );
else
    t0 = t0(1);
end
% t0=min(tm)+15;
T=curvefit('fvogfit', t0, tm, log(s.f),[], [], log(s.f));
[ignore,x]=fvogfit(T, tm, log(s.f));
fet=[x T];
if nargout>0
    FET=fet;
else
    fprintf('f0=%.5g GHz\nE0=%.6f eV\nT0=%.2f K\n', fet);
end

if isshow
    figure;
    x=linspace(min(tm)-5, max(tm)+5);
    semilogy(x,fvogful(fet, x), tm, s.f, 'o');
    title(strrep([s.fname ', ' s.desc],'_','\_'));
    xlabel('T (K)');
    ylabel('f (Hz)');
end

function f=fvogful(fet, tm)
%F=FVOGFUL(TF, TM)   function for Vogel-Fulcher
%	FET is a vector of [f0(GHz)  E0(eV)   Tf(K)]

kb=1.38062e-23;		%J/K
eV=1.6021892e-19;	%J

%       lf=f0 * exp(-E0/( k*(Tm-Tf) ))
f=fet(1)*1e9*exp( -fet(2)*eV./(kb*(tm-fet(3))));
