function postfl = postfl_evalstream1(postfl)
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
% $Id: postfl_evalstream1.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $
%

if (nargin < 1)
   help postfl_stream
   return
end

postfl.num_dims = length(postfl.p1);

% 1) organize the streamlines to ordered arrays
num_sls = length(postfl.slxyz);
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
   xysl = postfl.slxyz{isl};
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
