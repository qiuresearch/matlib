function postfl = postfl_evalstream2(postfl)
% --- Usage:
%        postfl = postfl_evalstream2(postfl)
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
% $Id: postfl_evalstream2.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $
%

if (nargin < 1)
   help postfl_evalstream2
   return
end

% 1) organize the streamlines to ordered arrays
disp(['POSTFL_EVALSTREAM2:: evaulationg the steamlines  ...'])
num_sls = length(postfl.slxyz);
postfl.jetwidth = 0;
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
   % get jet width =  the mean of last 20 points 
   postfl.jetwidth = max([postfl.jetwidth, ...
                       mean(postfl.sldata(isl).y(end-20:end))*2]);
end

% 2) show the jet width from streamlines
disp(['POSTFL_EVALSTREAM2:: jet width is estimated as ' num2str(postfl.jetwidth)])

% theoretical jet width (if possible)
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
