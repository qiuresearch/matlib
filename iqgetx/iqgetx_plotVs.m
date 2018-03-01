function [hf, haxes] = iqgetx_plotVs(sIqgetx, varargin)
% --- Usage:
%        [hf, haxes] = iqgetx_plotVs(sIqgetx, varargin)
% --- Purpose:
%        compare the buffer, sample I(Q)s between different
%        Vs. Used fields are:
%             sIqgetx.buf.iq, sIqgetx.sam.iq, sIqgetx.iq;
%        X-ray counters are also shown, the data of which are taken
%        with routine iqgetx_getdata, or iqgetx2_getdata, depending
%        on whether sIqgetx.bufimgs is available.
%
% --- Parameter(s):
%        sIqgetx - an array of IqGetX structure
%
% --- Return(s): 
%        hf - 
%
% --- Example(s):
%
% $Id: iqgetx_plotVs.m,v 1.14 2016/10/26 15:21:56 xqiu Exp $
%

if nargin < 1
   help iqgetx_plotVs
   return
end

saveeps_isa = 0; % 
newfigure = 1;
iqonly = 0;
hidden = 0;
match_range = [0.08,0.13];
counter_names = {'gdoor', 'i0', 'i1', 'mean'};
style_plot={'-o', '--o'};
parse_varargin(varargin);

if (strcmp(counter_names{1}, 'gdoor') && isfield(sIqgetx(1), 'sam') && isfield(sIqgetx(1).sam, 'monnames') ...
    && ~strcmp(sIqgetx(1).sam.monnames{1},'gdoor'))
   counter_names{1} = 'xflash';
end
varargin_figure = {'PaperPosition', [0.25,2,8,7], 'defaultlinelinewidth', ...
                   0.5, 'defaultaxeslinewidth', 0.4, ...
                   'DefaultAxesFontSize', 10, 'DefaultLineMarkerSize', ...
                   10, 'DefaultTextFontSize', 10}; % 'position', [1 ...
                    % [26,270,600,660];
if (newfigure == 1)
   if (hidden == 1)
      hf=figure('visible', 'off');
   else
      hf=figure();
   end
else
   hf=gcf;
   position = get(hf, 'Position');
   varargin_figure{end} = position;
end
set(hf, varargin_figure{:});
figure_size(hf, 'king');

if (iqonly == 1) % only the subtracted I(Q) will be plotted
   haxes = axes_create(1,2,'qeensize', 1, 'xmargin', 0.07, 'ymargin', 0.0);
else
   haxes = axes_create(2,4,'qeensize', 1, 'xmargin', 0.07, 'ymargin', 0.0);
end

num_data = length(sIqgetx);
counter_data = [];
for i=1:num_data

   if isfield(sIqgetx(i), 'title')
      titlestr = sIqgetx(i).title;
   else
      titlestr = sIqgetx(i).label;
   end
         
   % 1) final I(Q)s
   axes(haxes(1)); hold all;
   plot(sIqgetx(i).iq(:,1), sIqgetx(i).iq(:,2));%, style_plot{max([mod(i,length(style_plot)+1),1])});

   % 2) matched I(Q)s
   axes(haxes(2)); hold all;
   if (i == 1)
      dummy = sIqgetx(1).iq;
      scale = 1.0;
   else
      [dummy, scale] = match(sIqgetx(i).iq, sIqgetx(1).iq, match_range, ...
                             'verbose', 0);
   end
   % errorbar(sIqgetx(i).iq(:,1), sIqgetx(i).iq(:,2)*scale, sIqgetx(i).iq(:,4)*scale); %   style_plot{max([mod(i,length(style_plot)+1),1])});
   plot(sIqgetx(i).iq(:,1), sIqgetx(i).iq(:,2)*scale); %   style_plot{max([mod(i,length(style_plot)+1),1])});
   set(gca,'xscale','log','yscale','log')
   legend_2{i} = [titlestr '*' num2str(scale, '%4.2f')];
   
   if (iqonly == 1); continue; end
   
   % 3) raw sample
   axes(haxes(3)); hold all;
   if isfield(sIqgetx(i), 'sam')
      plot(sIqgetx(i).sam.iq(:,1), sIqgetx(i).sam.iq(:,2)); % style_plot{max([mod(i,length(style_plot)+1),1])});
   end
   
   % 4) matched raw sample
   axes(haxes(4)); hold all;
   if isfield(sIqgetx(i), 'sam')
      if (i == 1)
         dummy = sIqgetx(1).iq;
         scale = 1.0;
      else
         [dummy(:,:), scale] = match(sIqgetx(i).sam.iq, sIqgetx(1).sam.iq, ...
                                     match_range, 'verbose', 0);
      end
      plot(sIqgetx(i).sam.iq(:,1), sIqgetx(i).sam.iq(:,2)*scale); % style_plot{max([mod(i,length(style_plot)+1),1])});
   end
   legend_4{i} = [sIqgetx(i).label '*' num2str(scale, '%4.2f')];
   
   % 5) raw buffer
   axes(haxes(5)); hold all;
   if isfield(sIqgetx(i), 'buf')
      plot(sIqgetx(i).buf.iq(:,1), sIqgetx(i).buf.iq(:,2)); % style_plot{max([mod(i,length(style_plot)+1),1])});
   end
   
   % 6) matched raw buffer
   axes(haxes(6)); hold all;
   if isfield(sIqgetx(i), 'buf')
      if (i == 1)
         dummy = sIqgetx(1).iq;
         scale = 1.0;
      else
         [dummy(:,:), scale] = match(sIqgetx(i).buf.iq, sIqgetx(1).buf.iq, ...
                                     match_range);
      end
      plot(sIqgetx(i).buf.iq(:,1), sIqgetx(i).buf.iq(:,2)*scale);                                                                % style_plot{max([mod(i,length(style_plot)+1),1])});
   end
   legend_6{i} = [sIqgetx(i).label '*' num2str(scale, '%4.2f')];
   
   % 7) X-ray counters
   axes(haxes(7)); hold all;
   [metadata, metadata_names] = iqgetx_getmetadata(sIqgetx(i), ...
                                                   'sortdata', 0, ...
                                                   'normalize', 0);
   counter_data = [counter_data; metadata ];
   % 8) mean count
   axes(haxes(8));hold all;
