function a=npkar(pk, l, h, ind)
%NPKAR     area under Lorenz, Gauss or Pseudo-Voigt multi-peak function
%    A=NPKAR(PK, L, H, IND)
%    	   integrates PK function from L to H without background
%	   see NPKFN for the definition of PK structure
%	   IND index vector, if specified, NPKAR calculates area of the
%	   corresponding peaks
%    A=NPKAR(PK, L, H, 'each')
%    	   calculates area of every peak in PK
%
%See also NPKFN

if nargin < 4 
    ind='sum';
end
if strcmp(ind,'each') | strcmp(ind,'sum')
    jnd=1:length(pk.p);
else
    jnd=ind;
end
if length(h)==1
    h=h*ones(size(jnd));
end
if length(l)==1
    l=l*ones(size(jnd));
end


a=0*jnd;
if length(strmatch(pk.fn,'gauss')) | pk.fn==0
    for i=1:length(a)
	j=jnd(i);
        th=2*sqrt(log(2))*(h(i)-pk.p(j))/pk.w(j);   
        tl=2*sqrt(log(2))*(l(i)-pk.p(j))/pk.w(j);   
        a(i)=sqrt(pi/log(2))/4 *pk.w(j)*pk.a(j)*(erf(th)-erf(tl));
    end
elseif length(strmatch(pk.fn,'lorenz')) | pk.fn==1
    for i=1:length(a)
	j=jnd(i);
	th=2/pk.w(j)*(h(i)-pk.p(j));   
	tl=2/pk.w(j)*(l(i)-pk.p(j));   
	a(i)=pk.w(j)*pk.a(j)/2 *(atan(th)-atan(tl));
    end
elseif pk.fn>0 & pk.fn<1
    for i=1:length(a)
	j=jnd(i);
	%lorenz
	th=2/pk.w(j)*(h(i)-pk.p(j));   
	tl=2/pk.w(j)*(l(i)-pk.p(j));   
	a(i)=pk.fn(j) * pk.w(j)*pk.a(j)/2 *(atan(th)-atan(tl));
	%gauss
        th=2*sqrt(log(2))*(h(i)-pk.p(j))/pk.w(j);   
        tl=2*sqrt(log(2))*(l(i)-pk.p(j))/pk.w(j);   
        a(i)=a(i)+(1-pk.fn(j)) * ...
	    sqrt(pi/log(2))/4 *pk.w(j)*pk.a(j)*(erf(th)-erf(tl));
    end
else
    error('wrong value of pk.fn');
end

if strcmp(ind,'sum')
    a=sum(a);
end
