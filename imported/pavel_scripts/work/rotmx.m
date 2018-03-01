function R = rotmx(a1, a2, a3)
% ROTMX    matrix for rotation by angle OMEGA around specified axis
% R = ROTMX(AX, OMEGA)  rotation axis is specified as a vector
% R = ROTMX(PHI, THETA, OMEGA)  axis is specified in spherical coordinates,
%     Angles PHI, THETA, OMEGA are in radians.

if nargin == 2
    if prod(size((a1))) ~= 3
        error('first argument must be a 3-element vector')
    end
    ax = a1/norm(a1);
    omega = a2;
elseif nargin == 3
    phi = a1;
    theta = a2;
    omega = a3;
    ax = [ [cos(phi), sin(phi)] * sin(theta), cos(theta) ];
else
    error('ROTMX requires 2 or 3 arguments')
end

e0 = cos(omega/2);
e1 = sin(omega/2) * ax(1);
e2 = sin(omega/2) * ax(2);
e3 = sin(omega/2) * ax(3);

R = [ e0^2+e1^2-e2^2-e3^2,     2*(e1*e2-e0*e3),        2*(e1*e3+e0*e2);
      2*(e1*e2+e0*e3),         e0^2-e1^2+e2^2-e3^2,    2*(e2*e3-e0*e1);
      2*(e1*e3-e0*e2),         2*(e2*e3+e0*e1),        e0^2-e1^2-e2^2+e3^2 ];
