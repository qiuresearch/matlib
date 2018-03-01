function varargout = zoomin(factor, varargin)

x=1;
y=1;
parse_varargin(varargin);

x_lim = get(gca, 'xlim');
y_lim = get(gca, 'ylim');

if strcmp(get(gca, 'XScale'), 'log')
   x_lim = log(x_lim);
   x_lim = (x_lim(1)+x_lim(2))/2 + [-0.5,0.5]*(x_lim(2)-x_lim(1))* (1-factor);
   x_lim = exp(x_lim);
else   
   x_lim = (x_lim(1)+x_lim(2))/2 + [-0.5,0.5]*(x_lim(2)-x_lim(1))* (1-factor);
end

if strcmp(get(gca, 'YScale'), 'log')
   y_lim = log(y_lim);
   y_lim = (y_lim(1)+y_lim(2))/2 + [-0.5,0.5]*(y_lim(2)-y_lim(1))* (1-factor);
   y_lim = exp(y_lim);
else
y_lim = (y_lim(1)+y_lim(2))/2 + [-0.5,0.5]*(y_lim(2)-y_lim(1))*(1-factor);
end

if (x == 1)
   xlim(x_lim);
end
if (y == 1)
   ylim(y_lim);
end
