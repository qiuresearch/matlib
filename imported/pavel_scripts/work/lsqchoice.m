function [xs, idx] = lsqchoice(xpool, xsel)
% LSQCHOICE    choose elements from XPOOL which minimize lsq difference
%    with  XSEL
% XS = LSQCHOICE(XPOOL,XSEL)  or  [XS,IDX] = LSQCHOICE(XPOOL,XSEL)
%
% See also LSQORDER

if min(size(xpool)) > 1
    error('XPOOL must be a vector');
elseif min(size(xsel)) > 1
    error('XSEL must be a vector');
elseif length(xsel) > length(xpool)
    error('XSEL cannot be longer than XPOOL');
end
xs = zeros(size(xsel));
idx = zeros(size(xsel));
xpool = xpool(:);
xsel = xsel(:);

Nsel = length(xsel);
Npool = length(xpool);
[xpool1, sortIdx] = sort(xpool);
xp1idx = [xpool1, sortIdx];
xsidx = zeros(Nsel,2);
for i = 1:Nsel
    j = fnearbin(xp1idx(:,1), xsel(i));
    xsidx(i,:) = xp1idx(j,:);
    xp1idx(j,:) = [];
end

while 1
    [xs2, idx2] = lsqorder(xsidx(:,1), xsel);
    if ~isequal(xs2, xsidx(:,1))
        xsidx = xsidx(idx2,:);
    else
        break
    end
    % now try to find if anything in the pool is nearer
    improved = 0;
    if ~isempty(xp1idx)
        for i = 1:Nsel
            j = fnearbin(xp1idx(:,1), xsel(i));
            if abs(xp1idx(j,1)-xsel(i)) < abs(xsidx(i,1)-xsel(i))
                improved = 1
                xidxstore = xsidx(i,:);
                xsidx(i,:) = xp1idx(j,:);
                xp1idx(j,:) = [];
                % return storage to the right place
                k = fnearbin(xp1idx(:,1), xidxstore(1,1), 'lo');
                if isnan(k);
                    k = 0;
                end
                xp1idx = [xp1idx(1:k,:); xidxstore; xp1idx(k+1:end,:)];
            end
        end
    end
    if ~improved
        break
    end
end

xs(:) = xsidx(:,1);
idx(:) = xsidx(:,2);
