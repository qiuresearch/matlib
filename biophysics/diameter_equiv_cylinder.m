function [dia_virial, dia_volume] = diameter_equiv_cylinder(dia,height)
% --- Usage:
%        [dia_virial, dia_volume] = diameter_equiv_cylinder(dia,height)
% --- Purpose:
%        Calculate the equivalent spherical dia of a cylinder by
%             1) equaling second virial coefficient
%             2) equaling the volume
%

if (nargin < 1)
   help diameter_equiv_cylinder
   return
end

% 1) Virial
% the formula is taken from equ.10 of Galantini et al.,
% J.Phys.Chem.B 2004, 108, 3078-3085
factor1 = height/dia + 0.5*(3+pi) + 0.25*pi*dia/height;
dia_virial = 0.5*(3*dia*dia*height*factor1)^(1/3);

% 2) Volume
dia_volume = (8/pi*pi*dia*dia*height/4)^(1/3);
