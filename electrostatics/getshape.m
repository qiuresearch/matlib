function [index, ixyz] = getshape(data, id, varargin)
% --- Usage:
%        [index, ixyz] = getshape(data, id, varargin)
% --- Purpose:
%        this takes a solvent accessibility matrix and return the boundary
%        element index, which would be the elements with value zero, but has
%        at least one neighboring value of 1.
%
%        Right now, only three directions are checked, instead of 14 for
%        an exhaustive search
% --- Parameter(s):
%        data - a 3D matrix (eg, the solvent accessibility matrix)
%          id - which values to find: 0 (default) or 1
%    varargin - 'verbose':
%               'thickness' 1 (default)
% --- Return(s):
%        index - a 1D vector giving the index of each boundary element
%         ixyz - nx3 matrix converted from 'index' based on data dimensions
% --- Example(s):
%
% $Id: getshape.m,v 1.1 2013/08/18 04:17:36 xqiu Exp $
%

% 1) Simple check on input parameters

if (nargin < 1)
   help getshapre
   return
end

% 1) check parameter
verbose = 1;
thickness =1;
parse_varargin(varargin);

if ~exist('id', 'var')
   id = 0; % default is to find all 0s next to 1s
end

switch id
   case 0 % find all 0s adjacent to 1
   case 1 % find all 1s adjacent to 0
      data(:) = 1 - data;
end

% 2) prepare
[num_xs, num_ys, num_zs] = size(data);
data_tmp = data;
index = [];

% 3) compute,  assuming the box boundar is not on the surface

for i=1:thickness
   % along x
   if (num_xs > 1)
      data_tmp([1,end],:,:) = 0;
      data_tmp(2:end-1,:,:) = (data(2:end-1,:,:) - data(1:end-2,:,:)) ...
          + (data(2:end-1,:,:) - data(3:end,:,:));
      index = union(find(data_tmp < 0), index);
   end
   
   % along y
   if (num_ys > 1)
      data_tmp(:,[1,end],:) = 0;
      data_tmp(:,2:end-1,:) = (data(:,2:end-1,:) - data(:,1:end-2,:)) ...
          + (data(:,2:end-1,:) - data(:,3:end,:));
      index = union(find(data_tmp < 0), index);
   end
   
   % along z
   if (num_zs > 1)
      data_tmp(:,:,[1,end]) = 0;
      data_tmp(:,:,2:end-1) = (data(:,:,2:end-1) - data(:,:,1:end-2)) ...
          + (data(:,:,2:end-1) - data(:,:,3:end));
      index = union(find(data_tmp < 0), index);
   end
   
   % reset the maxtrix
   data(index) = 1;
end

% 4) return
num_xyzs = length(index);
showinfo(['number of  points on surface (v==' int2str(id) ['): ' ...
                    ''] int2str(length(index))])
if (nargout > 1)
   [ixyz(:,1), ixyz(:,2), ixyz(:,3)] = ind2sub([num_xs, num_ys, ...
                       num_zs], index);
end
