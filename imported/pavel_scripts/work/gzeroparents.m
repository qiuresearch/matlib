function gzp = gzeroparents(MaleFemaleChild)
% GZEROPARENTS  find generation 0 parents in the family tree
% usage: GZP = GZEROPARENTS(GenMaleFemaleChildRwPrince)  or
%        GZP = GZEROPARENTS(MaleFemaleChild)

if size(MaleFemaleChild,2) == 6
    disp('using columns 2:4 from the input matrix')
    MaleFemaleChild = MaleFemaleChild(:,2:4);
elseif size(MaleFemaleChild,2) ~= 3
    error('number of columns in the input matrix must be 3 or 6')
end

population = max(MaleFemaleChild(:)) + 1;
% index of ischild is larger by one than the member index
ischild = zeros(1,population+1);
gzp = zeros(1,population+1);
for g = 1:size(MaleFemaleChild,1)
    if all(ischild)
	break
    end
    m = MaleFemaleChild(g,1);
    f = MaleFemaleChild(g,2);
    c = MaleFemaleChild(g,3);
    if ~ischild(m+1)
	gzp(m+1) = 1;
    end
    if ~ischild(f+1)
	gzp(f+1) = 1;
    end
    ischild(c+1) = 1;
end

gzp = find(gzp ~= 0) - 1;
