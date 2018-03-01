function handle = postfl_plot(postfl, varargin)
% --- Usage:
%        handle = postfl_plot(postfl, varargin)
% --- Purpose:
%        variety of plots for postfl data structure
% --- Parameter(s):
%
% --- Return(s):
%        results -
%
% --- Example(s):
%
% $Id: postfl_plot.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $
%

if (nargin < 1)
   help postfl_plot
   return
end

% 1) list of used plot parameters
x=[];  sl=[];  mt=[]; tasx=[];

y=[]; z=[]; u=[]; v=[]; w=[]; c=[]; t=[]; tm=[]; tc=[]; i0=[]; t0=[]; ...
  x0= [];  c_aver=[]; t_aver=[]; t_delt=[]; t_dist=[]; tasx=[]; tmasx=[];
jet=[]; slstart=[];

label_x = []; label_y = []; title_plot = []; lege_plot = []; linespec = '';

parse_varargin(varargin);
num_fls = length(postfl);

% 2) default parameters

% 3) well, plot as you wish

lege_plot = {};
text_plot = {};

set(gca, 'ylimmode', 'auto', 'ytickmode', 'auto')

if isempty(x) && isempty(sl) && isempty(mt) % plot all the geometry
   title_plot=[];
   lege_plot=[];
   if ~isempty(u)
      postplot(postfl.fem, ...
               'tridata',{'U_ns','cont','internal'}, ...
               'trimap','jet(1024)', ...
               'title','Surface: Velocity field', ...
               'refine',2);
   end
   if ~isempty(c)
      postplot(postfl.fem, ...
               'tridata',{'C_ns','cont','internal'}, ...
               'trimap','jet(1024)', ...
               'title','Surface: Concentration field', ...
               'refine',2);
   end
   if ~isempty(slstart)
      switch postfl.num_dims
         case 1
            disp('ERROR:: no streamline in case of 1D!')
         case 2
            femdata=postplot(postfl.fem, ...
                             'flowdata',{'u','v'}, ...
                             'flowcolor',[1.0,0.0,0.0], ...
                             'flowstart',slstart, ...
                             'flowtype','line', ...
                             'solnum',1, 'geom', 'on', ...
                             'flowback', 'off', 'flowstattol',0.1);
         case 3
            femdata=postplot(postfl.fem, ...
                             'flowdata',{'u','v','w'}, ...
                             'flowcolor',[1.0,0.0,0.0], ...
                             'flowstart',slstart, ...
                             'flowtype','line', ...
                             'solnum',1, 'geom', 'off', ...
                             'flowback', 'off', 'flowstattol',0.1);
         otherwise
      end            
   end
end

if ~isempty(x) && isempty(sl) && isempty(mt) % cross section plot at x
                                             % values
   num_xs = length(x);
   index_xs = zeros(1, num_xs);
   title_plot = 'Cross section view along x direction';
   label_x = 'Distance from center (m)';
   for ifl=1:length(postfl)
      for i=1:num_xs
         index_xs(i) = locate(postfl(ifl).x(1,:), x(i));
         if ~isempty(u)
            plot(postfl(ifl).y(:,index_xs(i)), postfl(ifl).u(:, index_xs(i)));
            label_y = 'u (m/s)';
         end
         if ~isempty(v)
            plot(postfl(ifl).y(:,index_xs(i)), postfl(ifl).v(:, index_xs(i)));
            label_y = 'v (m/s)';
         end
         if ~isempty(c)
            plot(postfl(ifl).y(:,index_xs(i)), postfl(ifl).c(:, ...
                                                             index_xs(i)));
            label_y = 'concentration';
         end
         lege_plot{i+(ifl-1)*num_xs} = ['@x=', num2str(x(i))];
      end
   end
end

