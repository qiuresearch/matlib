function xyzplane = plane_gen(xyz0, xyz1, xyz2, num_points, varargin)
% --- Usage:
%        xyzplane = plane_gen(xyz0, xyz1, xyz2, num_points)
% --- Purpose:
%
% --- Parameter(s):
%
% --- Return(s):
%        results -
%
% --- Example(s):
%
% $Id: plane_gen.m,v 1.1 2013/08/17 17:00:50 xqiu Exp $
%

verbose = 1;
inclusive = 0;
parse_varargin(varargin);

% 1) Simple check on input parameters
xyzplane = [];

if nargin < 4
   help plane_gen
   return
end

num_dims = length(xyz0);
if (num_dims ~= length(xyz1)) or (num_dims ~= length(xyz2)) 
   disp('ERROR:: the two points given have DIFFERENT dimensions!')
   return
end
if (length(num_points) == 1)
   num_points = [num_points, num_points];
end

% 2) generate the first line, and then shift
line_repeat = line_gen(xyz0, xyz1, num_points(1));
xyzplane = repmat(line_repeat, 1, num_points(2));

if (num_points(2) > 1)
   % calculate the shift to each line
   xyz_shift = repmat(reshape((xyz2 - xyz0)/(num_points(2) -1), ...
                              num_dims, 1), 1, num_points(1));

   for iline =1:num_points(2)
      xyzplane(:,num_points(1)*(iline-1)+1:num_points(1)*iline) = ...
          xyzplane(:,num_points(1)*(iline-1)+1:num_points(1)*iline) + ...
          (iline-1)*xyz_shift;
   end
   % make sure the points are within the plane
   if (inclusive == 1)
      ipoints = 1:num_points(1);
      delta_num = (num_points(1)-1)/(num_points(2)-1);
      for iline=2:num_points(2)
         ipoints = [ipoints, ((iline-1)*num_points(1))+(1: ...
                    fix(num_points(1)-delta_num*(iline-1)))];
      end
      xyzplane = xyzplane(:,ipoints);
   end
end
