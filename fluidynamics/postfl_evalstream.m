function postfl = postfl_evalstream(postfl, varargin)
% --- Usage:
%        postfl = postfl_evalstream(postfl)
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
% $Id: postfl_evalstream.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $


if (nargin < 1)
   help postfl_evalstream
   return
end
%
x_grid = 0.2e-6;
x_grid_ll = 0.1e-6;
parse_varargin(varargin);

postfl.num_dims = length(postfl.p1);
num_sls = length(postfl.slxyz);

% 0) find the streamline with the maximum length
x_max=-inf;
x_min=-inf;
i_max = 1;
for i=1:num_sls
   dummydata = postfl.slxyz{i};
   if isempty(dummydata)
      continue
   end
   if (x_max < dummydata(end,1))
      x_max = dummydata(end,1);
      i_max = i;
      num_xs = length(dummydata(:,1));
   end
   x_min = max([x_min, dummydata(1,1)]);
end
disp(['POSTFL_EVALSTREAM:: find streamline #' int2str(i_max) ...
      ' longest ending @' num2str(x_max) '(m)'])

% calculate the x-grid size and the x array
x_grid = max([x_grid_ll, min([x_grid, (x_max - x_min)/ (num_xs-1)])]);
x_sl = x_min:x_grid:x_max;
num_slpoints = length(x_sl);

% 1) organize the streamlines to ordered arrays
switch postfl.evalstream_method
   case 1 % the faster way: interpolate data into equal grid array
      disp(['POSTFL_EVALSTREAM:: mesh the steamlines to equi-grids ' ...
            '(method #1)...'])

      postfl.sldata = [];
      postfl.sldata.x = repmat(x_sl, num_sls, 1);
      postfl.sldata.y = zeros(num_sls, num_slpoints);
      postfl.sldata.width = zeros(1,num_slpoints);
      postfl.sldata.u = zeros(num_sls, num_slpoints);
      postfl.sldata.v = zeros(num_sls, num_slpoints);
      if (postfl.num_dims == 3)
         postfl.sldata.z = zeros(num_sls, num_slpoints);
         postfl.sldata.w = zeros(num_sls, num_slpoints);
      else
         postfl.sldata.z = [0,0];
         postfl.sldata.w = [0,0];
      end
      postfl.sldata.c = zeros(num_sls, num_slpoints);
      postfl.sldata.t = zeros(num_sls, num_slpoints);
      
      disp(['POSTFL_EVALSTREAM:: process streamlines one by one, be ' ...
            'patient ... '])
      disp(['                    streamlines: ' int2str(num_sls), ...
            ', x grid size: ' num2str(x_grid), ', points: ' ...
            int2str(num_slpoints)])
      
      steptime = zeros(1,num_slpoints);
      for isl=1:num_sls
         xysl = postfl.slxyz{isl};
         % keep unique x coordinates only
         [dummydata, index_unique] = unique(xysl(:,1));
         xysl = xysl(index_unique, :);
         postfl.sldata.y(isl,:) = interp1(xysl(:,1), xysl(:,2), x_sl, ...
                                          'pchip', xysl(end,2));
         switch postfl.num_dims
            case 2
               [postfl.sldata.u(isl,:), postfl.sldata.v(isl,:), ...
                postfl.sldata.c(isl,:), i_nan] = postinterp(postfl.fem, ...
                                                            'u','v','c', ...
                                                            [x_sl; ...
                                   postfl.sldata.y(isl,:)]); 
            case 3
               postfl.sldata.z(isl,:) = interp1(xysl(:,1), xysl(:,3), ...
                                                x_sl, 'pchip', xysl(end,3));
               [postfl.sldata.u(isl,:), postfl.sldata.v(isl,:), ...
                postfl.sldata.w(isl,:) postfl.sldata.c(isl,:), i_nan] ...
                   = postinterp(postfl.fem, 'u','v','w','c', [x_sl; ...
                                   postfl.sldata.y(isl,:); ...
                                   postfl.sldata.z(isl,:)]);
            otherwise
         end
         % smooth it?
         
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
         switch postfl.num_dims % calculate the elapsed time at
                                % each point
            case 2
               steptime(2:end)=sqrt(x_grid^2+(postfl.sldata.y(isl,2:end) ...
                                              -postfl.sldata.y(isl,1:end- ...
                                                               1)) ...
                                    .^2)./ ...
                   sqrt(postfl.sldata.u(isl,1:end-1).^2 + ...
                        postfl.sldata.v(isl, 1:end- 1).^2);
            case 3
               steptime(2:end)=sqrt(x_grid^2+(postfl.sldata.y(isl,2:end) ...
                                              -postfl.sldata.y(isl,1:end- ...
                                                               1)).^2 ...
                                    + (postfl.sldata.z(isl,2:end)- ...
                                       postfl.sldata.z(isl,1:end-1)).^2)./ ...
                   sqrt(postfl.sldata.u(isl,1:end-1).^2 + ...
                        postfl.sldata.v(isl, 1:end- 1).^2 + ...
                        postfl.sldata.w(isl,1:end-1).^2);
            otherwise
         end
         postfl.sldata.t(isl,:) = cumsum(steptime);
      end
      % get the jet width from streamlines
      for i=1:num_slpoints
         postfl.sldata.width(i) = max(postfl.sldata.y(:,i));
      end      
      postfl.jetwidth = mean(postfl.sldata.width(fix(num_slpoints*4/5): ...
                                                 num_slpoints))*2;
      
