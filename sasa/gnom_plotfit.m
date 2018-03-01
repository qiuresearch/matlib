function varargout = gnom_plotfit(gnom, varargin)
% --- Usage:
%        varargout = gnom_plotfit(gnom, varargin)
% --- Purpose:
%        plot the GNOM results
% --- Parameter(s):
%        gnom - the structure returned from "gnom_loadout"
%
%        'left' - plotted as the left two panels (default)
%        'right' - plotted as the right two pannels
%        'normalize' - normalize data by the gnom.I0 (default:1)
%        'kratky_plot' - whether to show I(Q) in Kratky format (default:0)
%        'maxnum_points' - reduce number of points for visualization
% --- Return(s):
%         none -
%
% --- Example(s):
%
% $Id: gnom_plotfit.m,v 1.13 2015/11/09 16:26:03 schowell Exp $
%

if (nargin < 1)
    help gnom_plotfit
    return
end

% set default values
kratky_plot = 0;
normalize=1;
maxnum_points = 200; % maximum points to plot
linewidth = 1;
font_size = 8;
show_iq_error_ends = 1;
show_pr_error_ends = 0;
hidden = 0;
newfigure = 1;

parse_varargin(varargin); % parse input

% setup some variables
num_data = length(gnom);
iq_max = zeros(num_data,1);
iq_min = zeros(num_data,1);    
if pub
    if exist('lege', 'var')
        if lege == 2
            lege2 = pub_lege;
        end
    else
        lege1 = pub_lege;
    end
    font_size = 10;
    varargin_figure = { 'PaperPosition', [0.25,2,8,7], 'defaultlinelinewidth', 0.5, ...
        'defaultaxeslinewidth', 0.4, 'DefaultAxesFontSize', font_size, ...
        'DefaultLineMarkerSize', 0.01, 'DefaultTextFontSize', font_size};
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
    height = 4.8;
    width = 5.5;
    set(gcf, 'PaperUnits', 'inches');
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperSize', [width height]);
    set(gcf, 'PaperPosition', [0 0 width height]); % last 2 are width/height.
    set(gcf, 'renderer', 'painters');
    label_position = [0.03, 0.94];
    if exist('plt_title', 'var')
        sub_label = ['(a) ' plt_title];
    else
        sub_label = '(a)';
    end
    ha = subplot(1,2,1); hold all;
    text(label_position(1), label_position(2), sub_label, 'units', 'normalized');

    hb = subplot(1,2,2); hold all;
    text(label_position(1), label_position(2), '(b)', 'units', 'normalized');
else
    figure_fullsize(); clf;
    figure_format('tinyprint');
    ha = subplot(2,1,1); hold all; title('Scattering Intensity I(Q)');
    hb = subplot(2,1,2); hold all; title('Pair Distance Function P(r)');
end
colororder = get(0, 'DefaultAxesColorOrder');
for i=1:num_data
    % modify the data
    if (normalize == 1)
        gnom(i).iq(:,2:end) = gnom(i).iq(:,2:end)/gnom(i).i0(1);
        [num_rows, ~] = size(gnom(i).pr);
        gnom(i).pr(:,2:end) = gnom(i).pr(:,2:end)/sum(gnom(i).pr(:,2))/ ...
            (gnom(i).pr(end,1)-gnom(i).pr(1,1))*(num_rows-1);
    end
    % reduce the number of points if exceeding maxnum_points
    [num_rows, ~] = size(gnom(i).iq);
    if (num_rows > maxnum_points)
        gnom(i).iq = gnom(i).iq(1:ceil(num_rows/maxnum_points):end,:);
    end
    [num_rows, ~] = size(gnom(i).pr);
    if (num_rows > maxnum_points)
        gnom(i).pr = gnom(i).pr(1:ceil(num_rows/maxnum_points):end,:);
    end
    
    % I(Q)
    match_range = [0.001, 0.01];
