function [y,x]=fitexp(x,xdata,ydata)
%FITEXP    FITEXP(C, X) = exp( -X/C(1) ) * C(2) + C(3)
%         [Y,C] = FITEXP(C, X, Y), calculates the linear
%         coefficients C(2:3)

y=zeros(size(xdata));
y0=exp(-xdata/x(1));
if nargin < 3
    y = x(2)*y0 + x(3);
else
    %calculate linear coefficients
    x=x(:);
    M=[y0(:) ones(prod(size(y0)),1)];
    x(2:3)=M\ydata(:);
    y(:)=M*x(2:3);
end
