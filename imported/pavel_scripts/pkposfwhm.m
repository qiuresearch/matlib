function [pos, fwhm] = pkposfwhm(x, y, xbg, ybg)
% [pos, fwhm] = pkposfwhm(x, y, xbg, ybg)

c = ybg/xbg;
idx = find(x < 4);
xc = x(idx);
yc = y(idx);
[ymx, imax] = max(yc);
pos = xc(imax);
yhalf = (yc(imax) + pos * c) / 2;

xlohi = xaty(yhalf, xc, yc);
fwhm = diff(xlohi);

cla;
plot(xc, yc, '-',  pos, ymx, 'rx',  xc, c*xc, 'k--')
hold on
plot(xlohi, [yhalf, yhalf], 'k-')
xlim(0, 5)
