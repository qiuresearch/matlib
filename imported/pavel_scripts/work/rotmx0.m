function R = rotmx0(a1, a2, a3)
% ROTMX0   matrix for rotation by angle OMEGA around specified axis
% R = ROTMX(AX, OMEGA)  rotation axis is specified as a vector
% R = ROTMX(PHI, THETA, OMEGA)  axis is specified in spherical coordinates,
%     Angles PHI, THETA, OMEGA are in radians.

if nargin == 2
    if prod(size((a1))) ~= 3
        error('first argument must be a 3-element vector')
    end
    ax = a1/norm(a1);
    phi = atan2(ax(2), ax(1));
    theta = acos(ax(3));
    omega = a2;
elseif nargin == 3
    phi = a1;
    theta = a2;
    omega = a3;
else
    error('ROTMX requires 2 or 3 arguments')
end

T1 = [ cos(phi),       sin(phi),            0;
      -sin(phi),       cos(phi),            0;
              0,              0,            1; ];
T2 = [ cos(theta),            0,  -sin(theta);
                0,            1,            0;
       sin(theta),            0,   cos(theta); ];
T3 = [ cos(omega),  -sin(omega),            0;
       sin(omega),   cos(omega),            0;
                0,            0,            1; ];

R = T1.' * T2.' * T3 * T2 * T1;
