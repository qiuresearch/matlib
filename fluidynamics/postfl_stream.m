function postfl = postfl_stream(postfl)
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
% $Id: postfl_stream.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $
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
      postfl.slxyz = line_gen(postfl.p1, postfl.p2, ...
                              fix(postfl.num_points(1)/2)+ 1);
   case 3
      postfl.slxyz = plane_gen(postfl.p1, postfl.p2, postfl.p4, ...
                               fix(postfl.num_points([1,3])/2)+ 1);
   otherwise
      disp('ERROR:: the dimension can only be 1, 2, or 3!')
end

% 2) Obtain the stream line

disp(['POSTFL_STREAM:: extracting the streamline ... be patient! ' '... '])
switch postfl.num_dims
   case 2
      slxyz = stream2(postfl.x, postfl.y, postfl.u, postfl.v, ...
                      postfl.slxyz(1,:), postfl.slxyz(2,: ), [0.23,80000]);
   case 3
      slxyz = stream3(postfl.x, postfl.y, postfl.z, postfl.u, postfl.v, ...
                      postfl.w, postfl.slxyz(1,:), postfl.slxyz(2,:), ...
                      postfl.slxyz(3,:), [0.46,80000]);
   otherwise
      disp('ERROR:: the dimension can only be 1, 2, or 3!')
end

% 3) Remove short/incomplete stream lines

% find the maximum streamline length
x_max=-inf;
i_max = 1;
for i=1:length(slxyz)
   dummydata = slxyz{i};
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
x_sl = slxyz{i_max};
num_slpoints = length(x_sl(:,1));
x_sl = linspace(x_sl(1,1), x_sl(num_slpoints,1), num_slpoints);
x_grid = (x_sl(num_slpoints) - x_sl(1))/(num_slpoints-1);

% remove short streamlines
disp(['POSTFL_STREAM:: removing streamlines 50% shorter than the ' ...
      'maximum length!!!']);
index_removed = [];
x_min = x_sl(num_slpoints) - 0.5*(x_sl(num_slpoints)-x_sl(1));
for i=2:length(slxyz) % *** always keep the first stream line
   dummydata = slxyz{i};
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
   size_sl = cellfun('size', slxyz, 1);
   disp(['  ' num2str(num_removed) ' streamlines are removed!'])
   disp(['  they are: ' num2str(index_removed)])
   disp(['  with number of points: ' num2str(size_sl(index_removed))])
   disp(['  lengths: ' num2str(length_sls(index_removed))])
end

% ACTION of removing
if ~isempty(index_removed) 
   i_boolean = (ones(1, length(slxyz)) == 1);
   i_boolean(index_removed) = (1 == 0);
   slxyz = slxyz(i_boolean);
end

% re-adjust the 1st streamline --> y and z are all zeros
dummydata = zeros(num_slpoints,postfl.num_dims);
dummydata(:,1) = x_sl;
dummydata(:,2) = postfl.slxyz(2,1);
if (postfl.num_dims == 3)
   dummydata(:,3) = postfl.slxyz(3,1);
end
slxyz{1} = dummydata;
clear dummydata

% show some information
disp(['POSTFL_STREAM:: number of total streamlines: ' num2str(length(slxyz))])
disp(['                range: (' num2str(x_sl(1)) ',' ...
      num2str(x_sl(num_slpoints)) '), size: ' num2str(num_slpoints), ...
     ', i=' num2str(i_max)])

% 4) organize the streamlines to ordered arrays
num_sls = length(slxyz);
postfl.sldata.x = repmat(x_sl, num_sls, 1);
postfl.sldata.y = zeros(num_sls, num_slpoints);
postfl.sldata.width = zeros(1,num_slpoints);
postfl.sldata.u = zeros(num_sls, num_slpoints);
postfl.sldata.v = zeros(num_sls, num_slpoints);
if (postfl.num_dims == 3)
   postfl.sldata.z = zeros(num_sls, num_slpoints);
   postfl.sldata.w = zeros(num_sls, num_slpoints);
else
   postfl.sldata.z = [];
   postfl.sldata.w = [];
end
postfl.sldata.c = zeros(num_sls, num_slpoints);
postfl.sldata.t = zeros(num_sls, num_slpoints);