end

% annotation('TextBox', [0.36,0.985,0.28,0.005], 'FitHeightToText', ...
%            'on', 'HorizontalAlignment', 'center', 'VerticalAlignment', ...
%            'middle', 'String', [sIqgetx(1).label ' ... ' sIqgetx(end).label]);
% 

axes(haxes(1)); axis tight;
set(haxes(1), 'XAxisLocation', 'Top');
xylabel('iq');
legend({sIqgetx(:).label}, 'Interpreter','None'); legend boxoff
%puttext(0.5,0.9,'solute I(Q)', 'HorizontalAlignment', 'Center'); ylabel('I(Q)');
axes(haxes(2)); axis tight; 
legend(legend_2, 'Interpreter', 'None'); legend boxoff
xylabel('iq');
set(vline(match_range), 'color', 'k', 'linestyle', '--');
%puttext(0.5,0.9, ['matched solute (' num2str(match_range(1)), ', ', ...
%                  num2str(match_range(2)), ')'], 'HorizontalAlignment', 'Center');
if (iqonly == 0);
   axes(haxes(3)); axis tight; 
   legend({sIqgetx(:).label}, 'Interpreter','None'); legend boxoff
   puttext(0.5,0.9,'raw sample', 'HorizontalAlignment', 'Center');
   xlabel(['Q (' char(197) '^{-1})'])
   ylabel('I(Q)');
   
   axes(haxes(4)); axis tight; legend(legend_4, 'Interpreter', ...
                                      'None'); legend boxoff
   puttext(0.5,0.9,['matched sample (' num2str(match_range(1)), ', ', ...
                    num2str(match_range(2)), ')'], 'HorizontalAlignment', 'Center')
   xlabel(['Q (' char(197) '^{-1})'])
   ylabel('I(Q)');
   
   axes(haxes(5)); axis tight; legend({sIqgetx(:).label}, ...
                                      'Interpreter','None'); legend boxoff
   puttext(0.5,0.9,'raw buffer', 'HorizontalAlignment', 'Center');
   xlabel(['Q (' char(197) '^{-1})'])
   ylabel('I(Q)');
   
   axes(haxes(6)); axis tight; legend(legend_6, 'Interpreter', ...
                                      'None'); legend boxoff
   puttext(0.5,0.9,['matched buffer (' num2str(match_range(1)), ', ', ...
          num2str(match_range(2)), ')'], 'HorizontalAlignment', 'Center')
   xlabel(['Q (' char(197) '^{-1})'])
   ylabel('I(Q)');

   axes(haxes(7)); 
   axes_pos = get(gca, 'Position'); 
   axes_pos(4) = axes_pos(4)-0.05;
   set(gca, 'Position', axes_pos);

   % plot the counter data
   [dummy, iorder] = sort(counter_data(:,1));
   counter_data = counter_data(iorder,:);
   for i=2:length(metadata_names)-1
      [x,y] = stairs(counter_data(:,1), counter_data(:,i)/max(counter_data(:,i))*(11-i)/10);
      x=[x; x(end)+1]-0.5;
      y=[y; y(end)];
      plot(x, y, style_plot{max([mod(i, length(style_plot)+1),1])})
      %   plot(counter_data(:,1), counter_data(:,i+1), ...
      %        style_plot{max([mod(i,length(style_plot)+1),1])});
   end
   axis tight; ylim([0,1.1]);
   legend(metadata_names(2:end-1), 'Interpreter', 'None'); legend boxoff
   %   puttext(0.5,0.9,['Counters etc'], 'HorizontalAlignment', 'Center')
   xlabel('image number');
   ylabel('count');
   
   axes(haxes(8));
   axes_pos = get(gca, 'Position'); 
   axes_pos(4) = axes_pos(4)-0.05;
   set(gca, 'Position', axes_pos);
   for i=1:1
      k = strmatch('MEAN', upper(metadata_names), 'EXACT');
      k = k(1);
      [x,y] = stairs(counter_data(:,1), counter_data(:,k));
      x=[x; x(end)+1]-0.5;
      y=[y; y(end)];
      plot(x, y, 's--')
      %   plot(counter_data(:,1), counter_data(:,i+1), ...
      %        style_plot{max([mod(i,length(style_plot)+1),1])});
   end
   axis tight; zoomout(0.07);
   puttext(0.5,0.9,['Avg. Count'], 'HorizontalAlignment', 'Center');
   xlabel('image number');
   ylabel('count');
end

if (saveeps_isa == 1)
   saveps(gcf, [sIqgetx(1).label '_plotVs.eps']);
end
