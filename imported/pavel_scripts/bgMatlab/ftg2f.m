function F = ftg2f( r, G, Q )
% FTG2F       calculates F(Q) from G(r) via Fourier transformation
%   usage:  F = FTG2F(r, G, Q)

F = zeros(size(Q));

% trapezoid numerical integration:
% Int = f1*(x2-x1)/2 + f2*(x3-x1)/2 + f3*(x4-x2)/2 + ... fN*(x(N)-x(N-1))/2
dr = zeros(size(r));
dr(1) = r(2) - r(1);
dr(2:end-1) = r(3:end) - r(1:end-2);
dr(end) = r(end) - r(end-1);
dr = dr/2;

% F = int G(r)*sin(Qr) dr
for i = 1:length(F)
    F(i) = sum( G .* sin(Q(i)*r) .* dr );
end
