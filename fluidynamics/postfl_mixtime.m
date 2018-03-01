function postfl = postfl_mixtime(postfl, varargin)
% --- Usage:
%        postfl = postfl_mixtime(postfl, varargin)
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
% $Id: postfl_mixtime.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $
%

if (nargin < 1)
   help postfl_mixtime
   return
end
sltime_only = 0;
parse_varargin(varargin);

[num_sls, num_xs] = size(postfl.sldata.x);
num_c0s = length(postfl.c0);

% 1) process each streamline first: critical concentration is the
% important parameter
postfl.sldata.c_aver = zeros(1,num_xs);
postfl.sldata.i0 = zeros(num_c0s, num_sls); % the index of the beginning
postfl.sldata.x0 = zeros(num_c0s, num_sls); 
postfl.sldata.t0 = zeros(num_c0s, num_sls);
postfl.sldata.tc = zeros(1, num_sls); % the mixing time 10%-90%
postfl.sldata.tm = zeros(num_sls, num_xs); % the post-folding tmie

% 2) the time distribution data
if ~exist('t') || isempty(t)
   t = linspace(0.0,1000e-6,51);
end
num_ts = length(t);
t_grid = (t(num_ts) - t(1))/(num_ts -1);

postfl.mtdata.t = t;
postfl.mtdata.n = zeros(num_ts, num_xs);
postfl.mtdata.x = postfl.sldata.x(1,:);
postfl.mtdata.t_aver = zeros(num_c0s, num_xs);
postfl.mtdata.t_delt = zeros(num_c0s, num_xs);
postfl.mtdata.i0 = zeros(1,num_c0s);
postfl.mtdata.x0 = zeros(1,num_c0s);
postfl.mtdata.t0 = zeros(1,num_c0s);

% 3) calculate the mixing time (this is rather seperate from others)
disp('POSTFL_MIXTIME:: calculate the mixing time from 10% to 90% ...')
for i=1:num_sls
   % as Hye Yoon suggested, take the time difference between 10 and
   % 90% percent mixed
   c_min = mean(postfl.sldata.c(i,1:10));
   c_max = mean(postfl.sldata.c(i,num_xs-50: num_xs));
   i10 = locate(postfl.sldata.c(i,:), c_min*0.9+c_max*0.1);
   i90 = locate(postfl.sldata.c(i,:), c_min*0.1+c_max*0.9);
   postfl.sldata.tc(i) = postfl.sldata.t(i,i90) - postfl.sldata.t(i,i10);
end

% 4) calcuation the folding time performance
disp('POSTFL_MIXTIME:: analyze each stream line to get elapsed time ...')
switch postfl.weight_mixtime
   case 1 % using the inverse speed as the weight
          % assuming the starting points have the same width
      disp('                 streamline weighting: inverse velocity ...')
      width_sls_ref = sqrt(postfl.sldata.u(:,1).^2 + ...
                           postfl.sldata.v(:,1).^2 + ...
                           postfl.sldata.w(:,1).^2);
      width_sls = width_sls_ref;
   case 2 % using the width as the weight
      disp('                 streamline weighting: extracted width ...')
      width_sls_before = zeros(num_sls,1); % the width between the
                                           % streamline and the one before
      
      width_sls_after = zeros(num_sls,1); % between the one and after
      width_sls = zeros(num_sls,1);
   otherwise
end

