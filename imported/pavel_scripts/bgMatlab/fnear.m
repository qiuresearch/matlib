function j=fnear(x, c, flag)
%FNEAR       find indices of elements nearest to the given values
% IDX = FNEAR(X, C, [FLAG])
%    where optional FLAG can be 'near', 'lo' or 'hi' to restrict to
%    indices of X below or above C
% Example:
%    x = linspace(-4, 5);
%    i = fnear(x, [-pi,pi]);

%  $Id: fnear.m 26 2007-02-27 22:45:38Z juhas $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 3
    flag = 'near';
end
    
j = zeros(size(c));
switch flag
case 'near'
    for i = 1:prod(size(j))
	[ignore, j(i)] = min( abs(x-c(i)) );
    end
case 'lo'
    for i = 1:prod(size(j))
	k1 = find(x <= c(i));
	[ignore, k2] = min(c(i) - x(k1));
	if isempty(k2)
	    j(i) = NaN;
	else
	    j(i) = k1(k2);
	end
    end
case 'hi'
    for i = 1:prod(size(j))
	k1 = find(x >= c(i));
	[ignore, k2] = min(x(k1) - c(i));
	if isempty(k2)
	    j(i) = NaN;
	else
	    j(i) = k1(k2);
	end
    end
otherwise
    error('invalid FLAG string')
end
