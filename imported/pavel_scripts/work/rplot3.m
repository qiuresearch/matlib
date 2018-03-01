function hout = rplot3(r, varargin)
% RPLOT3      Plot points from Nx3 matrix
%    RPLOT3(R,...), splits the first argument to X,Y,Z and passes
%    all other arguments to PLOT3

if nargin <= 1
    varargin = {'*'};
end
h = plot3(r(:,1), r(:,2), r(:,3), varargin{:});
if ~ishold
    axis equal off
end
if nargout > 0
    hout = h;
end
