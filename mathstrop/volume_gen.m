function xyzvolume = volume_gen(xyz0, xyz1, xyz2, xyz3, num_points)
% --- Usage:
%        xyzplane = volume_gen(xyz0, xyz1, xyz2, xyz3, num_points)
% --- Purpose:
%
% --- Parameter(s):
%
% --- Return(s):
%        results -
%
% --- Example(s):
%
% $Id: volume_gen.m,v 1.1 2013/08/17 17:05:36 xqiu Exp $
%

% 1) Simple check on input parameters
xyzplane = [];

if nargin < 5
   help volume_gen
   return
end

num_dims = length(xyz0);
if (num_dims ~= length(xyz1)) or (num_dims ~= length(xyz2)) 
   disp('ERROR:: the two points given have DIFFERENT dimensions!')
   return
end
if (length(num_points) == 1)
   num_points = [num_points, num_points, num_points];
end
if (length(num_points) == 2)
   disp('VOLUME_GEN:: num_points needs to be a 1x3 vector!')
   return
end

% 2)

plane_repeat = plane_gen(xyz0, xyz1, xyz2, num_points(1:2));
xyzvolume = repmat(plane_repeat, 1, num_points(3));

num_planepoints = num_points(1)*num_points(2);

if (num_points(3) > 1)
   xyz_shift = repmat(reshape((xyz3 - xyz1)/(num_points(3) -1), num_dims, ...
                              1), 1, num_planepoints);
   
   for iplane =1:num_points(3)
      xyzvolume(:,num_planepoints*(iplane-1)+1:num_planepoints*iplane) ...
          = xyzvolume(:,num_planepoints*(iplane-1)+1: ...
                      num_planepoints*iplane) + (iplane-1)*xyz_shift;
   end
end
