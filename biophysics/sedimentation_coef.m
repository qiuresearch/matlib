function res =sedimentation_coef(molweight, volspecific, viscosity)
%        res =sedimentation_coef(molweight, volspecific, viscosity)
% molweight     - in Daltons
% volspecific   - ml/g  (0.73 for protein)
% viscosity     - Poise (water 0.0100200)

Na = 6.023e23;
molvolume = molweight*volspecific/Na*1e-6; % in m^3
radius = (molvolume*3/4/pi)^(1/3); % in m

viscosity = viscosity/10; % convert from Poise to Pa*S
friction_coef = 6*pi*viscosity*radius;
D20 =  1.3806503e-23*(273.15+20)/friction_coef;

sverd = (molweight*1e-3)*(1-volspecific)/Na/friction_coef;
sverd = sverd * 1e13;

res.molweight = molweight;
res.volspecific = volspecific;
res.molvolume = molvolume;
res.viscosity = viscosity;
res.sverd = sverd;
res.radius = radius*1e10;
res.D_20C = D20;

% water properties
% Temp.
% (ºC) 	Density
% (×1000 Kg/m3) 	Viscosity
% (Pa-s) 	Kinematic Viscosity
% (m2/s) 	Surface Tension
% (N/m) 	Bulk Modulus
% (GPa) 	Thermal Expansion Coefficient
% (/ºC)
% 0 	1 	1.79 × 10-3 	1.79 × 10-6 	7.56 × 10-2 	1.99 	-6.81 × 10-5
% 4 	1 	1.57 × 10-3 	1.57 × 10-6 	- 	- 	-
% 10 	1 	1.31 × 10-3 	1.31 × 10-6 	7.42 × 10-2 	2.12 	8.80 × 10-5
% 20 	0.998 	1.00 × 10-3 	1.00 × 10-6 	7.28 × 10-2 	2.21 	2.07 × 10-4
% 30 	0.996 	7.98 × 10-4 	8.01 × 10-7 	7.12 × 10-2 	2.26 	2.94 × 10-4
% 40 	0.992 	6.53 × 10-4 	6.58 × 10-7 	6.96 × 10-2 	2.29 	3.85 × 10-4
% 50 	0.988 	5.47 × 10-4 	5.48 × 10-7 	6.79 × 10-2 	2.29 	4.58 × 10-4
% 60 	0.983 	4.67 × 10-4 	4.75 × 10-7 	6.62 × 10-2 	2.28 	5.23 × 10-4
% 70 	0.978 	4.04 × 10-4 	4.13 × 10-7 	6.64 × 10-2 	2.24 	5.84 × 10-4
% 80 	0.972 	3.55 × 10-4 	3.65 × 10-7 	6.26 × 10-2 	2.20 	6.41 × 10-4
% 90 	0.965 	3.15 × 10-4 	3.26 × 10-7 	- 	2.14 	6.96 × 10-4
% 100 	0.958 	2.82 × 10-4 	2.94 × 10-7 	5.89 × 10-2 	2.07 	7.50 × 10-4 