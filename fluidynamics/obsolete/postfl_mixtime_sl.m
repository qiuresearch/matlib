function postfl = postfl_mixtime_sl(postfl, t)
% --- Usage:
%        postfl = postfl_mixtime_sl(postfl, t)
% --- Purpose:
%        calculate the mixing time performance from streamline
%        data. Here the threshold concentration postfl.c0 is very
%        important
% --- Parameter(s):
%        postfl - the postfl strucutre defined by postfl_init()
%        t      - the time grid you would like to quantize the
%                 mixing time distribution
% --- Return(s):
%        postfl - the same postfl structure with udpated
%                 postfl.sldata and postfl.mtdata fields
%
% --- Example(s):
%
% $Id: postfl_mixtime_sl.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $
%

if (nargin < 1)
   help postfl_mixtime_sl
   return
end

disp('POSTFL_MIXTIME2:: analyze each stream line to extract time ');

num_sls = length(postfl.sldata);

% find the streamline with the maximum length
x_max=-inf;
i_max = 1;
for i=1:num_sls
   if (x_max < postfl.sldata.x(end))
      x_max = postfl.sldata.x(end);
      i_max = i;
   end
end
disp(['                    find streamline No.' int2str(i_max) ...
      ' with largest end position: ' num2str(x_max)])

% calculate the x-grid size and the x array
x_grid = min([0.25e-6, (postfl.sldata.x(end)-postfl.sldata.x(1))/ ...
              (length(postfl.sldata.x)-1)]);
x = postfl.sldata.x(1):x_grid:postfl.sldata.x(end);
num_xs = length(x);

% 1) process each streamline first: critical concentration is the
% important parameter

% 2) the time distribution data
if ~exist('t') || ~isempty(t) 
   t = linspace(0.0,0.0006,61);
end
num_ts = length(t);
t_grid = (t(num_ts) - t(1))/(num_ts -1);

postfl.mtdata.t = t;
postfl.mtdata.n = [0,0]; % zeros(num_ts, num_xs);
postfl.mtdata.x = x;
num_c0s = length(postfl.c0);
postfl.mtdata.c_aver = postfl.mtdata.x;
postfl.mtdata.t_aver = zeros(num_c0s, num_xs);
postfl.mtdata.t_delt = zeros(num_c0s, num_xs);
postfl.mtdata.i0 = zeros(1, num_c0s);
postfl.mtdata.x0 = zeros(1, num_c0s);
postfl.mtdata.t0 = zeros(1, num_c0s);

% 3) 

for i=1:num_sls
   % as Hye Yoon suggested, take the time difference between 10 and
   % 90% percent mixed
   c_min = mean(postfl.sldata(i).c(1:10));
   c_max = mean(postfl.sldata(i).c(end-50:end));
   i10 = locate(postfl.sldata(i).c, c_min*0.9+c_max*0.1);
   i90 = locate(postfl.sldata(i).c, c_min*0.1+c_max*0.9);
   postfl.sldata(i).tc = postfl.sldata(i).t(i90) - postfl.sldata(i).t(i10);
end

% allocate some data for time saving
width_y = zeros(1,num_sls);
tm = zeros(1,num_sls);
c = zeros(1,num_sls);

for ic0=1:length(postfl.c0)
   disp(['POSTFL_MIXTIME:: analyze each stream line to get time (c0=' ...
         num2str(postfl.c0(ic0)) ') ...'])
   for i=1:num_sls
      postfl.sldata(i).i0 = locate(postfl.sldata(i).c, postfl.c0(ic0));
      postfl.sldata(i).x0 = postfl.sldata(i).x(postfl.sldata(i).i0);
      postfl.sldata(i).t0 = postfl.sldata(i).t(postfl.sldata(i).i0);
   
      % *** As the concentration data looks kind of noisy, something has to be
      % done to make sure the correct i0 is found.  i0 should be at
      % least monotonic
      if (i > 1) &&  (postfl.sldata(i).x0 > postfl.sldata(i-1).x0)
         disp(['WARNING:: Slower mixing for streamline #' num2str(i) ...
               ' at x0=' num2str(postfl.sldata(i).x0) '(' ...
               num2str(postfl.sldata(i-1).x0) ') (no change made!)'])
%         disp(['WARNING:: the x0 is reset for stream line # ' ...
%               num2str(i) ' from ' num2str(postfl.sldata(i).i0) [' ' ...
%                             'to '] num2str(postfl.sldata(i-1).i0-1)])
%             postfl.sldata(i).i0 = max([1, postfl.sldata(i-1).i0-1]); 
      end
      postfl.sldata(i).tm = postfl.sldata(i).t - postfl.sldata(i).t0;
   end
   
   % 4) calculate the average mixing time
   disp('POSTFL_MIXTIME:: Computing the folding time characteristics ...')
   for i=1:num_xs
      for isl=1:num_sls
         i_x = locate(postfl.sldata(isl).x, postfl.mtdata.x(i));
         width_y(isl) = postfl.sldata(isl).y(i_x);
         tm(isl) = postfl.sldata(isl).tm(i_x);
         c(isl) = postfl.sldata(isl).c(i_x);
      end
      width_y(1:num_sls-1) = width_y(2:end) - width_y(1:num_sls-1);
      width_y(num_sls) = width_y(num_sls-1)/1.2;
      i_negative = find(width_y < 0);
      if ~isempty(i_negative)  % negative width appears in 3D simulations
         width_y(i_negative) = width_y(max(1,i_negative-1));
      end
      
      tm(find(tm(:) < 0)) = 0; % set all pre-mixing time to zero

      postfl.mtdata.c_aver(i) = mean(c .* width_y)/mean(width_y);
      postfl.mtdata.t_aver(ic0,i) = mean(tm .*width_y)/mean(width_y);
      postfl.mtdata.t_delt(ic0,i) = sqrt(mean((tm- ...
                                               postfl.mtdata.t_aver(ic0,i)) ...
                                              .^2.*width_y)/mean(width_y));
      % quantize the mixing time to grids (tm not useful anymore)
%      tm = fix(tm/t_grid);
%      tm(find(tm < 1)) = 1;
%      tm(find(tm > num_ts)) = num_ts;
%      for i2=1:length(tm)
%         postfl.mtdata.n(tm(i2),i) = postfl.mtdata.n(tm(i2),i) + width_y(i2);
%      end
   end
   
   % 5) get the optimized parameter: earliest measurement time. This
   % is just taken as the error bar equals the averaged mixing time

   index = find(postfl.mtdata.t_aver(ic0,:) > postfl.mtdata.t_delt(ic0,:));
   %sqrt(postfl.mtdata.t_delt.^2 + 4e-5^2);
   if ~isempty(index)
      postfl.mtdata.i0(ic0) = index(1);
      postfl.mtdata.x0(ic0) = postfl.mtdata.x(postfl.mtdata.i0(ic0));
      postfl.mtdata.t0(ic0) = postfl.mtdata.t_aver(ic0,postfl.mtdata.i0(ic0));
      disp(['POSTFL_MIXTIME:: Earliest observation time is ' ...
            num2str(postfl.mtdata.t0(ic0)) ' at x=' ...
            num2str(postfl.mtdata.x0(ic0))])
   else
      disp('WARNING:: search for earliest observation time failed! ')
      postfl.mtdata.i0(ic0) = num_xs;
      postfl.mtdata.x0(ic0) = postfl.mtdata.x(postfl.mtdata.i0(ic0));
      postfl.mtdata.t0(ic0) = postfl.mtdata.t_aver(ic0,postfl.mtdata.i0(ic0));
   end
end
