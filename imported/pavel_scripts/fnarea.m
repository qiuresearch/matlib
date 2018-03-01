function a=fnarea(p, fnc, l, h)
%FNAREA    calculates area under fnpeak, without background
%A = FNAREA(P, FNC, L, H)
%    P are peak parameters, FNC can be 'gauss', 'gaussbg', 
%    'lorenz', 'lorenzbg'
%    L and H are integration limits
%
%See also FNPEAK

if nargin < 3
   l=-Inf; h=Inf;
elseif nargin==3
   h=l(:,2); l=l(:,1);
end

if any(strcmp(fnc, {'gaussbg', 'gauss'}))
   th=2*sqrt(log(2))*(h-p(1))/p(2);   
   tl=2*sqrt(log(2))*(l-p(1))/p(2);   
   a=sqrt(pi/log(2))/4 * p(2)*p(3) * (erf(th)-erf(tl));
   
elseif any(strcmp(fnc, {'lorenzbg', 'lorenz'}))
   th=2/p(2)*(h-p(1));   
   tl=2/p(2)*(l-p(1));   
   a=p(2)*p(3)/2 * (atan(th)-atan(tl));
   
else
    error('Unknown function...');
end

