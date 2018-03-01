function lambda = wavelen(U)
%WAVELEN   Wave length of electron
%	   WAVELEN(U) is the wave length in A of an electron
%	   accelerated by voltage U (kV)

%	1996 by Pavol.
m = 511.0034; 		%keV/c2   electron mass
hc = 12.398520; 	%keVA	  Planck constant
lambda = hc ./ sqrt( U.^2 + 2*U*m );