%************************************************************************%
%
% postfl.sldata is an array of structure
%
%************************************************************************%
if ~isempty(sl) && (length(postfl.sldata) > 1)% streamline plot given starting y values
   num_sls = length(sl);
   index_sls = zeros(1,num_sls);
   title_plot = 'Physical parameters along each stream line';
   label_x = 'flow direction (m)';
   for ifl=1:length(postfl)
      
      if ~isempty(c_aver) % here the c_aver is saved in postfl.mtdata
         label_x = 'Position along the flow (m)';
         label_y = '<concentration>';
         lege_plot{ifl} = ['model no. ', num2str(ifl)];
         plot(postfl(ifl).mtdata.x, postfl(ifl).mtdata.c_aver);
      end

      if ~isempty(tc) % plot the critical time (mixing time) of
                      % each streamline
         label_x = 'Streamline starting position (m)';
         label_y = 'the mixing time (s)';
         lege_plot{ifl} = ['model no. ', num2str(ifl)]; 
         plot(postfl(ifl).slxyz(2,:), [postfl(ifl).sldata(:).tc]);
      end
      
      if ~isempty(i0) % plot the critical time (mixing time) of streamlines
         label_x = 'Streamline starting position (m)';
         label_y = 'index of folding start';
         lege_plot{ifl} = ['model no. ', num2str(ifl)];
         plot(postfl(ifl).slxyz(2,:), [postfl(ifl).sldata(:).i0]);
      end
      
      if ~isempty(t0) % plot the critical time (mixing time) of streamlines
         label_x = 'Streamline starting position (m)';
         label_y = 'folding start time (s)';
         lege_plot{ifl} = ['model no. ', num2str(ifl)];
         plot(postfl(ifl).slxyz(2,:), [postfl(ifl).sldata(:).t0]);
      end

      if ~isempty(x0) % plot the critical time (mixing time) of streamlines
         label_x = 'Streamline starting position (m)';
         label_y = 'folding starting position (m)';
         lege_plot{ifl} = ['model no. ', num2str(ifl)];
         plot(postfl(ifl).slxyz(2,:), [postfl(ifl).sldata(:).x0]);
      end
      
      if isempty(x) % plot "var" vs. x for each streamline
         for i=1:num_sls
            index_sls(i) = locate(postfl(ifl).slstart(2,:), sl(i));
            xdata = postfl(ifl).sldata(index_sls(i)).x;
            if ~isempty(tasx) % t as x axis
               label_x = 'elapsed time (s)';
               xdata = postfl(ifl).sldata(index_sls(i)).t;
            end
            if ~isempty(tmasx) % tm as x axis
               label_x = 'elapsed time since mixing (s)';
               xdata = postfl(ifl).sldata(index_sls(i)).tm;
            end
            if ~isempty(y)
               plot(xdata, postfl(ifl).sldata(index_sls(i)).y);
               label_y = 'y (m)'; 
            end
            if ~isempty(u)
               plot(xdata, postfl(ifl).sldata(index_sls(i)).u);
               label_y = 'u (m/s)';
            end
            if ~isempty(v)
               plot(xdata, postfl(ifl).sldata(index_sls(i)).v);
               label_y = 'v (m/s)';
            end
            if ~isempty(c)
               plot(xdata, postfl(ifl).sldata(index_sls(i)).c);
               label_y = 'concentration';
            end
            if ~isempty(t)
               plot(xdata, postfl(ifl).sldata(index_sls(i)).t);
               label_y = 'total time (s)';
            end
            if ~isempty(tm)
               plot(xdata, postfl(ifl).sldata(index_sls(i)).tm);
               label_y = 'elapsed time after mixing (s)';
            end
         
            if isempty(tc) && isempty(i0) && isempty(x0) && isempty(t0) ...
                   && isempty(c_aver)
               lege_plot{i+(ifl-1)*num_sls} = ['from y=', num2str(sl(i))];
            end
            
         end
         if ~isempty(y)
            text_plot = {text_plot{:}, ['jet width=' ...
                                num2str(postfl(ifl).jetwidth) '(' ...
                                num2str(postfl(ifl).jetwidth_theory) ')']};
         end
      end % if isempty(x)
   end % for ifl=1:length(postfl)
end % if ~isempty(sl)

