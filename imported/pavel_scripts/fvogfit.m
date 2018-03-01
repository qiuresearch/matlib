function [lf, f0Ea]=fvogfit(tf,tm,lfdata)
%FVOGFIT   function for Vogel-Fulcher fit
%   LF=FVOGFIT(Tf, Tm, lfdata)
%   lf=f0 * exp(-E0/( k*(Tm-Tf) ))
%   LF is a vector of [f0(GHz)  E0(eV)   Tf(K)]

kb=1.38062e-23;		%J/K
eV=1.6021892e-19;	%J

tm=tm(:);
lfdata=lfdata(:);
lf0=-eV./( kb*(tm-tf) );
[a,b]=linreg(lf0, lfdata);
lf=a*lf0+b;
f0Ea=[exp(b)/1e9 a];
