function decaylength = decaylength_hydration(period, mode)
%	 decaylength = decaylength_hydration(period, mode)
%
if (nargin < 1)
   help decaylength_hydration
   return
end

if ~exist('mode', 'var')
   mode = 'forward';
end
lambda_water = 4;

if strcmpi(mode, 'forward')
   decaylength = 0.5/sqrt(1/lambda_water^2 + (2*pi/period)^2);
else % given the decaying length, get the periodicity
   decaylength = 2*pi/sqrt((0.5/period)^2 - 1/lambda_water^2);
end


