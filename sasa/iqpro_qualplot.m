function [hf, iqpro] = iqpro_qualplot(iqpro, varargin)
% --- Usage:
%        [hfig, iqpro] = iqpro_qualplot(iqpro, varargin)
%
% --- Purpose:
%
% --- Parameter(s):
%        iqpro - a 2D array or a structure with .data, .title or .label
%        varargin - 'newfigure', 'hidden', 'ploterr',
%        'match_range', 'guinier_range'
% --- Return(s): 
%
% --- Example(s):
%
% $Id: iqpro_qualplot.m,v 1.12 2015/11/09 16:26:04 schowell Exp $

global colororder
global symbolorder
newfigure = 1;
hidden = 0;
ploterr = 1;
do_saveps = 1;
linewidth = 1;
scale_rg = 0;
pub = 0;

parse_varargin(varargin);

if ~exist('savename', 'var') || isempty(savename)
   savename = 'noname';
end

style_plot={'-', '-.', '--', ':'};
scrsz = get(0,'ScreenSize');
varargin_figure = { 'PaperPosition', [0.25,2,8,7], 'defaultlinelinewidth', ...
                    0.5, 'defaultaxeslinewidth', 0.4, ...
                    'DefaultAxesFontSize', 10, 'DefaultLineMarkerSize', ...
                    10, 'DefaultTextFontSize', 10}; % 'position', [1 ...
                                                    %  1,scrsz(3), scrsz(4)]}; % [26,270,600,660]};
% if a 2D array is passed
if ~isstruct(iqpro(1))
   iqpro = xypro_init(iqpro);
   iqpro.title = strrep(inputname(1), '_', '-');
end

% create a new figure or use passed
%figure_format('smallprint');
if (newfigure == 1)
   if (hidden == 1)
      hf=figure('visible', 'off', varargin_figure{:});
   else
      hf=figure(varargin_figure{:});
   end
else
   hf=gcf;
   clf(hf);
   position = get(hf, 'Position');
   varargin_figure{end} = position;
   set(hf, varargin_figure{:});
end
figure_fullsize(hf);
height = 4.8;
width = 5.5;
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperSize', [width height]);
set(gcf, 'PaperPosition', [0 0 width height]); % last 2 are width/height.
set(gcf, 'renderer', 'painters');

if exist('guinier_range', 'var') && ~isempty(guinier_range)
   [iqpro.guinier_range] = deal(guinier_range);
end
if exist('match_range', 'var') && ~isempty(match_range)
   [iqpro.match_range] = deal(match_range);
end
if exist('match_data', 'var') && ~isempty(match_data)
   [iqpro.match_data] = deal(match_data);
end
if exist('match_scale', 'var') && ~isempty(match_scale)
   [iqpro.match_scale] = deal(match_scale);
end
if exist('match_offset', 'var') && ~isempty(match_offset)
   [iqpro.match_offset] = deal(match_offset);
end

%iqpro = xypro_dataprep(iqpro);

