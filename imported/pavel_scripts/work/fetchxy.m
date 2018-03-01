function [x,y]=fetchxy(lineidx)
% FETCHXY     get x and y data from a line object
% [X,Y]=FETCHXY     select line in gca
% [X,Y]=FETCHXY(1)  get data from the last line in gca
%
% See also GETH.

if nargin==0
    figure(gcf);
    hl=geth('line');
else
    hl=geth('line', lineidx);
end
x = get(hl, 'XData').';
y = get(hl, 'YData').';
