function postfl = postfl_getstream2(postfl)
% --- Usage:
%        postfl = postfl_getstream2(postfl)
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
%        postfl - postfl structure with "slstart", "slxyz" field updated
%            
% --- Example(s):
%
% $Id: postfl_getstream2.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $
%

if (nargin < 1)
   help postfl_getstream2
   return
end

postfl.num_dims = length(postfl.p1);

% 1) generate starting points

disp('POSTFL_STREAM:: get starting coordinates for streamlines ...')
% the default stream starting points: 
switch postfl.num_dims
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

   otherwise
      disp('ERROR:: the dimension can only be 1, 2, or 3!')
end

% 3) Remove short/incomplete stream lines

% find the maximum streamline length
x_max=-inf;
i_max = 1;
for i=1:length(postfl.slxyz)
   if isempty(postfl.slxyz{i})
      continue
   end
   dummydata = postfl.slxyz{i};
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
postfl.x_sl = x_sl;
postfl.x_grid = x_grid;

% remove short streamlines
disp(['POSTFL_STREAM:: removing streamlines 50% shorter than the ' ...
      'maximum length!!!']);
index_removed = [];
x_min = x_sl(num_slpoints) - 0.50*(x_sl(num_slpoints)-x_sl(1));
for i=2:length(postfl.slxyz) % *** DO NOT remove the first streamline ***
   dummydata = postfl.slxyz{i};
   length_dummy = size(dummydata,1);
   if (length_dummy <= 1) % add if the streamline only has one point
      index_removed = [index_removed, i];
   else
      if (dummydata(length_dummy,1) < x_min) % add if shorter than x_min
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
   clf, hold all
   for i=1:length(index_removed)
      xyplot(postfl.slxyz{index_removed(i)})
   end
end

% ACTION of removing
if ~isempty(index_removed) 
   i_boolean = (ones(1, length(postfl.slxyz)) == 1);
   i_boolean(index_removed) = (1 == 0);
   postfl.slxyz = postfl.slxyz(i_boolean);
   postfl.slstart = postfl.slstart(:,i_boolean);
end

% readjust the 1st streamline --> y and z are all zeros
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
      num2str(x_sl(num_slpoints)) '), size: ', num2str(num_slpoints)])
