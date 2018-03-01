function hf = iqgetx_plotV(sIqgetx, varargin)
% --- Usage:
%        hf = iqgetx_plotV(sIqgetx, varargin)
% --- Purpose:
%        do a general plot of the signal and buffer I(Q) data
%
% --- Parameter(s):
%        sIqgetx - an array of IqGetX structure
%
% --- Return(s): 
%        result - 
%
% --- Example(s):
%
% $Id: iqgetx_plotV.m,v 1.21 2016/10/26 15:21:56 xqiu Exp $

if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   error('at least one parameter is required, please see the usage! ')
end

newfigure = 1;
hidden=0;
savefigure = 0;
printfigure = 0;
xlog = 0;
ylog = 1;
if isfield(sIqgetx(1).sam, 'monnames');
   counter_names = sIqgetx(1).sam.monnames;
else
   counter_names = [];
end
match_range = [];
parse_varargin(varargin);
style_plot={'-', '-.', '--', ':'};
varargin_figure = { 'PaperPosition', [0.25,2,8,7], 'defaultlinelinewidth', ...
                    0.5, 'defaultaxeslinewidth', 0.4, ...
                    'DefaultAxesFontSize', 10, 'DefaultLineMarkerSize', ...
                    10, 'DefaultTextFontSize', 10}; % 'position', [1 ...
                     % [26,270,600,660]};

warning off
num_data = length(sIqgetx);
if isempty(match_range)
   match_range = max(sIqgetx(1).iq(:,1))*[0.5 0.7];
end

for i=1:num_data
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
   figure_size(hf, 'king');
   
   haxes = axes_create(2,3,'qeensize', 1, 'xmargin', 0.07, 'ymargin', 0.0);
   % 1) raw sample - raw buffer
   axes(haxes(1)); set(haxes(1), 'xaxis', 'top'); hold all
   xlabel([]); ylabel('I(Q)');
   
   plot(sIqgetx(i).sam.iq(:,1), sIqgetx(i).sam.iq(:,2));%, style_plot{3});

   if ~isempty(sIqgetx(i).buf)
      plot(sIqgetx(i).buf.iq(:,1), sIqgetx(i).buf.iq(:,2));%, style_plot{2});
      plot(sIqgetx(i).iq(:,1), sIqgetx(i).iq(:,2));%, style_plot{1});
   end
   legend({'sample', 'buffer', 'sam-buf'});
   if isfield(sIqgetx(i), 'buf1') && isfield(sIqgetx(i), 'buf2')
      plot(sIqgetx(i).buf1.iq(:,1), sIqgetx(i).buf1.iq(:,2));%, style_plot{3});
      plot(sIqgetx(i).buf2.iq(:,1), sIqgetx(i).buf2.iq(:,2));%, style_plot{3});
      legend({'sample', 'buffer', 'sam-buf', 'buf1', 'buf2'});
   end
   legend boxoff
   if (xlog == 1)
      set(gca, 'XScale', 'log');
   end
   if (ylog == 1)
      set(gca, 'YScale', 'log');
   end
   axis tight
   title([sIqgetx(i).title, ' (' sIqgetx(i).label ')'],'Interpreter', 'none');
   
   % 2) X-ray counters
   axes(haxes(2)); set(haxes(2), 'XAxisLocation', 'Top'); hold all;
   xlabel('image number')
   ylabel(['X-ray counters (' sIqgetx(i).label ')'],'Interpreter', 'none')

   [data, data_names] = iqgetx_getmetadata(sIqgetx(i), 'sortdata',1, ...
                                           'normalize',0);
   symbolorder = {'s', 'o', '^', 'd', 'x', 'V', 'p', '<', '*', 'h', '+'};
   for j=1:length(counter_names);
      k = strmatch(upper(counter_names{j}), upper(data_names), 'EXACT');
      %      [x,y] = stairs(data(:,1), data(:,k)/data(1,k));
      %      x=[x; x(end)+1]-0.5;
      %      y=[y; y(end)];
      %      plot(x, y);%, style_plot{max([mod(k,
      %      length(style_plot)+1),1])})\
      %plot(data(:,1), data(:,k)/data(1,k)*(j/2+0.5), 's--');
      plot(data(:,1), data(:,k)/max(data(:,k))*(11-j)/10, '--', ...
           'Marker', symbolorder{j});
   end
   axis auto;
   ylim([0, 1.1]);
   legend(counter_names, 'Interpreter', 'none');
   legend boxoff;

   % 3) raw buffer
   axes(haxes(3));
   hold all;
   xlabel(['Q (' char(197) '^{-1})'])
   ylabel(['buffers (' sIqgetx(i).label ')'],'Interpreter', 'none');
   bufimgs = [];
   if isfield(sIqgetx(i), 'bufimgs')
      bufimgs = sIqgetx(i).bufimgs;
   end
   if isfield(sIqgetx(i), 'buf1imgs')
      bufimgs = [bufimgs, sIqgetx(i).buf1imgs];
   end
   if isfield(sIqgetx(i), 'buf2imgs')
      bufimgs = [bufimgs, sIqgetx(i).buf2imgs];
   end
   for k=1:length(bufimgs)
      plot(bufimgs(k).iq(:,1), bufimgs(k).iq(:,2), 'linewidth', 2);%, ...
