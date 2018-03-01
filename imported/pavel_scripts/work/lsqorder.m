function [xord, iord] = lsqorder(x, y)
% LSQORDER    order 2 list to minimize their lsq difference
% XORD = LSQORDER(X,Y)  or  [XORD,IORD] = LSQORDER(X,Y)
%
% See also LSQCHOICE

% lsq difference is in local, possibly global minimum when both lists are
% sorted:
[xs, xidx] = sort(x);
[ys, yidx] = sort(y);
iord = zeros(size(xs));
iord(yidx) = xidx;
xord = x(iord);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% original code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% N = length(x);
% idx = 1:N;
% xs = x;
% improved = 1;
% 
% while improved
%     improved = 0;
%     for i = 1:N
%         [e,k] = min( (xs(i+1:end)-xs(i)) .* (y(i+1:end)-y(i)) );
%         while e<0
%             k = k+i;
%             improved = 1;
%             xs([i, k]) = xs([k, i]);
%             idx([i, k]) = idx([k, i]);
%             [e,k] = min( (xs(i+1:end)-xs(i)) .* (y(i+1:end)-y(i)) );
%         end
%     end
% end
