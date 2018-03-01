function idx = fnearbin(x, c, flag)
%FNEARBIN    binary search for indices of elements nearest to the given values
% IDX = FNEARBIN(X, C, [FLAG])
%    vector X must be sorted.
%    optional parameter FLAG can be 'near', 'lo' or 'hi' to restrict to
%    indices of X below or above C
% Example:
%    x = linspace(-4, 5);
%    i = fnearbin(x, [-pi,pi]);

%  $Id: fnearbin.m 26 2007-02-27 22:45:38Z juhas $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if min(size(x)) > 2
    error('X must be a vector')
end
if nargin < 3
    flag = 'near';
end

idx = zeros(size(c));
Nx = length(x);
for i = 1:prod(size(idx))
    lo = 1;
    hi = Nx;
    while x(lo) < c(i) & c(i) < x(hi) & lo < hi-1
        mi = floor((lo+hi)/2);
        if x(mi) < c(i)
            lo = mi;
        else
            hi = mi;
        end
    end
    switch flag
    case 'lo',
        if lo < Nx  &  x(lo+1) == c(i)
            lo = lo + 1;
        elseif ~(x(lo) < c(i))
            lo = NaN;
        end
        idx(i) = lo;
    case 'hi',
        if hi > 1  &  x(hi-1) == c(i)
            hi = hi - 1;
        elseif ~(x(hi) > c(i))
            hi = NaN;
        end
        idx(i) = hi;
    case 'near',
        if c(i) < x(lo)  &  lo > 1  &  c(i)-x(lo-1) < x(lo)-c(i)
            idx(i) = lo - 1;
        elseif c(i) > x(hi) & hi+1 < Nx & c(i)-x(hi) < x(hi+1)-c(i)
            idx(i) = hi + 1;
        elseif c(i)-x(lo) <= x(hi)-c(i)
            idx(i) = lo;
        else
            idx(i) = hi;
        end
    otherwise
        error('invalid FLAG string')
    end
end
