function [haxes, hzoomaxes] = axes_create(num_xs, num_ys, varargin)
% --- Usage:
%        [haxes, hzoomaxes] = axes_create(num_xs, num_ys, varargin)
%
% --- Purpose:
%
% --- Parameter(s):
%        varargin: x0, y0, xmargin, ymargin, queensize, newfigure,
%        zoomaxes
%

% the lower left corner position
x0=0.1;
y0=0.1;
xmargin = 0.07; % good for full size plots
ymargin = 0.09;
queensize = 0;
newfigure = 0;
zoomaxes = 0;

parse_varargin(varargin);

% assume filling the hold frame
if ~exist('width', 'var')
   width = (1-x0-0.1+xmargin)/num_xs-xmargin;
end
if ~exist('height', 'var')
   height = (1-y0-0.1+ymargin)/num_ys-ymargin;
end

if (newfigure == 0);
   clf;
else
   figure;
end

if (queensize == 1)
   set(gcf, 'PaperPosition', [0.25,1,8,9]);
end

%linewidth = 0.6;
%fontsize = 12;
%set(gcf, 'PaperPosition', [0.25,1,8,9],'DefaultAxesFontName', 'Times', ...
%         'DefaultAxesFONTSIZE', fontsize, 'DefaultAxesLineWidth', ...
%         linewidth, 'DefaultLineLineWidth', linewidth);

for i=1:num_xs
   for j=1:num_ys
      haxes(i,j) = axes('Position', [x0+(width+xmargin)*(i-1), ...
                          y0+(height+ ymargin)*(num_ys-j), width, height]);
      cla, hold all, set(haxes(i,j), 'box', 'on');

      if (zoomaxes == 1) % add a zoomin axes to each one
         hzoomaxes(i) = axes('Position', [x0+(width+xmargin)*mod(i+1, ...
                                                           2)+width/2, ...
                             y0-(height+ ymargin)*fix((i-1)/2) + ...
                             height*2/5, width/2, height*3/5]);
         
         cla, hold all, set(gca, 'box', 'on');
      end
   end
end
