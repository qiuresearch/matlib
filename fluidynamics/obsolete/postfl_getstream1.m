function postfl = postfl_getstream1(postfl)
% --- Usage:
%        postfl = postfl_stream(postfl)
% --- Purpose:
%        extracting the streams line from previously interpolated
%        u,v,w data. Starting line/plane points are taken from
%        postfl.p1,p2,p3,num_dims. The streamlines are then
%        reinterpolated to have the same x grids.  warning: the first
%        streamline is set to be at y==0. this may not be applicable
%        to some simulations.
%
% --- Parameter(s):
%        postfl - a postfl structure with previousely interpolated
%        data
% --- Return(s):
%        postfl - postfl structure with "sldata" field updated
%
% --- Example(s):
%
% $Id: postfl_getstream1.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $
%

if (nargin < 1)
   help postfl_stream
   return
end

postfl.num_dims = length(postfl.p1);

% 1) generate starting points

disp('POSTFL_STREAM:: get starting coordinates for streamlines ...')
% the default stream starting points: 
switch length(postfl.num_points)
   case 1
      disp('ERROR:: no streamline in case of 1D!')
   case 2
      postfl.slstart = line_gen(postfl.p1, postfl.p2, ...
                              fix(postfl.num_points(1)/2)+ 1);
   case 3
      postfl.slstart = plane_gen(postfl.p1, postfl.p2, postfl.p4, ...
                               fix(postfl.num_points([1,3])/2)+ 1);
   otherwise
      disp('ERROR:: the dimension can only be 1, 2, or 3!')
end

% 2) Obtain the stream line

disp(['POSTFL_STREAM:: extracting the streamline ... be patient! ' '... '])
switch postfl.num_dims
   case 2
      postfl.slxyz = stream2(postfl.x, postfl.y, postfl.u, postfl.v, ...
                      postfl.slstart(1,:), postfl.slstart(2,: ), [0.23,80000]);
   case 3
      postfl.slxyz = stream3(postfl.x, postfl.y, postfl.z, postfl.u, postfl.v, ...
                      postfl.w, postfl.slstart(1,:), postfl.slstart(2,:), ...
                      postfl.slstart(3,:), [0.46,80000]);
   otherwise
      disp('ERROR:: the dimension can only be 1, 2, or 3!')
end

% 3) Remove short/incomplete stream lines

% find the maximum streamline length
x_max=-inf;
i_max = 1;
for i=1:length(postfl.slxyz)
   dummydata = postfl.slxyz{i};
   if isempty(dummydata)
      continue
   end
   length_sls(i) = dummydata(end,1);
   %   size(dummydata)
   if (x_max < dummydata(end,1))
      x_max = dummydata(end,1);
      i_max = i;
   end
end
x_sl = postfl.slxyz{i_max};
num_slpoints = length(x_sl(:,1));
x_sl = linspace(x_sl(1,1), x_sl(num_slpoints,1), num_slpoints);
x_grid = (x_sl(num_slpoints) - x_sl(1))/(num_slpoints-1);

% remove short streamlines
disp(['POSTFL_STREAM:: removing streamlines 50% shorter than the ' ...
      'maximum length!!!']);
index_removed = [];
x_min = x_sl(num_slpoints) - 0.5*(x_sl(num_slpoints)-x_sl(1));
for i=2:length(postfl.slxyz) % *** always keep the first stream line
   dummydata = postfl.slxyz{i};
   length_dummy = size(dummydata,1);
   if (length_dummy <= 1) % add to list if the streamline only has one point
      index_removed = [index_removed, i];
   else
      if (dummydata(length_dummy,1) < x_min) % add to list if shorter than x_min
         index_removed = [index_removed, i];
      end
   end
end
if ~isempty(index_removed) % show some information
   num_removed = length(index_removed);
   size_sl = cellfun('size', postfl.slxyz, 1);
   disp(['  ' num2str(num_removed) ' streamlines are removed!'])
   disp(['  they are: ' num2str(index_removed)])
   disp(['  with number of points: ' num2str(size_sl(index_removed))])
   disp(['  lengths: ' num2str(length_sls(index_removed))])
end

% ACTION of removing
if ~isempty(index_removed) 
   i_boolean = (ones(1, length(postfl.slxyz)) == 1);
   i_boolean(index_removed) = (1 == 0);
   postfl.slxyz = postfl.slxyz(i_boolean);
end

% re-adjust the 1st streamline --> y and z are all zeros
dummydata = zeros(num_slpoints,postfl.num_dims);
dummydata(:,1) = x_sl;
dummydata(:,2) = postfl.slstart(2,1);
if (postfl.num_dims == 3)
   dummydata(:,3) = postfl.slstart(3,1);
end
postfl.slxyz{1} = dummydata;
clear dummydata

% 4) show some information
disp(['POSTFL_STREAM:: number of total streamlines: ' num2str(length(postfl.slxyz))])
disp(['                range: (' num2str(x_sl(1)) ',' ...
      num2str(x_sl(num_slpoints)) '), size: ' num2str(num_slpoints), ...
     ', i=' num2str(i_max)])