%           style_plot{max([mod(k,length(style_plot)+1),1])});
      [~, legend_plot{k}, ~] = fileparts(bufimgs(k).file);
   end
   
   if (xlog == 1)
      set(gca, 'XScale', 'log');
   end
   if (ylog == 1)
      set(gca, 'YScale', 'log');
   end
   axis tight
   if exist('legend_plot', 'var') && ~isempty(legend_plot);
      legend(strrep(legend_plot, '__', '_'), 'Interpreter', 'none');
      % legend_plot = [];
   end
   
   legend boxoff
      
   % 5) matched buffer data
   axes(haxes(5));   hold all;
   xlabel(['Q (' char(197) '^{-1})'])
   ylabel(['buffers matched (' num2str(match_range(1)), ', ', ...
          num2str(match_range(2)), ')'],'Interpreter', 'none');
   for k=1:length(bufimgs)
      if (k == 1)
         % dummy = bufimgs(1).iq;
         scale = 1.0;
      else
          [~, scale] = match(bufimgs(k).iq, bufimgs(1).iq, ...
              match_range, 'verbose', 0);
      end
      plot(bufimgs(k).iq(:,1), bufimgs(k).iq(:,2)*scale,'linewidth',2);%, ...
%           style_plot{max([mod(k,length(style_plot)+1),1])});
      legend_plot{k} = [legend_plot{k} num2str(scale, '*%4.2f')];
   end
   
   if (xlog == 1)
      set(gca, 'XScale', 'log');
   end
   if (ylog == 1)
      set(gca, 'YScale', 'log');
   end
   axis tight
   legend(strrep(legend_plot, '__', '_'), 'Interpreter', 'none'); legend_plot = [];
   legend boxoff

   % 4) raw sample
   axes(haxes(4));   hold all
   xlabel(['Q (' char(197) '^{-1})'])
   ylabel(['samples (' sIqgetx(i).label ')'],'Interpreter', 'none')
   if isfield(sIqgetx(i), 'samimgs')
      for k=1:length(sIqgetx(i).samimgs)
%          plot(sIqgetx(i).samimgs(k).iq(:,1), sIqgetx(i).samimgs(k).iq(:,2) + sIqgetx(i).buf.iq(:,2), 'linewidth', 2); % Want to see the unsubtracted sample images (SH)
         plot(sIqgetx(i).samimgs(k).iq(:,1), sIqgetx(i).samimgs(k).iq(:,2), 'linewidth', 2);%, ...
%              style_plot{max([mod(k,length(style_plot)+1),1])});
         [~, legend_plot{k}, ~] = fileparts(sIqgetx(i).samimgs(k).file);
      end
   end
   if (xlog == 1)
      set(gca, 'XScale', 'log');
   end
   if (ylog == 1)
      set(gca, 'YScale', 'log');
   end
   axis tight
   legend(strrep(legend_plot, '__', '_'), 'Interpreter', 'none');
   legend boxoff
      
   % 6) matched sample data
   axes(haxes(6)); hold all;
   xlabel(['Q (' char(197) '^{-1})'])
   ylabel(['samples matched (' num2str(match_range(1)), ', ', ...
           num2str(match_range(2)), ')'],'Interpreter', 'none');
   if isfield(sIqgetx(i), 'samimgs')
      for k=1:length(sIqgetx(i).samimgs)
         if (k == 1)
            % dummy = sIqgetx(i).samimgs(1).iq;
            scale = 1.0;
         else
             [~, scale] = match(sIqgetx(i).samimgs(k).iq, ...
                 sIqgetx(i).samimgs(1).iq, match_range, 'verbose', 0);
         end
         plot(sIqgetx(i).samimgs(k).iq(:,1), ...
              sIqgetx(i).samimgs(k).iq(:,2)*scale,'linewidth',2);%, ...
%              style_plot{max([mod(k,length(style_plot)+1),1])});
         legend_plot{k} = [legend_plot{k} num2str(scale, '*%4.2f')];
      end
   end
   if (xlog == 1)
      set(gca, 'XScale', 'log');
   end
   if (ylog == 1)
      set(gca, 'YScale', 'log');
   end
   axis tight
   legend(strrep(legend_plot, '__', '_'), 'Interpreter', 'none'); ...
       legend_plot = [];
   legend boxoff

%   annotation(gcf, 'TextBox', [0.36,0.985, 0.28,0.05]);
   %'FitHeightToText', ...
   %           'on', 'HorizontalAlignment', 'center', 'VerticalAlignment', ...
   %           'middle', 'String', 'test');
%   [sIqgetx(i).title, ' (', ...
%                       sIqgetx(i).label, ')'], 'Interpreter', 'None');

   if (savefigure == 1)
      saveps(gcf, [sIqgetx(i).label '_V' int2str(i) '.eps']);
   end
end
warning on
