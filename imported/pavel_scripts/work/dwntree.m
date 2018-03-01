function Hstruct = dwntree(GenMaleFemaleChildRwPrince)
% DWNTREE     make a nice plot of family tree for GA minimization
% [Hstruct] = DWNTREE(GenMaleFemaleChildRwPrince)

if size(GenMaleFemaleChildRwPrince, 2) ~= 6
    error('GenMaleFemaleChildRwPrince must have 6 columns');
end

G = GenMaleFemaleChildRwPrince(:,1).';
M = GenMaleFemaleChildRwPrince(:,2).';
F = GenMaleFemaleChildRwPrince(:,3).';
C = GenMaleFemaleChildRwPrince(:,4).';
Rw = GenMaleFemaleChildRwPrince(:,5).';
Prince = (GenMaleFemaleChildRwPrince(:,6) ~= 0).';
N = length(G);
n = 1:N;

pop = [min([M, F, C]), max([M, F, C])];
cla; hold on;
set( gca, 'YDir', 'Reverse', 'Ylim', [-1,  N+1], ...
    'Xlim',  [pop(1)-0.5, pop(2)+0.5], 'FontSize', 8 );
% plot the kids first:
hchild = plot(C(Prince~=0), n(Prince~=0), 'r*', C(~Prince), n(~Prince), 'ro');
sRw = num2str(Rw(:), '%.3f');
sRw = [char(' '*ones(N,2)), sRw];
hRw = text(C, n, sRw, 'FontSize', 8, 'VerticalAlignment', 'middle');
% show matings next
hmate = plot( ...
    [M;     M;     C;     C;     C;     F;     F], ...
    [n-1;   n-.50; n-.50; n;     n-.50; n-.50; n-1], '-' );
% finally, show child-parents links
nchild = [];
pchild = [];
for i = n
    nfirst = i;
    nmax = find(C(i+1:end) == C(i)) + i;
    if isempty(nmax)
        nmax = N;
    else
        nmax = nmax(1) - 1;
    end
    [ignore,nlast] = find([M(i+1:nmax);F(i+1:nmax)] == C(i));
    if isempty(nlast)
        nlast = nfirst;
    else
        nlast=max(nlast) +i - 1;
    end
    nchild = [nchild,  [nfirst; nlast] ];
    pchild = [pchild,  [C(i); C(i)] ];
end
hlink = plot(pchild, nchild, 'k:');
ytl = num2str([0;G.']);
set(gca, 'YTick', [0 n], 'YTickLabel', ytl, 'XMinorTick', 'on')
xlabel('Person', 'FontSize', 10)
ylabel('Generation', 'FontSize', 10)
title('', 'FontSize', 10)

if nargout
    Hstruct = struct( 'child', hchild, 'mate', hmate, 'link', hlink, ...
        'Rw', hRw);
end