%**********************************************************************%

   case 2 % the slow way: each streamline has different length
      disp(['POSTFL_EVALSTREAM:: keep each steamline as original ' ...
            '(method #2)...'])
      postfl.sldata = repmat(struct('num_points', 0, 'x', [], 'y', [], ...
                                    'z', [], 'u', [], 'v', [], 'w', [], ...
                                    'c', [], 't', [], 'i0', 0, 'x0', 0, ...
                                    't0', 0, 'tc', [], 'tm', []), 1, num_sls);
      disp(['POSTFL_EVALSTREAM:: process streamlines one by one, be ' ...
            'patient ... '])
      disp(['                    streamlines: ' int2str(num_sls)])
      for isl=1:num_sls
         xysl = postfl.slxyz{isl};
         postfl.sldata(isl).x = gridize(xysl(:,1)', x_grid, ...
                                        'overshoot',0, 'x_start', x_min);
         postfl.sldata(isl).num_points = length(postfl.sldata(isl).x);
         postfl.sldata(isl).y = interp1(xysl(:,1), xysl(:,2), ...
                                        postfl.sldata(isl).x, 'pchip', ...
                                        xysl(end,2));
         if (postfl.num_dims == 3)
            postfl.sldata(isl).z =  interp1(xysl(:,1), xysl(:,3), ...
                                            postfl.sldata(isl).x, ...
                                            'pchip', xysl(end,3));
            [postfl.sldata(isl).u, postfl.sldata(isl).v, ...
             postfl.sldata(isl).w, postfl.sldata(isl).c, i_nan] = ...
                postinterp(postfl.fem, 'u','v','w','c', ...
                           [postfl.sldata(isl).x; postfl.sldata(isl).y; ...
                            postfl.sldata(isl).z]);
            
         else
            postfl.sldata(isl).z = [];
            postfl.sldata(isl).w = [];
            [postfl.sldata(isl).u, postfl.sldata(isl).v, ...
             postfl.sldata(isl).c, i_nan] =  postinterp(postfl.fem, ...
                                                        'u','v','c', ...
                                                        [postfl ...
                                .sldata(isl).x; postfl.sldata(isl).y]); 
            
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
                                  postfl.sldata(isl).y(1:end-1)).^2 ...
                                 + (postfl.sldata(isl).z(2:end)- ...
                                    postfl.sldata(isl).z(1:end-1)).^2)./ ...
                         sqrt(postfl.sldata(isl).u(1:end-1).^2 + ...
                              postfl.sldata(isl).v(1:end-1).^2 + ...
                              postfl.sldata(isl).w(1:end-1).^2)];
            otherwise
         end
         postfl.sldata(isl).t = cumsum(steptime);
      end
      % get jet width =  the mean of last 20 points 
      y_max = -inf;
      for isl=1:num_sls
         y_avg = mean(postfl.sldata(isl) .y(fix(length(postfl.sldata(isl) ...
                                                       .y)*4/5):end));
         y_max = max([y_max, y_avg]);
      end
      postfl.jetwidth = y_max*2;
   otherwise
      disp('ERROR:: only two methods of stream evaulation are available!!!')
end
      
% 2) show the jet width from streamlines
disp(['POSTFL_EVALSTREAM:: jet width is estimated as ' ...
      num2str(postfl.jetwidth)])

% theoretical jet half width
if isfield(postfl.const, 'flow_ratio') && isfield(postfl.const, 'width_outlet')
   flux_ratio = postfl.const.v_sam*postfl.const.width_inlet/ ...
       postfl.const.v_buf/postfl.const.width_side;
   width_percent = roots([0.5, 0, -1.5, 0.5*flux_ratio/(1+ 0.5* flux_ratio)]);
   width_percent = min(width_percent((imag(width_percent) == 0) & ...
                                     (real(width_percent) > 0)));
   postfl.jetwidth_theory = width_percent* postfl.const.width_outlet;
   disp(['POSTFL_EVALSTREAM:: theoretical jet width is ' ...
         num2str(postfl.jetwidth_theory)])
else
   postfl.jetwidth_theory = 0;
end