% action!
num_data = length(iqpro);
iq_max = zeros(num_data,1);
logiq_range = zeros(num_data,2);
giq_offset = zeros(num_data,1);
guinier_max = zeros(num_data,1);
for i=1:num_data
   if isfield(iqpro(i), 'match_data'); 
      match_data = iqpro(i).match_data;
   else
      match_data = iqpro(1).data; 
   end
   if isfield(iqpro(i), 'match_range'); 
      match_range = iqpro(i).match_range;
   else
      match_range = [0.02, 0.05];  
   end
   if isfield(iqpro(i), 'match_scale'); 
      match_scale = iqpro(i).match_scale;
   else
      match_scale = 1;
   end
   if isfield(iqpro(i), 'match_offset'); 
      match_offset = iqpro(i).match_offset;
   else
      match_offset = 0;
   end

   if isfield(iqpro(i), 'guinier_range');
      guinier_range = iqpro(i).guinier_range;
   else
      guinier_range = [iqpro(i).data(1,1), iqpro(i).data(10,1)];
   end
   guinier_max(i) = guinier_range(2);
   
   % 0) get the data
   if exist('min_x2', 'var')
       [iq, scale, ~, ~] = scale_offset(iqpro(i).data, match_data, ...
           'match_range', match_range, 'scale', match_scale, ...
           'offset', match_offset);
   else
       [iq, scale, ~] = match(iqpro(i).data, match_data, match_range, ...
           'scale', match_scale, 'offset', match_offset);
   end
   
   % 1) raw I(Q) in linear form
   subplot(2,2,1); hold all;
   xyplot(iq, 'linewidth', linewidth);
   
   % 2) log-log format
   subplot(2,2,2); hold all;
   set(gca, 'xscale', 'log', 'yscale', 'log');
   if (ploterr == 1)
      [~, c] = size(iq);
      if c > 3
          h = errorbar(iq(:,1),iq(:,2),iq(:,4)); %, 'linewidth', linewidth);
      else
          h = errorbar(iq(:,1),iq(:,2),iq(:,3)); %, 'linewidth', linewidth);
      end
      remove_error_bar_ends(h)
   else
      plot(iq(:,1),iq(:,2));
   end
   iq_max(i) = max(iq(:,2));
   
   % 3) quinier
   subplot(2,2,3); hold all;
   rg_fitres(i) = rgfit(iq, guinier_range)
   iqpro(i).rg_fitres = rg_fitres(i);
   giq = guinier(iq);
   if scale_rg
       if i == 1
           d_giq = - abs(giq(1,2) - (rg_fitres(i).data(1,2) - rg_fitres(i).data(end,2) ))/20
       end
       giq_offset(i) = (i-1) * d_giq
       giq(:,2) = giq(:,2) + giq_offset(i); % scale the data for improved visibility
   end
   hplot(i) = xyplot(giq, symbolorder{i}, 'Color', colororder(i,:), ...
       'linewidth', linewidth);
   i_giq_max = locate(giq(:,1), guinier_range(2)^2*2);
   logiq_range(i,:) = [min(giq(1:i_giq_max,2)), max(giq(1:i_giq_max,2))];
   
   if exist('kratky_match_range','var')
       % if exist('min_x2', 'var')
       %     [iq, scale, ~, ~] = scale_offset(iqpro(i).data, match_data, ...
       %         'match_range', kratky_match_range, 'scale', match_scale, ...
       %         'offset', match_offset);
       % else
       [iq, scale, ~] = match(iqpro(i).data, match_data, ...
           kratky_match_range, 'scale', match_scale, 'offset', match_offset);
       % end
   else
       kratky_match_range = match_range;
   end
   % 4) kratky
   subplot(2,2,4); hold all; 
   xyplot(kratky(iq), 'linewidth', linewidth);
   
   lege{i} = [iqpro(i).title(1:min(15,end)) num2str(scale, ', x%0.2g') ...
              num2str(abs(rg_fitres(i).rg), ', Rg=%0.1f(%0.1f)')];
end

% linear-linear
subplot(2,2,1); hold all; 
xylabel('iq');
if pub
    label_position = [0.03, 0.94];
    if exist('plt_title', 'var')
        sub_label = ['(a) ' plt_title];
    else
        sub_label = '(a)';
    end
    text(label_position(1), label_position(2), sub_label, 'units', 'normalized');
    % create the legend entries
    if ~exist('pub_lege', 'var')
        for i=1:length(iqpro)
            lege{i} = [num2str(iqpro(i).concentration, '%0.2f') ' mg/mL'];
            legend(lege, 'FontSize', 8, 'Location', 'SouthEast');
        end
    else
        legend(pub_lege, 'FontSize', 8, 'Location', 'SouthEast');
    end
    dx = .38;
    dy = .38;
    ax = gca;
    p1 = get(ax, 'position');
    set(ax, 'position', [p1(1) p1(2) dx dy]);
