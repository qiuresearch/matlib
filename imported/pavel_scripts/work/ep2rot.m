function R = ep2rot(ep)
% EP2ROT   calculate rotation matrix from Euler parameters
% R = EP2ROT(EP)  EP may be a 3 or 4 element vector

if length(ep) == 3
    ep = [ sqrt(1 - sum(ep.^2)), ep ];
end
if ~isreal(ep) | length(ep) ~= 4 | abs(sum(ep.^2) - 1) > 1e-12
    error('Invalid Euler parameters')
end

e0 = ep(1);
e1 = ep(2);
e2 = ep(3);
e3 = ep(4);

R = [ e0^2+e1^2-e2^2-e3^2,     2*(e1*e2-e0*e3),        2*(e1*e3+e0*e2);
      2*(e1*e2+e0*e3),         e0^2-e1^2+e2^2-e3^2,    2*(e2*e3-e0*e1);
      2*(e1*e3-e0*e2),         2*(e2*e3+e0*e1),        e0^2-e1^2-e2^2+e3^2 ];