for ic0=1:length(postfl.c0)
   disp(['POSTFL_MIXTIME:: critical concentration c0=' ...
         num2str(postfl.c0(ic0))])   
   for i=1:num_sls
      postfl.sldata.i0(ic0,i) = locate(postfl.sldata.c(i,:), postfl.c0(ic0));
   
      % *** As the concentration data looks kind of noisy, something has to be
      % done to make sure the correction i0 is found.  i0 should be at
      % least monotonic

      if (i > 1) &&  (postfl.sldata.i0(ic0,i) > postfl.sldata.i0(ic0,i-1))
         if isfield(postfl, 'force_mixorder') && (postfl.force_mixorder ~= 0)
            disp(['WARNING:: i0 is reset for stream line # ' num2str(i) ...
                  ' from ' num2str(postfl.sldata.i0(ic0,i)) ' to ' ...
                  num2str(postfl.sldata.i0(ic0,i-1)-1)])
            postfl.sldata.i0(ic0,i) = max([1, postfl.sldata.i0(ic0,i-1)-1]);
         else
            disp(['WARNING:: i0='  int2str(postfl.sldata.i0(ic0,i)) ...
                  ' of stream line #' int2str(i) ' > ' 'i0=' ...
                  int2str(postfl.sldata.i0(ic0,i-1)-1) ' of #' int2str(i-1)])
         end
      end
      postfl.sldata.t0(ic0,i) = postfl.sldata.t(i,postfl.sldata.i0(ic0,i));
      postfl.sldata.x0(ic0,i) = postfl.sldata.x(i,postfl.sldata.i0(ic0,i));
      postfl.sldata.tm(i,:) = postfl.sldata.t(i,:) - postfl.sldata.t0(ic0,i);
   end
   
   index_dummy = find(postfl.sldata.i0(ic0,:) >= num_xs);
   if ~isempty(index_dummy)
      disp(['WARNING:: some streamlines are not mixed even in the end!!!'])
      disp(['  They are:' num2str(index_dummy)])
   end
   
   if (sltime_only == 1); continue; end
   
   % 4) calculate the average mixing time
   tm = zeros(num_sls,1);
   for i=1:num_xs
      % computer the weight of each streamline
      switch postfl.weight_mixtime
         case 1 % using the inverse speed as the weight
            switch(postfl.num_dims)
               case 2
                  width_sls(:) = width_sls_ref ./ ...
                      sqrt(postfl.sldata.u(:,i).^2 + ...
                           postfl.sldata.v(:,i).^2);
%                 if (mod(i,100) == 0) plot(width_sls); end
               case 3
                  width_sls(:) = width_sls_ref./ ...
                      sqrt(postfl.sldata.u(:,i).^2 + ...
                           postfl.sldata.v(:,i).^2 + postfl.sldata.w(:, i).^2);
               otherwise
            end
         case 2 % using the width as the weight
            width_sls_after(1:(num_sls-1),1) = postfl.sldata.y(2:end,i) ...
                - postfl.sldata.y(1:(num_sls-1),i);
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
         otherwise
      end

      tm(:) = postfl.sldata.tm(:,i);
      tm(find(tm(:) < 0),1) = 0; % set all pre-mixing time to zero
      postfl.sldata.c_aver(i) = mean(postfl.sldata.c(:,i) .* ...
                                     width_sls)/mean(width_sls);
      postfl.mtdata.t_aver(ic0,i) = mean(tm.*width_sls)/mean(width_sls);
      postfl.mtdata.t_delt(ic0,i) = sqrt(mean(((tm - ...
                                               postfl.mtdata.t_aver(ic0,i)) ...
                                              .^2).*width_sls)/mean(width_sls));
      % quantize the mixing time to grids (tm not useful anymore)
      tm(:) = fix(tm/t_grid);
      tm(find(tm < 1)) = 1;
      tm(find(tm > num_ts)) = num_ts;
      for i2=1:length(tm)
         postfl.mtdata.n(tm(i2),i) = postfl.mtdata.n(tm(i2),i) + width_sls(i2);
      end
   end
   
   % 5) get the optimized parameter: earliest measurement time. This
   % is just taken as the error bar equals the averaged mixing time

   % this form is importance as we want to find the LAST position
   % where the t_delt is larger than t_aver
   if isfield(postfl.const, 'width_beam') && (postfl.const.width_beam ~= 0)
      disp(['INFO:: adding finite beam size effect (' ...
            num2str(postfl.const.width_beam) ')'])
      postfl.mtdata.t_delt(ic0,:) = sqrt(postfl.mtdata.t_delt(ic0,:).^2 ...
                                         + (postfl.const.width_beam/ ...
                                            (postfl.const.v_sam + ...
                                             2*postfl.const.v_buf)/ 1.5)^2);
   end
                                    
   index = find(postfl.mtdata.t_aver(ic0,:) < postfl.mtdata.t_delt(ic0,:));
   if ~isempty(index)
      postfl.mtdata.i0(ic0) = min([index(end)+1, num_xs]);
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
