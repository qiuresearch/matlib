function v = dvar( dtgt, dtest, flag )
% DVAR        calculate variance of test versus target distance lists
% V = DVAR(DTGT, DTEST, FLAG)
% V = DVAR(DTGT, RTEST, FLAG)
%   DTEST may be shorter than DTGT, but must not be longer.  Target
%   distances can be also specified via list of coordinates.  When
%   optional FLAG==1, DTEST would be scaled to minimize sum of squares.

if nargin < 3
    flag = 0;
end
if size(dtgt,2) ~= 1
    error('DTGT must be a column vector')
end
if size(dtgt,1) < size(dtest,1)
    error('DTGT may not be shorter than DTEST')
end
% convert coordinates to distances
if size(dtest,2) > 1
    dtest = distmx(dtest, 'c');
end
% make sure dtest is sorted
dtest = sort(dtest);
if length(dtgt) == length(dtest)
    dtgt1 = dtgt;
else
    dtgt1 = [];
    for i = 1:length(dtest)
        j = fnear(dtgt, dtest(i));
        dtgt1(end+1,1) = dtgt(j);
        dtgt(j) = [];
    end
end

if flag
    dtest = (dtest\dtgt1)*dtest;
end
v = mean((dtest-dtgt1).^2);
