function [wdh,pcnt,pw] = wdhist(rf, delta, ofmt)
% WDHIST(RF) calculate weighed distance histogram
% [WDH,PCNT,PW] = WDHIST(RF, DELTA=1E-8, OFMT='')
%   WDH   is 2-column matrix of distance and weighed counts
%   PCNT  is pair type count matrix
%   PW    is sorted pair weight vector
%   RF    is Nx4 matrix of coordinates and scattering factors
%   DELTA is distance window size, use default value when empty
%   OFMT  output format for WDH, default is '', when 'dccheck'
%         wdhist will print out inputs for dccheck program

% defaults
c_delta = 1e-8;
% process arguments
if nargin < 2 | isempty(delta)
    delta = c_delta;
end
if size(rf,2) ~= 4
    error('RF must be Nx4 matrix');
end
if nargin < 3
    ofmt = '';
end

N = size(rf,1);
% calculate D
r = rf(:,1:3);
D = distmx(r);

% calculate scattering factor weights
sf = rf(:,4);
W = sf*sf' / mean(sf)^2;
% Ntype - number of atom types
Ntype = 0;
% usf unique scattering factor
usf = unique(sort(sf));
Ntype = length(usf);
sftype = zeros(size(sf));
for i = 1:Ntype
    sftype(sf == usf(i)) = i;
end
pair2idx = diag(1:Ntype);
pw(1:Ntype) = usf.^2;
idx2pair = [(1:Ntype)', (1:Ntype)'];
Npairtype = Ntype;
for i = 1:Ntype-1
    for j = 1:Ntype-i
        Npairtype = Npairtype + 1;
        pair2idx(j,j+i) = Npairtype;
        pair2idx(j+i,j) = Npairtype;
        idx2pair(Npairtype,:) = [j, j+i];
        pw(Npairtype) = usf(j)*usf(j+i);
    end
end

% now calculate the histogram
p1 = sftype(:,ones(N,1)); p2 = p1';
p12 = p1(:) + (p2(:)-1)*Ntype;
P = pair2idx(p12);
DWP = sortrows([ D(:), W(:), P(:) ], 1);
wdh = [-Inf, 0];
pcnt = [];
for dwp = DWP'
    if dwp(1)-wdh(end,1) > delta
        wdh(end+1,:) = [dwp(1), 0.0];
        pcnt(end+1,:) = zeros(1,Npairtype);
    end
    wdh(end,2) = wdh(end,2) + dwp(2);
    pcnt(end,dwp(3)) = pcnt(end,dwp(3)) + 1;
end
wdh(1,:) = [];
wdh(:,2) = wdh(:,2) / N;
pw = pw/(mean(sf)^2) / N;

% sort by pair weights
[pw,idx] = sort(pw);
pcnt = pcnt(:,idx);

% optional printouts
switch ofmt
case '',
case 'dccheck',
    fprintf('  amounts=%.8g%s \\\n', wdh(1,2), sprintf(',%.8g', wdh(2:end,2)));
    fprintf('  coins=%.8g%s \\\n', pw(1), sprintf(',%.8g', pw(2:end)));
    c = sum(pcnt,1);
    fprintf('  ccnts=%i%s\n', c(1), sprintf(',%i', c(2:end)));
otherwise,
    error('invalid OFMT value');
end
