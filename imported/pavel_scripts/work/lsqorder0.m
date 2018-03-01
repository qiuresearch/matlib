function [xord, iord] = lsqorder0(x, y)
% LSQORDER0    order 2 list to minimize their lsq difference
% XORD = LSQORDER0(X,Y)  or  [XORD,IORD] = LSQORDER0(X,Y)
%   this version is using old, slow algorithm
%
% See also LSQCHOICE

N = length(x);
iord = 1:N;
xord = x;
improved = 1;

while improved
    improved = 0;
    for i = 1:N
        [e,k] = min( (xord(i+1:end)-xord(i)) .* (y(i+1:end)-y(i)) );
        while e<0
            k = k+i;
            improved = 1;
            xord([i, k]) = xord([k, i]);
            iord([i, k]) = iord([k, i]);
            [e,k] = min( (xord(i+1:end)-xord(i)) .* (y(i+1:end)-y(i)) );
        end
    end
end
