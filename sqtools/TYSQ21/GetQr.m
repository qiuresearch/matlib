function data = GetQr(r,a,b,Z1,Z2,c1,c2,d1,d2)
% data = GetQr(r,a,b,Z1,Z2,c1,c2,d1,d2)

E=exp(1);
data = d1*E.^(-r*Z1) + d2*E.^(-r*Z2) + c1 * ( -E.^(-Z1) + E.^(-r*Z1)) + ...
    c2 * ( -E.^(-Z2) + E.^(-r*Z2)) + b * ( -1 + r) + 1/2 * a* (-1 + r.^2);