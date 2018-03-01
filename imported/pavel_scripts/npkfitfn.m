function [f,J,xlin]=npkfitfn(x, xdata, ydata, pk0, isbg)
%NPKFITFN  curve fit function - returns sum of squares 
%[F,J,XLIN]=NPKFITFN(X, XDATA, YDATA, PK0, ISBG) 
%   X function parameters, X is a vector of [p1 w1, p2 w2... gamma],
%   where p is for peak positions, w for FWHM's
%   gamma if present is for Pseudo-Voigt parameter
%   PK0 is npk structure
%   ISBG if zero -> don't add background
%   F is sum of squares
%   XLIN is a vector of [a1 a2 a3...AB], a's are peak amplitudes,
%   AB is linear background
%
%See also NPKFIT, NPKFN

xdata=xdata(:);
ydata=ydata(:);
n=length(pk0.p);
pk=pk0;
pk.p=x(1:n);
pk.w=x(n+1:2*n);
pk.a=ones(1,n);
ispv=isnumeric(pk0.fn);
if ispv
    pk.fn=x(2*n+1:3*n);
end
ydata1=npkfn(pk, xdata, 'fit');
M=cat(2, ydata1{:});
if isbg
    M=[M xdata ones(size(xdata))];
    %A=diag([-ones(1,n) 1 1]);
    %b=[zeros(1,n) inf inf];
else
    %A=-eye(n);
    %b=zeros(1,n);
end
xlin=M\ydata;
%xlin=lsqlin(M, ydata, A, b);
ydata2=M*xlin;
f=ydata2-ydata;
xlin=xlin';
if ~isbg
    xlin=[xlin 0 0];
end

if nargout>1	%calculate the Jacobian
    J=zeros(length(xdata), length(x));
    a=xlin(1:n);
    if ~ispv	%simpler case:
	if length(strmatch(pk.fn,'gauss'))
	    for j=1:n
		J(:,j)=ydata1{j}*a(j)*8*log(2).*(xdata-pk.p(j))/pk.w(j)^2;
		J(:,j+n)=ydata1{j}*a(j)*8*log(2).*(xdata-pk.p(j)).^2/pk.w(j)^3;
	    end
	else	%must be lorenz
	    for j=1:n
		J(:,j)=ydata1{j}.^2*a(j)*8.*(xdata-pk.p(j))/pk.w(j)^2;
		J(:,j+n)=ydata1{j}.^2*a(j)*8.*(xdata-pk.p(j)).^2/pk.w(j)^3;
	    end
	end
    else	%tough case
	pkl=pk;pkl.fn='l';
	pkg=pk;pkg.fn='g';
	yl1=npkfn(pkl, xdata, 'fit');
	yg1=npkfn(pkg, xdata, 'fit');
	for j=1:n
	    J(:,j)=pk.fn(j)*yl1{j}.^2*a(j)*8.*(xdata-pkl.p(j))/pkl.w(j)^2+...
	   (1-pk.fn(j))*yg1{j}*a(j)*8*log(2).*(xdata-pkg.p(j))/pkg.w(j)^2;
	    J(:,j+n)=pk.fn(j)*yl1{j}.^2*a(j)*8.*(xdata-pkl.p(j)).^2/pkl.w(j)^3+...
	   (1-pk.fn(j))*yg1{j}*a(j)*8*log(2).*(xdata-pkg.p(j)).^2/pkg.w(j)^3;
	    J(:,j+2*n)=a(j)*(yl1{j}-yg1{j});
	end
    end
end
