function [data, circ_rings]  = integrate_azimuthal(im, q, qwidth, varargin)
% --- Usage:
%        [data, circ_rings]  = circ_integrate(im, q, qwidth, varargin)
%
% --- Purpose:
%

global X_cen Y_cen MaskI X_Lambda Spec_to_Phos

num_points = 101;
phiwidth=0; % in radians
parse_varargin(varargin);

% convert to polar coordinates
im = im .* double(MaskI);
im_size = size(im);
[xgrid, ygrid] = meshgrid(1:im_size(2), 1:im_size(1));
[theta, r] = cart2pol(xgrid-X_cen, ygrid-Y_cen);
radius = Spec_to_Phos*tan(2*asin(q*X_Lambda/4/pi));
rwidth = Spec_to_Phos*tan(2*asin((q+qwidth)*X_Lambda/4/pi))- ...
         Spec_to_Phos*tan(2*asin((q-qwidth)*X_Lambda/4/pi));

% need to improve
inegative = find(theta < 0);
if ~isempty(inegative)
   theta(inegative) = theta(inegative)+2*pi;
end

% find the "band" to integrate
iselected= find((r >= (radius-rwidth/2)) & (r <= (radius+rwidth/2)) ...
                & (MaskI == 1));

% angles of the points on the circle
data(:,1) = linspace(min(theta(iselected)), max(theta(iselected)), num_points);
data(:,2) = 0; data(:,3) = 0;

% integrate
if (phiwidth == 0) % no width --> only use in between 
   index = histogram(theta(iselected), [data(1,1), data(end,1)], num_points);
   
   for i=1:length(index)
      data(index(i),2) = data(index(i),2) + im(iselected(i));
      data(index(i),3) = data(index(i),3) + 1;
   end
else % fixed theta width for each point, may overlap!
   for i=1:num_points
      index =  find((theta(iselected) >= (data(i,1)-phiwidth/2)) ...
                    & (theta(iselected) <= (data(i,1)+phiwidth/ 2)));
      if ~isempty(index)
         data(i,2) = sum(im(iselected(index)));
         data(i,3) = length(index);
      end
   end
end
% normalize by number of pixels added
data(find(data(:,3) == 0),3) = 1;
data(:,1) = data(:,1);
data(:,2) = data(:,2)./data(:,3);

% generate the circ box for plotting
arc = [cos(linspace(data(1,1), data(end,1), 300))', sin(linspace(data(1,1), ...
                                                  data(end,1), 300))'];

circ_rings(:,1) = X_cen + [(radius-rwidth/2)*arc(:,1); (radius+ ...
                                                  rwidth/2)*arc(:,1)];
circ_rings(:,2) = Y_cen + [(radius-rwidth/2)*arc(:,2); (radius+ ...
                                                  rwidth/2)*arc(:, 2)];
circ_rings = [circ_rings; circ_rings(end,:)];


