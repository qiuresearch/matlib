function varargout = findbonds(r, max_blen)
% FINDBONDS   find bond pairs and return vectors suitable for plotting
%    RB = FINDBONDS(R, MAX_BLEN)  where R=[X(:) Y(:) Z(:)]
%    [XB, YB, ZB] = FINDBONDS(R, MAX_BLEN);

rdim = size(r, 2);
dm = distmx(r);
[ib,jb] = find(dm < max_blen);
kb = find(ib<jb);
ib = ib(kb); jb = jb(kb);
rb = zeros(3*length(ib), rdim);

for n = 1:rdim
    xbn = ones(3,length(ib))*NaN;
    xbn(1:3:end) = r(ib,n);
    xbn(2:3:end) = r(jb,n);
    rb(:,n) = xbn(:);
end

if nargout == rdim
    for n = 1:rdim
	varargout{n} = rb(:,n);
    end
else
    varargout{1} = rb;
end
