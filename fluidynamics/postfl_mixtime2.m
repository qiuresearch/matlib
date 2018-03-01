function postfl = postfl_mixtime2(postfl, varargin)
% --- Usage:
%        postfl = postfl_mixtime_sl(postfl, varargin)
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
% $Id: postfl_mixtime2.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $
%

if (nargin < 1)
   help postfl_mixtime_sl
   return
end
sltime_only = 0;
parse_varargin(varargin);

% 1) initialize the x data
num_sls = length(postfl.sldata);
x_grid = abs(postfl.sldata(1).x(2) - postfl.sldata(1).x(1));
x = postfl.sldata(1).x(1):x_grid:postfl.sldata(1).x(end);
num_xs = length(x);

disp(['POSTFL_MIXTIME2:: number of streamlines: ' int2str(num_sls) ...
      ', x_grid: ' num2str(x_grid) ])
disp(['                  range: (' num2str(postfl.sldata(1).x(1)) ...
      ', ' num2str(postfl.sldata(1).x(end)) '), number of xs: ' ...
      num2str(num_xs)])

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

% 3) calculate the "mixing time"

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
width_sls = zeros(1,num_sls);
tm = zeros(1,num_sls);
c = zeros(1,num_sls);

disp('POSTFL_MIXTIME2:: compute the folding time characteristics ...')
switch postfl.weight_mixtime
   case 1 % using the inverse speed as the weight
          % assuming the starting points have the same width
      disp('                  streamline weighting: inverse velocity ...')
      for i=1:num_sls
         width_sls_ref(i) = sqrt(postfl.sldata(i).u(1).^2 + ...
                                 postfl.sldata(i).v(1).^2 + ...
                                 postfl.sldata(i).w(1).^2);
      end
      width_sls = width_sls_ref;
   case 2 % using the width as the weight
      disp('                  streamline weighting: extracted width ...')
      width_sls_before = zeros(num_sls,1); % the width between the
                                           % streamline and the one before
      
      width_sls_after = zeros(num_sls,1); % between the one and after
      width_sls = zeros(num_sls,1);
   otherwise
end

for ic0=1:length(postfl.c0)
   disp(['POSTFL_MIXTIME2:: critical concentration c0=' ...
         num2str(postfl.c0(ic0))])
   for i=1:num_sls
      [dummy, postfl.sldata(i).i0] = min(abs(postfl.sldata(i).c- ...
                                             postfl.c0(ic0)));
      postfl.sldata(i).x0 = postfl.sldata(i).x(postfl.sldata(i).i0);
      postfl.sldata(i).t0 = postfl.sldata(i).t(postfl.sldata(i).i0);
   
      % *** As the concentration data looks kind of noisy, something has to be
      % done to make sure the correct i0 is found.  i0 should be at
      % least monotonic
      if (i > 1) &&  (postfl.sldata(i).x0 > postfl.sldata(i-1).x0)
         disp(['WARNING:: slower mixing for streamline #' num2str(i) ...
               ' at x0=' num2str(postfl.sldata(i).x0, '%0.2e') '>' ...
               num2str(postfl.sldata(i-1).x0, '%0.2e') '(NO RESET!)'])
%         disp(['WARNING:: the x0 is reset for stream line # ' ...
%               num2str(i) ' from ' num2str(postfl.sldata(i).i0) [' ' ...
%                             'to '] num2str(postfl.sldata(i-1).i0-1)])
%             postfl.sldata(i).i0 = max([1, postfl.sldata(i-1).i0-1]); 
      end
      postfl.sldata(i).tm = postfl.sldata(i).t - postfl.sldata(i).t0;
   end

   if (sltime_only == 1); continue; end
   
   % 4) calculate the average mixing time
   for i=1:num_xs
      for isl=1:num_sls
         [dummy, i_x] = min(abs(postfl.sldata(isl).x-postfl.mtdata.x(i)));
         tm(isl) = postfl.sldata(isl).tm(i_x);
         c(isl) = postfl.sldata(isl).c(i_x);
         width_sls(isl) = postfl.sldata(isl).y(i_x);
         if (postfl.weight_mixtime == 1) % the inverse speed as weight
            width_sls(isl) = width_sls_ref(isl)/ sqrt( ...
                postfl.sldata(isl).u(i_x).^2+postfl.sldata(isl).v(i_x).^2 ...
                +postfl.sldata(isl).w(i_x).^2);
         end
      end
      if (postfl.weight_mixtime == 2) % using the width as the weight
         width_sls_after(1:(num_sls-1),1) = width_sls(2:end) - ...
             width_sls(1:(num_sls-1));
         width_sls_after(num_sls,1) = width_sls_after(num_sls-1);
         % this assumption may be very wrong
         width_sls_before(:,1) = [width_sls_after(1,1); ...
                             width_sls_after(1: (num_sls-1),1)];
         
         % negative stream line width may happen in 3D case
         i_negative = find(width_sls_after < 0);
         if ~isempty(i_negative)
            disp(['WARNING:: negative stream line width found for ' ...
                  num2str(length(i_negative)) ' streamlines at x=' ...
                  num2str(postfl.mtdata.x(i)) '!'])
            %         if (i_negative(1) == 1) % if the first is negative
            %            width_sls = 
            %         end
            width_sls_after(i_negative,1) = 0; % width_sls_after(i_negative-1);
            if (i_negative(end) ~= num_sls)
               width_sls_before(i_negative+1,1) = 0; % width_sls_before(i_negative+2);            
            else  % if the last is negative
               width_sls_before(i_negative(1:end-1)+1,1)=0;
            end
            
         end
         width_sls(:) = (width_sls_before + width_sls_after)/2;
         width_sls = reshape(width_sls, 1, num_sls);
      end
      
      %
      tm(find(tm(:) < 0)) = 0; % set all pre-mixing time to zero
      postfl.mtdata.c_aver(i) = mean(c .* width_sls)/mean(width_sls);
      postfl.mtdata.t_aver(ic0,i) = mean(tm .*width_sls)/mean(width_sls);
      postfl.mtdata.t_delt(ic0,i) = sqrt( mean(( tm- postfl.mtdata ...
                                                 .t_aver(ic0,i)) ...
                                               .^2.*width_sls)/ ...
                                          mean(width_sls));
   end
   
   % 5) get the optimized parameter: earliest measurement time. This
   % is just taken as the error bar equals the averaged mixing time

   index = find(postfl.mtdata.t_aver(ic0,:) > postfl.mtdata.t_delt(ic0,:));
   if ~isempty(index)
      postfl.mtdata.i0(ic0) = index(1);
      postfl.mtdata.x0(ic0) = postfl.mtdata.x(postfl.mtdata.i0(ic0));
      postfl.mtdata.t0(ic0) = postfl.mtdata.t_aver(ic0,postfl.mtdata.i0(ic0));
   else
      disp('WARNING:: search for earliest observation time failed! ')
      postfl.mtdata.i0(ic0) = num_xs;
      postfl.mtdata.x0(ic0) = postfl.mtdata.x(postfl.mtdata.i0(ic0));
      postfl.mtdata.t0(ic0) = postfl.mtdata.t_aver(ic0,postfl.mtdata.i0(ic0));
   end
   disp(['   c0=' num2str(postfl.c0(ic0), '%0.2f') ', T0=' ...
         num2str(postfl.mtdata.t0(ic0)*1e6,'%0.2f'), 'us, at x0=' ...
         num2str(postfl.mtdata.x0(ic0)*1e6,'%0.2f') 'um'])
end
