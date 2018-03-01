function result = postfl_plotres(postfl, file_prefix, varargin)

if ~exist('file_prefix')
   file_prefix = 'postfl';
end

% default streamline and cross section settings
if ~exist('sl', 'var')
   sl = linspace(postfl.slstart(2,1),postfl.slstart(2,end),11);
end
if ~exist('x', 'var')
   x = linspace(20,400,10)*1e-6;
end
geom=[];
parse_varargin(varargin)

% 1) whole geometry plot
if isfield(postfl, 'fem') && ~isempty(geom)
   clf
   postfl_plot(postfl, 'u')
   legend off
   title([])
   saveps(gcf, [file_prefix, '_cell_U.ps'])
   figure
end

% 2) direct simulation result

set(gcf, 'PaperPosition', [0.25,1,8,9], 'position', [56,270,600,660])
if isfield(postfl, 'sldata') && isfield(postfl, 'mtdata')
   % a) streamline y
   clf, hold all,
   oaxis=subplot(4,3,1);
   hold all, postfl_plot(postfl, 'sl', sl, 'y')
   if (postfl.num_dims == 3)
      postfl_plot(postfl, 'sl', sl, 'z')
   end
   delete(findobj(gca, 'Type', 'Text'));
   textstr{1}=['jet width: ' num2str(postfl.jetwidth,'%0.2g') '(' ...
               num2str(postfl.jetwidth_theory, '%0.2g') ')'];
   textstr{2}=['total number: ' int2str(length(postfl.slstart(1,: ...
                                                     ))) '(' ...
               int2str(postfl.num_points(1)) ')'];
   if (postfl.num_dims == 3)
      textstr{3} = ['start at z: '  num2str(postfl.slstart(3,1))];
   end
   puttext(0.2,0.9, textstr);
   title('Flow Profile'), legend off;
   
   subplot(4,3,4)
   hold all, postfl_plot(postfl, 'sl', sl, 'y')
   if (postfl.num_dims == 3)
      postfl_plot(postfl, 'sl', sl, 'z')
   end
   delete(findobj(gca, 'Type', 'Text'));
   xlim_now = get(gca, 'xlim');
   axis auto
   xlim([0, xlim_now(2)])
   title('Jet Profile'), legend off
   
   % b) u, v, w
   subplot(4,3,2)
   hold all, postfl_plot(postfl, 'sl',sl, 'u')
   title('Velocity of Streamlines'), legend off
   clear textstr
   if ~isfield(postfl.const, 'height')
      postfl.const.height = 0;
   end
   textstr{1} = ['inlet: ' num2str(postfl.const.v_sam, '%0.3f') ...
                 'm/s (' num2str(postfl.const.v_sam* ...
                                 postfl.const.width_inlet* ...
                                 postfl.const.height*6e10, '%0.1f') 'uL/min)'];
   textstr{2} = ['side: ' num2str(postfl.const.v_buf, '%0.3f') ...
                 'm/s (' num2str(postfl.const.v_buf* ...
                                 postfl.const.width_side* ...
                                 postfl.const.height*6e10, '%0.1f') 'uL/min)'];
   if isfield(postfl.const, 'v_dia')
      textstr{3} = ['diag: ' num2str(postfl.const.v_dia, '%0.3f') ...
                    'm/s (' num2str(postfl.const.v_dia* ...
                                    postfl.const.width_diag* ...
                                    postfl.const.height*6e10, '%0.1f') ...
                    'uL/min)'];

   end
   puttext(0.12,0.5, textstr);
   
   subplot(4,3,5), 
   hold all, postfl_plot(postfl, 'sl',sl, 'v')
   if (postfl.num_dims == 3)
      set(gcf, 'DefaultLineLineStyle', '--');
      postfl_plot(postfl, 'sl', sl, 'w')
   end
   title('V & W'), legend off

   % c) concentration
   subplot(4,3,3), 
   hold all, postfl_plot(postfl, 'sl',sl, 'c')
   title('Concentration'), legend off

   subplot(4,3,6), 
   hold all, postfl_plot(postfl, 'sl',sl, 'c_aver')
   title('Average Concentration'), legend off

   textstr{1}=['height: ' num2str(postfl.const.height)];
   textstr{2}=['inlet width: ' num2str(postfl.const.width_inlet, ...
                                        '%0.2g')];
   textstr{3}=['side width: ' num2str(postfl.const.width_side)];
   if (postfl.num_dims == 3) && isfield(postfl.const, 'width_diag')
      textstr{4} = ['diag width: '  num2str(postfl.const.width_diag)];
   end
   puttext(0.32,0.6, textstr);

   % d) time data related to folding
   subplot(4,3,7)
   hold all, postfl_plot(postfl, 'sl', sl, 't')
   title('Time from Zero Position'), legend off
   
   subplot(4,3,8)
   hold all, postfl_plot(postfl, 'sl',sl, 'tm')
   axis tight
   y_lim = get(gca, 'ylim');
   xlim auto, ylim([-y_lim(2)*0.02, y_lim(2)*1.04])
   title('Time from mixing'), legend off
   
   subplot(4,3,9), hold all
   postfl_plot(postfl, 'mt', 't_aver', 't_delt')
   ylim([0.0, postfl.mtdata.t_aver(end)+1e-7])
   legend off, title('Uncertainty of Time')

   subplot(4,3,10), hold all, 
   postfl_plot(postfl, 'sl', 'x0')
   title('Time Zero Position'), legend off

   % e) critical concentration dependence
   if (length(postfl.c0) > 1)
      subplot(4,3,11)
      hold all, postfl_plot(postfl, 'mt', 't0')
      legend off,   title([])
      delete(findobj(gca, 'Type', 'Text'));
      
      subplot(4,3,12)
      hold all, postfl_plot(postfl, 'mt', 'x0')
      legend off, title([])
      delete(findobj(gca, 'Type', 'Text'));
   end
   saveps(gcf, [file_prefix, '_res.ps'])
end
return
