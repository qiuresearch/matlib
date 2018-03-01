clf
x0 = linspace(-2*pi, 2*pi);
ys0 = sin(x0);
yc0 = cos(x0);
h = plot(x0, ys0, x0, yc0);
axis equal
axis(axis)
% return
set(h, 'EraseMode', 'xor')
for fi=(0:2:360)*pi/180
    R = [ cos(fi)  -sin(fi)
          sin(fi)  cos(fi) ];
    xys = R * [x0;ys0];
    xyc = R * [x0;yc0];
    set(h(1), 'XData', xys(1,:), 'YData', xys(2,:));
    set(h(2), 'XData', xyc(1,:), 'YData', xyc(2,:));
    drawnow;
end
% endDSfqewr