steptime = zeros(1,num_slpoints);
disp(['POSTFL_STREAM:: re-sizing the steamlines ...'])
for isl=1:num_sls
   xysl = slxyz{isl};
   % solve the distinct c problem from interp1
   [dummydata, index_unique] = unique(xysl(:,1));
   xysl = xysl(index_unique, :);
   postfl.sldata.y(isl,:) = interp1(xysl(:,1), xysl(:,2), x_sl, 'pchip');
   if (postfl.num_dims == 3)
      postfl.sldata.z(isl,:) = interp1(xysl(:,1), xysl(:,3), x_sl, 'pchip');
      [postfl.sldata.u(isl,:), postfl.sldata.v(isl,:), ...
       postfl.sldata.w(isl,:) postfl.sldata.c(isl,:), i_nan] = ...
          postinterp(postfl.fem, 'u','v','w','c', [x_sl; ...
                          postfl.sldata.y(isl,:); postfl.sldata.z(isl,:)]);
        % smooth it?
   else
      [postfl.sldata.u(isl,:), postfl.sldata.v(isl,:), ...
       postfl.sldata.c(isl,:), i_nan] = postinterp(postfl.fem, ...
                                                   'u','v','c', ...
                                                   [x_sl; ...
                          postfl.sldata.y(isl,:)]); 
      %; zeros(1,num_slpoints)]);
   end
   % check the existence of NAN
   if ~isempty(i_nan)
      disp(['WARNING:: ' num2str(length(i_nan)) ' NANs found in ' ...
            'streamline # ' num2str(isl) ', replaced by INF!'])
      postfl.sldata.u(isl,i_nan) = inf;
      postfl.sldata.v(isl,i_nan) = inf;
      postfl.sldata.c(isl,i_nan) = 0.0;
      if (postfl.num_dims == 3)
         postfl.sldata.w(isl,i_nan) = inf;
      end
   end
   % should use absolute velocity
   switch postfl.num_dims
      case 2
         steptime(2:end)=sqrt(x_grid^2+(postfl.sldata.y(isl,2:end) ...
                                        -postfl.sldata.y(isl,1:end- ...
                                                         1)).^2)./ ...
             sqrt(postfl.sldata.u(isl,1:end-1).^2 + postfl.sldata.v(isl, ...
                                                           1:end- 1).^2);
      case 3
         steptime(2:end)=sqrt(x_grid^2+(postfl.sldata.y(isl,2:end) ...
                                        -postfl.sldata.y(isl,1:end- ...
                                                         1)).^2 + ...
                              (postfl.sldata.z(isl,2:end)- ...
                               postfl.sldata.z(isl,1:end-1)).^2)./ ...
             sqrt(postfl.sldata.u(isl,1:end-1).^2 + postfl.sldata.v(isl, ...
                                                           1:end- ...
                                                           1).^2 + ...
                  postfl.sldata.w(isl,1:end-1).^2);
      otherwise
   end
   postfl.sldata.t(isl,:) = cumsum(steptime);
end

% 5) get the jet width from streamlines, ... and calculate the
% theoretical width too.
for i=1:num_slpoints
   postfl.sldata.width(i) = abs(postfl.sldata.y(num_sls,i) - ...
                                postfl.sldata.y(1,i))*2; % a factor of two
end

% just the mean of last 50 points from simulation results
postfl.sldata.jetwidth = mean(postfl.sldata.width(num_slpoints-50: ...
                                                  num_slpoints));
disp(['POSTFL_STREAM:: jet width is estimated as ' ...
      num2str(postfl.sldata.jetwidth)])

% theoretical jet half width
if isfield(postfl.const, 'flow_ratio') && isfield(postfl.const, 'width_outlet')
   flux_ratio = postfl.const.v_sam*postfl.const.width_inlet/ ...
       postfl.const.v_buf/postfl.const.width_side;
   width_percent = roots([0.5, 0, -1.5, 0.5*flux_ratio/(1+ 0.5* flux_ratio)]);
   width_percent = min(width_percent((imag(width_percent) == 0) & ...
                                     (real(width_percent) > 0)));
   postfl.sldata.jetwidth_theory = width_percent* postfl.const.width_outlet;
   disp(['POSTFL_STREAM:: theoretical jet width is ' ...
         num2str(postfl.sldata.jetwidth_theory)])
else
   postfl.sldata.jetwidth_theory = 0;
end
