function [R,ep] = randrot
% RANDROT  generate random rotation matrix  
% [R,EP] = RANDROT()  returns matrix R and Euler parameters EP

phi = 2*pi*rand(1);
costheta = 2.0*rand(1) - 1.0;
sintheta = sqrt(1.0 - costheta^2);
omega = pi*rand(1);
ep123 = sin(omega/2.0) * [ [cos(phi), sin(phi)]*sintheta, costheta ];
ep = [ cos(omega/2.0), ep123 ];
R = ep2rot(ep);
