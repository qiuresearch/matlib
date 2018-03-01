function [Xmax, Ymax] = flmax(x, y, low, high, dim, nspfit)
%FLMAX       Find local maximum.
%  [XMAX,YMAX] = FLMAX(X, Y, LOW, HIGH)  returns the position and value
%  of a local maximum of the [X,Y] curve, where LOW <= X <= HIGH
%  X, Y may be vectors of the same size, Y can also be matrix with
%  the number of rows equal to the length of X
%
%  [XMAX,YMAX] = FLMAX(X, Y, LOW, HIGH, DIM)  operates along the dimension
%  DIM.  In requires LENGTH(X)==SIZE(Y,DIM)
%
%  [XMAX,YMAX] = FLMAX(X, Y, LOW, HIGH, [], NSPFIT)  will refine positions
%  of local maxima by fitting cubic spline to NSPFIT neighborhood points.
%  This is only available when X and Y are vectors.
%
%  When complex, the magnitude MAX(ABS(X)) is used, and the angle
%  ANGLE(X) is ignored.  NaN's are ignored when computing the maximum.
%
%  See also FLMIN, MAX, MIN.

%  $Id: flmax.m 32 2007-03-12 21:49:36Z juhas $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 5 | isempty(dim)
    if size(y,1) == 1
	dim = 2;
    else
	dim = 1;
    end
end
if nargin < 6; nspfit = 0; end
if min(size(x)) > 2
    error('X must be a vector')
end
if length(x) ~= size(y,dim)
    error('size of Y must agree with the length of X')
end
if min(size(low)) ~= 1
    error('LOW must be a scalar.');
end
if min(size(high)) ~= 1
    error('HIGH must be a scalar.');
end
if min(size(dim)) ~= 1
    error('DIM must be a scalar.');
end
if nspfit > 0 & (min(size(x)) > 1 | min(size(y)) > 1)
    error('NSPFIT requires X and Y to be vectors');
end

idx = find(low<=x &  x<=high);
% build N-dimensional index NDIDX to get the subarray of Y along DIM
for i = 1:ndims(y)
    ndidx{i} = 1:size(y,i);
end
ndidx{dim} = idx;

[Ymax,idxIdx] = max(y(ndidx{:}), [], dim);
% make sure Xmax has the same size as Ymax
Xmax = zeros(size(idxIdx));
Xmax(:) = x(idx(idxIdx));

% apply cubic spline fit - fix to make it work with matrices
if nspfit > 2
    ipk = idx(idxIdx);
    il = max(ipk - floor(nspfit/2), 1);
    ih = min(il + nspfit - 1, length(x));
    pp = spline(x(il:ih), y(il:ih));
    [Ymax, Xmax] = fnmin(fncmb(pp, -1));
    Ymax = -Ymax;
end
