function postfl = postfl_stream2(postfl)
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
% $Id: postfl_stream2.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $
%

if (nargin < 1)
   help postfl_stream2
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
hf = figure('visible', 'off');

switch postfl.num_dims
   case 2
   case 3
      flowstart = {postfl.slstart(1,:), postfl.slstart(2,:), postfl.slstart(3,:)};
      femdata=postplot(postfl.fem, ...
                       'flowdata',{'u','v','w'}, ...
                       'flowcolor',[1.0,0.0,0.0], ...
                       'flowstart',flowstart, ...
                       'flowtype','line', ...
                       'solnum',1, 'geom', 'off', ...
                       'flowback', 'off', 'flowstattol',0.1, ...
                       'flowrefine', 2, 'outtype', 'postdata');

      delete(hf);
      % clf(hf), set(hf, 'visible', 'on'), hold all
      femdata = femdata{1};
      femdata.grouping = [femdata.grouping, length(femdata.t)+1];
      for i=1:length(femdata.grouping)-1
         i_start = femdata.t(1,femdata.grouping(i));
         i_end = femdata.t(2,femdata.grouping(i+1)-1);
         postfl.slxyz{i} = transpose(femdata.p(:,i_start:i_end));
         %xyplot(postfl.slxyz{i})
      end
      flclear femdata; 
   otherwise
      disp('ERROR:: the dimension can only be 1, 2, or 3!')
end

% 3) Remove short/incomplete stream lines

% find the maximum streamline length
x_max=-inf;
i_max = 1;
for i=1:length(postfl.slxyz)
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
  
% show some information
disp(['POSTFL_STREAM:: number of total streamlines: ' num2str(length(postfl.slxyz))])
disp(['                range: (' num2str(x_sl(1)) ',' ...
      num2str(x_sl(num_slpoints)) '), size: ', num2str(num_slpoints)])


% 4) organize the streamlines to ordered arrays
disp(['POSTFL_STREAM:: analyzing the steamlines ...'])
num_sls = length(postfl.slxyz);
postfl.sldata = repmat(struct('num_points', 0, 'x', [], 'y', [], ...
                              'z', [], 'u', [], 'v', [], 'w', [], ...
                              'c', [], 't', [], 'i0', 0, 'x0', 0, ...
                              't0', 0, 'tc', [], 'tm', []), 1, num_sls);
for isl=1:num_sls
   xysl = postfl.slxyz{isl};
   postfl.sldata(isl).x = xysl(:,1)';
   postfl.sldata(isl).num_points = length(postfl.sldata(isl).x);
   postfl.sldata(isl).y = xysl(:,2)';
   if (postfl.num_dims == 3)
      postfl.sldata(isl).z = xysl(:,3)';
      [postfl.sldata(isl).u, postfl.sldata(isl).v, postfl.sldata(isl).w, ...
       postfl.sldata(isl).c, i_nan] = postinterp(postfl.fem, ...
                                                 'u','v','w','c', ...
                                                 [postfl.sldata(isl).x; ...
                          postfl.sldata(isl).y; postfl.sldata(isl).z]);
      
   else
      postfl.sldata(isl).z = [];
      postfl.sldata(isl).w = [];
      [postfl.sldata(isl).u, postfl.sldata(isl).v, postfl.sldata(isl).c, ...
       i_nan] =  postinterp(postfl.fem, 'u','v','c', [postfl.sldata(isl).x; ...
                          postfl.sldata(isl).y]); 
           
   end
   
   % check the existence of NAN
   if ~isempty(i_nan)
      disp(['WARNING:: ' num2str(length(i_nan)) ' NANs found in ' ...
            'streamline # ' num2str(isl) ', replaced by INF!'])
      postfl.sldata(isl).u(i_nan) = inf;
      postfl.sldata(isl).v(i_nan) = inf;
      postfl.sldata(isl).c(i_nan) = 0.0;
      if (postfl.num_dims == 3)
         postfl.sldata(isl).w(i_nan) = inf;
      end
   end
   
   % should use absolute velocity
   switch postfl.num_dims
      case 2
         steptime=[0, sqrt((postfl.sldata(isl).x(2:end)- ...
                            postfl.sldata(isl).x(1:end-1)).^2+ ...
                           (postfl.sldata(isl).y(2:end) - ...
                            postfl.sldata(isl).y(1:end- 1)).^2)./ ...
                   sqrt(postfl.sldata(isl).u(1:end-1).^2 + ...
                        postfl.sldata(isl).v(1:end- 1).^2)];
      case 3
         steptime=[0, sqrt((postfl.sldata(isl).x(2:end)- ...
                            postfl.sldata(isl).x(1:end-1)).^2+ ...
                           (postfl.sldata(isl).y(2:end) - ...
                            postfl.sldata(isl).y(1:end-1)).^2 + ...
                           (postfl.sldata(isl).z(2:end)- ...
                            postfl.sldata(isl).z(1:end-1)).^2)./ ...
                   sqrt(postfl.sldata(isl).u(1:end-1).^2 + ...
                        postfl.sldata(isl).v(1:end-1).^2 + ...
                        postfl.sldata(isl).w(1:end-1).^2)];
      otherwise
   end
   postfl.sldata(isl).t = cumsum(steptime);
end

% 5) get the jet width from streamlines
% just the mean of last 50 points from simulation results
postfl.jetwidth = mean(postfl.sldata(num_sls).y(end-50:end))*2;
disp(['POSTFL_STREAM:: jet width is estimated as ' num2str(postfl.jetwidth)])

% theoretical jet width
if isfield(postfl.const, 'flow_ratio') && isfield(postfl.const, 'width_outlet')
   width_percent = roots([0.5, 0, -1.5, 0.5*postfl.const.flow_ratio/(1+ ...
                                                     0.5*postfl.const ...
                                                     .flow_ratio)]);
   width_percent = min(width_percent((imag(width_percent) == 0) & ...
                                     (real(width_percent) > 0)));
   postfl.jetwidth_theory = width_percent* postfl.const.width_outlet;
   disp(['POSTFL_STREAM:: theoretical jet width is ' ...
         num2str(postfl.jetwidth_theory)])
end