%************************************************************************%
%
% postfl.sldata is just ONE structure
%
%************************************************************************%
if ~isempty(sl) && (length(postfl.sldata) == 1)% streamline plot
                                               % given starting y
                                               % values
   num_sls = length(sl);
   index_sls = zeros(1,num_sls);
   title_plot = 'Physical parameters along each stream line';
   label_x = 'flow direction (m)';
   for ifl=1:length(postfl)
      
      if ~isempty(c_aver)
         label_x = 'Position along the flow (m)';
         label_y = '<concentration>';
         lege_plot{ifl} = ['model no. ', num2str(ifl)];
         plot(postfl(ifl).sldata.x(1,:), postfl(ifl).sldata.c_aver);
      end
      
      if ~isempty(tc) % plot the critical time (mixing time) of
                      % each streamline
         label_x = 'Streamline starting position (m)';
         label_y = 'the mixing time (s)';
         lege_plot{ifl} = ['model no. ', num2str(ifl)]; 
         plot(postfl(ifl).sldata.y(:,1), postfl(ifl).sldata.tc);
      end
      
      if ~isempty(i0) % plot the critical time (mixing time) of streamlines
         label_x = 'Streamline starting position (m)';
         label_y = 'index of folding start (s)';
         lege_plot{ifl} = ['model no. ', num2str(ifl)];
         plot(postfl(ifl).sldata.y(:,1), postfl(ifl).sldata.i0);
      end
      
      if ~isempty(t0) % plot the critical time (mixing time) of streamlines
         label_x = 'Streamline starting position (m)';
         label_y = 'folding start time (s)';
         lege_plot{ifl} = ['model no. ', num2str(ifl)];
         plot(postfl(ifl).sldata.y(:,1), postfl(ifl).sldata.t0);
      end

      if ~isempty(x0) % plot the critical time (mixing time) of streamlines
         label_x = 'Streamline starting position (m)';
         label_y = 'folding starting position (m)';
         lege_plot{ifl} = ['model no. ', num2str(ifl)];
         plot(postfl(ifl).sldata.y(:,1), postfl(ifl).sldata.x0);
      end
      
      if isempty(x)
         for i=1:num_sls
            % plot "var" vs. x for each streamline
            index_sls(i) = locate(postfl(ifl).sldata.y(:,1), sl(i));
            xdata = postfl(ifl).sldata.x(index_sls(i),:);
            if ~isempty(tasx) % t as x axis
               label_x = 'elapsed time (s)';
            xdata = postfl(ifl).sldata.t(i,:);
            end
            if ~isempty(tmasx) % tm as x axis
               label_x = 'elapsed time since mixing (s)';
               xdata = postfl(ifl).sldata.tm(i,:);
            end
            if ~isempty(y)
               plot(xdata, postfl(ifl).sldata.y(index_sls(i), :));
               label_y = 'y (m)'; 
            end
            if ~isempty(z)
               plot(xdata, postfl(ifl).sldata.z(index_sls(i), :));
               label_y = 'z (m)'; 
            end
            if ~isempty(u)
               plot(xdata, postfl(ifl).sldata.u(index_sls(i), :));
               label_y = 'u (m/s)';
            end
            if ~isempty(v)
               plot(xdata, postfl(ifl).sldata.v(index_sls(i), :));
               label_y = 'v (m/s)';
            end
            if ~isempty(w)
               plot(xdata, postfl(ifl).sldata.w(index_sls(i), :));
               label_y = 'w (m/s)';
            end
            if ~isempty(c)
               plot(xdata, postfl(ifl).sldata.c(index_sls(i), :));
               label_y = 'concentration';
            end
            if ~isempty(t)
               plot(xdata, postfl(ifl).sldata.t(index_sls(i), :));
               label_y = 'total time (s)';
            end
            if ~isempty(tm)
               plot(xdata, postfl(ifl).sldata.tm(index_sls(i), :));
               label_y = 'elapsed time after mixing (s)';
            end
         
            if isempty(tc) && isempty(i0) && isempty(x0) && isempty(t0) ...
                   && isempty(c_aver)
               lege_plot{i+(ifl-1)*num_sls} = ['from y=', num2str(sl(i))];
            end
            
         end
         if ~isempty(y)
            text_plot = {text_plot{:}, ['jet width=' ...
                                num2str(postfl(ifl).jetwidth) '(' ...
                                num2str(postfl(ifl) .jetwidth_theory) ')']};
         end
      end

      if ~isempty(x)   % plot cross-sections on the stream lines
         num_xs = length(x);
         index_xs = zeros(1, num_xs);
         label_x = 'Distance from center (m)';
         for i=1:num_xs
            index_xs(i) = locate(postfl(ifl).sldata.x(1,:), x(i));
            lege_plot{i+(ifl-1)*num_xs} = ['@x=', num2str(x(i))];

            if ~isempty(jet)
               y = postfl(ifl).sldata.y(:, index_xs(i))';
               z = postfl(ifl).sldata.z(:, index_xs(i))';
               % sort by z
               [z, i_sort] = sort(z);
               y = y(i_sort);
               zy_ubd = getcontour1(z, y, postfl.const.height/100);
               z=zy_ubd(:,1)';
               y=zy_ubd(:,2)';
               % make up the matrix and plot               
               y = [y, fliplr(-y), -y, fliplr(y), y(1)];
               z = [z, fliplr(z), -z, fliplr(-z), z(1)];
               area(z,y, 'FaceColor', 'blue', 'EdgeColor', 'blue')
               set(gca, 'View', [90,90])
               title_plot = ['Jet shape cross section at x=' num2str(x(i))];
               label_y = 'Distance from center (m)';
               label_x = 'Depth (m)';
               lege_plot = [];
            end

            if ~isempty(u)
               plot(postfl(ifl).sldata.y(:, index_xs(i)), ...
                    postfl(ifl).sldata.u(:, index_xs(i)));
               label_y = 'u (m/s)';
            end
            if ~isempty(v)
               plot(postfl(ifl).sldata.y(:, index_xs(i)), ...
                    postfl(ifl).sldata.v(:, index_xs(i)));
               label_y = 'v (m/s)';
            end
            if ~isempty(c)
               plot(postfl(ifl).sldata.y(:, index_xs(i)), ...
                    postfl(ifl).sldata.c(:, index_xs(i)));
               label_y = 'concentration';
            end
            if ~isempty(t)
               plot(postfl(ifl).sldata.y(:, index_xs(i)), ...
                    postfl(ifl).sldata.t(:, index_xs(i)));
               label_y = 'total time (s)';
            end
            if ~isempty(tm)
               plot(postfl(ifl).sldata.y(:, index_xs(i)), ...
                    postfl(ifl).sldata.tm(:, index_xs(i)));
               label_y = 'elapsed time after mixing (s)';
            end
         end % loop var: i
      end 
   end  % loop var: ifl
