function [y,x]=ftmp(x,xdata,ydata)
y=zeros(size(xdata));
x=x(:);
y0=exp(-xdata/x(1));
M=[y0(:) ones(prod(size(y0)),1)];
x(2:3)=M\ydata(:);
y(:)=M*x(2:3);
