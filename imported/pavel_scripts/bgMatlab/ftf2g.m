function G = ftf2g( Q, F, r )
% FTF2G       calculates G(r) from F(Q) via inverse Fourier transformation
%   usage:  G = FTF2G(Q, F, r)

G = zeros(size(r));

% trapezoid numerical integration:
% Int = f1*(x2-x1)/2 + f2*(x3-x1)/2 + f3*(x4-x2)/2 + ... fN*(x(N)-x(N-1))/2
dQ = zeros(size(Q));
dQ(1) = Q(2) - Q(1);
dQ(2:end-1) = Q(3:end) - Q(1:end-2);
dQ(end) = Q(end) - Q(end-1);
dQ = dQ/2;

% G = 2/pi * int F(Q)*sin(Qr) dQ
for i = 1:length(r)
    G(i) = 2/pi * sum( F .* sin(Q*r(i)) .* dQ );
end
