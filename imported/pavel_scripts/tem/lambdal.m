function lL=lambdal(U, L)
%LAMBDAL   returns product of camera length and electron wavelength
%	   lL=LAMBDAL(U, L)
%	   U is acceleration voltage in kV,
%	   L is camera length in cm
%
%          edit to change prefered voltage or camera length

%1997 by Pavol

%%DEFAULTS%%
Ldef = 50;	%cm
Udef = 120;	%kV
if nargin<2
	L = Ldef;
end
if nargin<1
	U = Udef;
end

lL = L.*wavelen(U);      %Acm
