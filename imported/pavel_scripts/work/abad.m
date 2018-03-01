function abadness = abad(rnew, rcluster, dfree)
% ABAD    calculate badness of new position with respect to existing cluster
% ABADNESS = ABAD(RNEW, RCLUSTER, DFREE)    calculates sum of squares of new
%   pair distances with respect to the nearest available distances,
% where
%   RNEW is Mx3 matrix of new positions to check
%   RCLUSTER in Nx3 matrix of coordinates of reference cluster
%   DFREE is a vector of available distances, DFREE must be at least as long
%      as RCLUSTER

% check
if size(rnew,2) ~= size(rcluster,2)
    error('RNEW and RCLUSTER must have the same number of columns')
elseif min(size(dfree)) > 1
    error('DFREE should be vector')
elseif length(dfree) < size(rcluster,1)
    error('DFREE is shorter than number of cluster atoms')
end

abadness = zeros(size(rnew,1),1);
if isempty(rcluster)
    return
end

Dnc = distmx2(rnew, rcluster);
for idxnew = 1:size(rnew,1)
    dnew = Dnc(idxnew,:);
    dtgt = lsqchoice(dfree, dnew);
    abadness(idxnew) = sum((dnew-dtgt).^2);
end
