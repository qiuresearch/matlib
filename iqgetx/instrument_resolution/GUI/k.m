function [] = k(varargin)
x = 1:0.1:2;
y = ones(1,length(x));
for i = 1:length(x);
    y(i) = 4*x(i)+19;
end
plot(x,y)