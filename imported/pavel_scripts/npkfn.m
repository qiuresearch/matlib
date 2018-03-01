function y=npkfn(pk, x, fitflag)
%NPKFN     Lorenz, Gauss or Pseudo-Voigt multi-peak function
%    Y=NPKFN(PK, X)
%	   PK is structure with following fields:
%	   'fn'   'g', 'gauss' or 0 for gauss peak 'l', 'lorenz' or 
%		    1 for lorenz peak 0<fn<1 for Pseudo-Voigt
%	   'p'	    vector of peak positions
%	   'w'	    vector of peak FWHMs
%	   'a'	    vector of peak amplitudes
%          'AB'     linear background y=AB(1)*x+AB(2)

%2000 by Pavol

if nargin<3
    fitflag=0;
else
    fitflag=strcmp(fitflag,'fit');
end
y=0*x;
if length(strmatch(pk.fn,'gauss')) | pk.fn==0
    for i=1:length(pk.p)
	yy{i}=pk.a(i)*exp( -4*log(2)*(x-pk.p(i)).^2 / pk.w(i)^2 );
    end
elseif length(strmatch(pk.fn,'lorenz')) | pk.fn==1
    for i=1:length(pk.p)
	yy{i}=pk.a(i)./( 4/pk.w(i)^2*(x-pk.p(i)).^2 + 1 );
    end
elseif all(pk.fn>0 & pk.fn<1)
    for i=1:length(pk.p)
	yy{i}=pk.fn(i)*pk.a(i)./( 4/pk.w(i)^2*(x-pk.p(i)).^2 + 1 ) + ...
	      (1-pk.fn(i))*pk.a(i)*exp( -4*log(2)*(x-pk.p(i)).^2 / pk.w(i)^2 );
    end
else
    error('wrong value of pk.fn');
end

if fitflag
    y=yy;
else
    for i=1:length(pk.p)
	y=y+yy{i};
    end
    y=y+pk.AB(1)*x+pk.AB(2);
end