else
    title(num2str(match_range, '(a) match range [%5.3g, %5.3g]'));
    legend(lege, 'FontSize', 8, 'Location', 'SouthEast');
end
legend boxoff;
axis tight; y_lim = get(gca, 'ylim'); ylim([0,y_lim(2)]);
vline(match_range, 'linestyle', '--', 'color', [0.5 0.5 0.5], 'linewidth', linewidth);
set(gca,'YTickLabel',[])

% log-log
subplot(2,2,2); hold all; 
xylabel('iq');
%s autolimit('loglog', 'ha', gca);
axis tight
zoomout(.1)
yrange = ylim;
i_match = locate(iqpro(1).data(:,1), 0.15);
yrange(1) = mean(iqpro(1).data(i_match:end,2))*.5;
yrange(2) = max(iq_max) * 4;
ylim(yrange);
if pub
    text(label_position(1), label_position(2), '(b)', 'units', 'normalized');
    ax = gca;
    p2 = get(ax, 'position');
    set(ax, 'position', [p2(1) p2(2) dx dy]);
    h = get(gca, 'xlabel');
    set(h, 'Units', 'Normalized');
    pos = get(h, 'position') - [0 0.007 0];
    set(h, 'position', pos);
else
    title('(b) Log-Log plot');
    if isfield(iqpro(1), 'prefix')
        lege2 = {iqpro.prefix};
    elseif isfield(iqpro(1), 'label')
        lege2 = {iqpro.label};
    end
end
if exist('lege2', 'var')
   legend(lege2, 'FontSize', 8, 'Location', 'SouthWest', 'Interpreter', ...
          'None'); legend boxoff;
end
vline(match_range, 'linestyle', '--', 'color', [0.5 0.5 0.5], 'linewidth', linewidth);
set(gca,'YTickLabel',[])

% quinier
subplot(2,2,3); hold all; 
for i=1:num_data
    % plot the guinier plot
    if scale_rg
        plot(rg_fitres(i).fit([1,2,end],1), rg_fitres(i).fit([1,2,end],2) + giq_offset(i), ...
            'Color', colororder(i+5,:), 'Marker', 'o', 'MarkerSize', ...
            4, 'LineStyle', '-', 'linewidth', linewidth);
    else
        plot(rg_fitres(i).fit([1,2,end],1), rg_fitres(i).fit([1,2,end],2), ...
            'Color', get(hplot(i), 'color'), 'Marker', 'o', 'MarkerSize', ...
            4, 'LineStyle', '--' , 'linewidth', linewidth);
    end
end
xylabel('guinier');
if pub
    text(label_position(1), label_position(2), '(c)', 'units', 'normalized');
    ax = gca;
    p3 = get(ax, 'position');
    set(ax, 'position', [p3(1) p3(2) dx dy]);    
else
    title(num2str(guinier_range, '(c) Guinier range [%5.3g, %5.3g]'));
end
% zoomout(0.1);
xlim([0, max(guinier_max)^2*2]);
ymin = min(logiq_range(:,1));% - abs(min(logiq_range(:,1)) * .01 );
ymax = max(logiq_range(:,2)) + abs(max(logiq_range(:,2)) * .08 );
ylim([ymin ymax]); 
set(gca,'YTickLabel',[])

% kratky
subplot(2,2,4); hold all; 
xylabel('kratky');
if pub
    text(label_position(1), label_position(2), '(d)', 'units', 'normalized');
    ax = gca;
    p4 = get(ax, 'position');
    set(ax, 'position', [p4(1) p4(2) dx dy]);
else
    title('(d) Kratky Plot');
end
autolimit('kratky', 'ha', gca);
vline(kratky_match_range, 'linestyle', '--', 'color', [0.5 0.5 0.5], 'linewidth', linewidth);
set(gca,'YTickLabel',[])

% save and assign
if do_saveps;saveps(gcf, [savename '_iqqual.eps']);end;
assignin('caller', ['iqpro_' savename], iqpro);
