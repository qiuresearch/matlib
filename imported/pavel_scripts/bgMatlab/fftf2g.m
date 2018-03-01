function [rf, gf] = fftf2g(Q, F, r0)
% FFTF2G      calculates G(r) from F(Q) via inverse Fourier transformation
% usage:
% [R, G] = FTF2G(Q, F)  here a regular R-grid is generated with the same
%   number of points as in the Q vector extrapolated to 0 and padded to the
%   next power of 2.  The maximum R equals pi/Qstep, where Qstep is the
%   average spacing in the Q vector.
%
% [R, G] = FTF2G(Q, F, R)  calculates G over user specified grid. 
% The Q vector may be padded by extra zeros to achieve the same or
% denser sampling in the Fourier image as in R.  The Fourier image
% is then interpolated to R.  The maximum element in R must be smaller
% or equal to pi/Qstep.

if length(Q) > 1
    Qstep = (Q(end) - Q(1)) / (length(Q) - 1);
else
    Qstep = Q(1);
end

if nargin > 2
    r0set = 1;
    N = 1;
    if length(r0) > 1
        r0step = (max(r0) - min(r0)) / (length(r0) - 1);
        N = ceil(max(r0) / r0step);
    end
else
    r0set = 0;
    N = round(Q(end)/Qstep);
end

N1 = pow2(ceil(log2(N)));
N2 = 2*N1;
q2 = (0:(N2 - 1)) * Qstep;
f2 = zeros(size(q2));
mid = find(Q(1) <= q2 & q2 <= Q(end));
f2(mid) = interp1(Q, F, q2(mid), 'linear');
lo = 1:(mid(1) - 1);
f2(lo) = interp1([0, Q(1)], [0, F(1)], q2(lo));

cg2 = ifft(f2) * 2/pi * q2(end);
g2 = imag(cg2);
rstep = 2*pi / q2(end);
rmax = pi/Qstep;
r3 = 0:rstep:rmax;
g3 = g2(1:length(r3));

if r0set
    rf = r0;
    if r3(end) < rmax
        r3(end+1) = rmax;
        g3(end+1) = 0;
    end
    gf = interp1(r3, g3, r0);
else
    rf = r3;
    gf = g3;
end
