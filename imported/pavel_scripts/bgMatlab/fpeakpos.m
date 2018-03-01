function [xpk, ypk] = fpeakpos(x, y, xsep, ydrop, nspfit)
%FPEAKPOS    Find peak positions
%  [XPK,YPK] = FPEAKPOS(X, Y)  finds coordinates of all local maxima
%
%  [XPK,YPK] = FPEAKPOS(X, Y, XSEP)  find local maxima, with
%       minimum separation XSEP
%
%  [XPK,YPK] = FPEAKPOS(X, Y, XSEP, YDROP)  find local maxima, with
%       minimum separation XSEP, which are higher than YDROP with
%       respect to peak feet
%
%  [XPK,YPK] = FPEAKPOS(X, Y, XSEP, YDROP, NSPFIT)  find local maxima,
%       as above and refine their positions by fitting cubic spline to
%       NSPFIT neighborhood points
%
%  See also FLMAX, MAX, MIN.

%  $Id: fpeakpos.m 31 2007-03-12 21:48:57Z juhas $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% default argument values
if nargin < 3; xsep = 0; end
if nargin < 4; ydrop = 0; end
if nargin < 5; nspfit = 0; end

% argument sanity check
if min(size(x)) > 2
    error('X must be a vector')
end
if length(x) > 3 & min(diff(x)) <= 0
    error('X values must be increasing')
end
if length(x) ~= length(y)
    error('size of Y must agree with the length of X')
end
if min(size(xsep)) ~= 1
    error('XSEP must be a scalar.');
end
if min(size(ydrop)) ~= 1
    error('YDROP must be a scalar.');
end
if min(size(nspfit)) ~= 1 | floor(nspfit) ~= nspfit
    error('NSPFIT must be integer scalar.');
end

xc = x(:); yc = y(:); ic = (1:length(xc))';
xpk = []; ypk = [];

% difference matrix with original indices
dyi = [diff(yc), ic(1:end-1)];
% reduce constant values
dyi(dyi(:,1) == 0,:) = [];
nd = size(dyi,1);

% find extremes
ixtrm = find(dyi(1:end-1,1).*dyi(2:end,1) < 0);
ixtrm = ceil((dyi(ixtrm,2) + dyi(ixtrm+1,2))/2);
% add minima on left and right sides:
if y(ixtrm(1)) > y(ixtrm(2));
    ixtrm = [1; ixtrm];
end
if y(ixtrm(end)) > y(ixtrm(end-1));
    ixtrm = [ixtrm; ic(end)];
end

% [xpk, ypk, ipk, xlf, ylf, ilf, xrf, yrf, irf]  peak and its feet
ipk = ixtrm(2:2:end);  ilf = ixtrm(1:2:end-2);  irf = ixtrm(3:2:end);
xyiplr = [  xc(ipk), yc(ipk), ic(ipk), ...
            xc(ilf), yc(ilf), ic(ilf), ...
            xc(irf), yc(irf), ic(irf) ];

% apply XSEP
% reverse order by ydrop
yd = min([xyiplr(:,[2,2]) - xyiplr(:,[5,8])], [], 2);
[ignore,order] = sort(-yd);
for i = order(:)'
    if isnan(xyiplr(i,1)); continue; end
    for jlo = i-1:-1:1
        if isnan(xyiplr(jlo,1)) | xyiplr(i,1) - xyiplr(jlo,1) > xsep;
            break;
        end
        xyiplr(jlo,1) = NaN;
    end
    for jhi = i+1:+1:size(xyiplr,1)
        if isnan(xyiplr(jhi,1)) | xyiplr(jhi,1) - xyiplr(i,1) > xsep;
            break;
        end
        xyiplr(jhi,1) = NaN;
    end
end
xyiplr(isnan(xyiplr(:,1)),:) = [];

% apply YDROP
yd = min([xyiplr(:,[2,2]) - xyiplr(:,[5,8])], [], 2);
xyiplr(yd < ydrop,:) = [];

xpk = xyiplr(:,1); ypk = xyiplr(:,2);

% apply cubic spline fit
if nspfit > 2
    xpb = [];
    ypb = [];
    il = max(xyiplr(:,3) - floor(nspfit/2), 1);
    for ipk = 1:size(xyiplr,1)
        isp = il(ipk) + (0:(nspfit-1));
        pp = spline(x(isp), y(isp));
        [ypk(ipk), xpk(ipk)] = fnmin(fncmb(pp, -1));
        ypk(ipk) = -ypk(ipk);
    end
end
