function HO = dcubes(n, zsep)
% DCUBES(N, ZSEP)  plot several in-scale cubes with a=1

if nargin < 2
    zsep = 0.6;
end
if nargin < 1
    n = 4;
end

xc = [ 0 1 1 0 0 NaN 0 1 1 0 0 NaN 0 0 NaN 1 1 NaN 1 1 NaN 0 0 ];
yc = [ 0 0 1 1 0 NaN 0 0 1 1 0 NaN 0 0 NaN 0 0 NaN 1 1 NaN 1 1 ];
zc = [ 0 0 0 0 0 NaN 1 1 1 1 1 NaN 0 1 NaN 0 1 NaN 0 1 NaN 0 1 ];

hp = [];
for dz = (0:n-1) * ( 1 + zsep );
    hp = [hp ; plot3( xc, yc, zc+dz, 'k')];
    hold on;
end
axis equal
view(22, 10)
axis off
set(gca, 'Position', [0.05 0.025 0.3 0.95])
set(hp, 'LineWidth', 0.25)
if nargout > 0
    HO = hp;
end
