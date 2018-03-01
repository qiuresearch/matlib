function hout = plcfg( xyz, varargin )
% PLCFG       plot rmca atom configuration
% H = PLCFG(XYZ[, STYLE])  or  H = PLCFG(X, Y, Z[, STYLE])

c_style = '.';

if size(xyz, 2) == 3
    x = xyz(:,1);
    y = xyz(:,2);
    z = xyz(:,3);
else
    x = xyz;
    y = varargin{1};
    z = varargin{2};
    % pop used arguments
    varargin(1:2) = [];
end
if length(varargin) > 0
    c_style = varargin{1};
    varargin(1) = [];
end
if length(varargin) > 0
    error('too many arguments');
end

subplot(211);
mx = -max(x);
mz = -min(z);
h(:,1) = plot(y, x+mx, c_style, y, z+mz, c_style);
axis equal;
hl = line('XData', xlim, 'YData', [0 0], 'Color', 'k', 'LineStyle', '--');

subplot(212);
h(end+1,1) = plot3(x,y,z,c_style);
axis equal;

% h = plot3(x, y, z, c_style{:});
if nargout>0
    hout = h;
end
