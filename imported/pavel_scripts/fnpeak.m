function [y,p1]=fnpeak(p, x0, y0, fnc)
%FNPEAK    function for fitting Gauss or Lorenz peak with or
%	   without background
%[Y,P1]=FNPEAK(P, X0, Y0, FNC)
%   X0, Y0 are fitted data points
%   FNC  can be 'gauss', 'gaussbg', 'lorenz', 'lorenzbg'
%   P 	 is a vector of parameters of the function FNC
%   or 'lorenz'
%
%   gauss[bg]:   f = P(3)*exp( -4*log(2)*(x-P(1)).^2)/P(2)^2 ) +
%                    [+ P(4)*x + P(5)]
%
%   lorenz[bg]:  f = P(3)/( 4/P(2)^2 * (x-P(1)).^2 + 1) +
%		     [+ P(4)*x + P(5)]
%
%Y=FNPEAK(P, X0, FNC)   form for FNC evaluation
%
%   parameters P have following meaning:
%      P(1)   peak center
%      P(2)   full width at half maxima
%      P(3)   peak height
%      P(4:5)   parameters of linear background
%
%      P(1:2) must be defined, the rest of P are linear and can be calculated
%      from Y0 (which is required if length(P)==2)

%1999 by Pavol

if nargin==3
   fnc=y0; clear y0
end

if all(fnc(end-1:end)=='bg')
    addbg=1;
    fnc(end-1:end)='';
else
    addbg=0;
end

if strcmp('gauss', fnc)
    f = exp( -4*log(2)*(x0-p(1)).^2 / p(2)^2 );
elseif strcmp('lorenz', fnc)
    f = 1./( 4/p(2)^2 * (x0-p(1)).^2 + 1);
else
    error('Unknown function...');
end

if exist('y0')~=1
    y=p(3)*f;
    if addbg
	y=y+p(4)*x0 + p(5);
    end
    p1=p;
else
    b=y0(:);
    if addbg
	M=[f(:) x0(:) ones(length(b),1)];
    else
	M=f(:);
    end
    pp=M\b;
    y=zeros(size(x0));
    y(:)=M*pp;
    p1=p(1:2);
    p1=[p1 pp.'];
    p1(2)=abs(p1(2));
end