%         max(gnom(1).iq(1,1), gnom(i).iq(1,1)), ...
%         min(gnom(i).iq(end,1), gnom(i).iq(end,1))];
    [~, scale, ~] = match(gnom(i).iq, gnom(1).iq, match_range);
    multi_factor = 10^((num_data-i+1)/num_data);
    multi_factor = multi_factor*scale;
    if (kratky_plot == 1)
        iq=kratky(gnom(i).iq);
        hIq(i) = errorbar(ha, iq(2:end,1), iq(2:end,2)*multi_factor, iq(2:end,3)* ...
            multi_factor, 'LineStyle', 'none', 'Marker', ...
            '.', 'Color', colororder(mod(i-1,end)+1,:));
        plot(ha, iq(2:end,1), iq(2:end,4)*multi_factor, ...
            'Color', get(hIq(i), 'Color'));
    else
        hIq(i) = errorbar(ha, gnom(i).iq(:,1), gnom(i).iq(:,2)*multi_factor, ...
            gnom(i).iq(:,3)*multi_factor, 'LineStyle', ...
            'none', 'Marker', '.', 'Color', ...
            colororder(mod(i-1,end)+1,:));
        hIq2(i) = plot(ha, gnom(i).iq(:,1), gnom(i).iq(:,4)*multi_factor, ...
            'Color', ...
            get(hIq(i), 'Color'));
        iq_max(i) = max(max(gnom(i).iq(:,[2,4])*multi_factor));
        iq_min(i) = min(mean(gnom(i).iq(end-20:end,[2,4])*multi_factor));
    end
    
    % P(r)
    hPr(i) = errorbar(hb, gnom(i).pr(:,1), gnom(i).pr(:,2), gnom(i).pr(:,3), ...
        'Color', get(hIq(i), 'Color'));
    
    if ~pub
        lege1{i} = [gnom(i).title(1:min(21,end)) sprintf([',I0=%0.1e,chi2=%0.2g'], ...
            gnom(i).i0(1), gnom(i).chi2)];
        
        lege2{i} = [gnom(i).title(1:min(21,end)) sprintf(',Rg=%0.1f,Dmax=%0.1f', ...
            gnom(i).rg(1), gnom(i).pr(end,1))];
    end
end

axes(ha); % I(Q)
if exist('lege1', 'var')
    if pub 
        legend(hIq2, pub_lege, 'FontSize', font_size-2, 'Location', 'SouthWest');
    else
        legend(hIq, lege1, 'Location','NorthWestOutside', 'FontSize', font_size-2, ...
            'Interpreter', 'None');
    end
    legend boxoff
end
if (kratky_plot == 1)
    xylabel('kratky');
    autolimit('kratky');
else
    xylabel('iq');
    set(gca, 'xscale', 'log', 'yscale', 'log');
    if pub
        dx = .38;
        dy = .38;
        ax = gca;
        p1 = get(ha, 'position');
        set(ha, 'position', [p1(1) p1(2) dx dy]);
        axis tight
        zoomout(.1)
        yrange = ylim;
        yrange(1) = min(iq_min) * .5;
        yrange(2) = max(iq_max) * 4;
        ylim(yrange)
        h = get(gca, 'xlabel');
        set(h, 'Units', 'Normalized');
        pos = get(h, 'position') + [0 0.077 0];
        set(h, 'position', pos);
    else
        autolimit('loglog');
    end
end
set(gca,'YTickLabel',[])

axes(hb); % P(r)
if exist('lege2', 'var')
    if pub 
    legend(hPr, pub_lege, 'FontSize', font_size-2, 'Location', 'NorthEast');
    else
    legend(hPr, lege2, 'Location','NorthWestOutside', 'FontSize', font_size, ...
        'Interpreter', 'None');
    end
end
legend boxoff

axis tight;
if pub
    p2 = get(hb, 'position');
    set(hb, 'position', [p2(1) p2(2) dx dy]);
    yrange = ylim;
    yrange(2) = yrange(2)*1.12;
    ylim(yrange)
end
prlabel
set(gca,'YTickLabel',[])
for i=1:length(hPr)
    if show_iq_error_ends
        remove_error_bar_ends(hIq(i)); % default keep, ends are helpful
    end
    if show_pr_error_ends
        remove_error_bar_ends(hPr(i)); % defalt remove, end look messy
    end
end
