function NbondMx = nbondgrid(d, rxy, dmngrid)
% NBONDGRID   calculate number of bonds consistent with distance table on grid
% NBONDMX = NBONDGRID(D, RXY, DMNGRID)
%   D    is a sorted table of distances
%   RXY  is Nx2 matrix of existing points
%   DMNGRID    is a 5-element vector which defines plane grid,
%              DMNGRID = [Delta, Mmin, Mmax, Nmin, Nmax]

% check arguments {{{
d = d(:);
if any(diff(d) < 0)
    error('D must be sorted vector of distances');
end
if size(rxy,2) ~= 2
    error('RXY must be Nx2 matrix')
end
N = size(rxy,1);
if ~(dmngrid(1) > 0)
    error('DMNGRID(1) must be positive')
end
if any(dmngrid(2:5) ~= round(dmngrid(2:5)))
    error('DMNGRID(2:5) must be integer')
end
delta = dmngrid(1);
gm = dmngrid(2):dmngrid(3);
gn = dmngrid(4):dmngrid(5);
if length(gm)*length(gn) == 0
    error('plane grid is empty')
end
% }}}

% calculate grid coordinates of existing points:
m = round(rxy(:,1)/delta);
n = round(rxy(:,2)/delta);

gxy = delta*[m, n];
gdxy = tril(distmx(gxy), -1);
gdxy = sort(gdxy(gdxy(:)>0));

% ineficient:
for b = gdxy'
    i = fnear(d, b);
    if abs(d(i)-b) < delta
	d(i) = [];
    end
end

NbondMx = zeros(length(gm), length(gn));
for i = 1:length(gm)
    for j = 1:length(gn)
	gpt = [gm(i), gn(j)]*delta;
	gpt = gpt(ones(N,1),:);
	bpt = sqrt(sum((gpt-gxy).^2,2));
	dpt = d;
	for b = bpt'
	    k = find(dpt >= b-sqrt(.5)*delta & dpt < b+delta*sqrt(.5));
	    if ~isempty(k)
		NbondMx(i,j) = NbondMx(i,j)+1;
		dpt(k(1)) = [];
	    end
	end
    end
end

clf; 
imagesc(delta*gm, delta*gn, NbondMx'); hold on; plot(rxy(:,1),rxy(:,2),'k*');

% vim: fdm=marker