end

if ~isempty(mt) % mixing time plot
   title_plot = 'mixing time data';
   label_x = 'flow direction (m)';
   label_y = 'mixing time (s)';
   for ifl=1:length(postfl)
      text_plot = {text_plot{:}, ['c0: ' num2str(postfl(ifl).c0(end))], ...
                   ['t0: ' num2str(postfl(ifl).mtdata.t0(end))], ...
                   ['x0: ' num2str(postfl(ifl).mtdata.x0(end))]};
      if ~isempty(t_aver)
         plot(postfl(ifl).mtdata.x, postfl(ifl).mtdata.t_aver);
         lege_plot = {lege_plot{:}, ['"folding time" of model ' num2str(ifl)]};
      end
      if ~isempty(t_delt)
         plot(postfl(ifl).mtdata.x, postfl(ifl).mtdata.t_delt);
         lege_plot = {lege_plot{:}, ['"error bar" of model ' num2str(ifl)]};
      end
      if ~isempty(t_dist) && ~isempty(x) 
         % the mixing time distribution at one crosssection
         num_xs = length(x);
         index_xs = zeros(1, num_xs);
         label_x = 'time bin (s)';
         label_y = 'number of points';
         for i=1:num_xs
            index_xs(i) = locate(postfl(ifl).mtdata.x, x(i));
            plot(postfl(ifl).mtdata.t, postfl(ifl).mtdata.n(:, index_xs(i)));
            lege_plot{i+(ifl-1)*num_xs} = ['@x=', num2str(x(i))];
         end % loop var: i
      end
      if ~isempty(t0)
         label_x = 'threshold concentration';
         label_y = 'earliest measurement time (s)';
         plot(postfl(ifl).c0, postfl(ifl).mtdata.t0);
         lege_plot = {lege_plot{:}, ['t0 of model ' num2str(ifl)]};
      end
      if ~isempty(x0)
         label_x = 'threshold concentration';
         label_y = 'earliest measurement position (m)';
         plot(postfl(ifl).c0, postfl(ifl).mtdata.x0);
         lege_plot = {lege_plot{:}, ['x0 of model ' num2str(ifl)]};
      end
      if ~isempty(i0)
         label_x = 'threshold concentration';
         label_y = 'earliest measurement index';
         plot(postfl(ifl).c0, postfl(ifl).mtdata.i0);
         lege_plot = {lege_plot{:}, ['i0 of model ' num2str(ifl)]};
      end
   end
end

axis tight
zoomout(0.94);
% the labels and legends
if ~isempty(title_plot)
   title(title_plot)
end
if ~isempty(label_x)
   xlabel(label_x);
end
if ~isempty(label_y)
   ylabel(label_y);
end
if ~isempty(lege_plot)
   legend(lege_plot);
end
if ~isempty(text_plot)
   puttext(0.16,0.8,text_plot)
end
