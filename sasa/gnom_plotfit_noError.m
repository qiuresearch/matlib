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
% $Id: gnom_plotfit.m,v 1.11 2013/10/03 03:20:31 xqiu Exp $
%

if (nargin < 1)
   help gnom_plotfit
   return
end

% set default values
kratky_plot = 0;
normalize=1;
maxnum_points = 200; % maximum points to plot
figure_format('tinyprint');
parse_varargin(varargin);
clf;
ha = subplot(2,1,1); hold all; title('Scattering Intensity I(Q)');
hb = subplot(2,1,2); hold all; title('Pair Distance Function P(r)');
colororder = get(0, 'DefaultAxesColorOrder');
for i=1:length(gnom)
   % modify the data
   if (normalize == 1)
      gnom(i).iq(:,2:end) = gnom(i).iq(:,2:end)/gnom(i).i0(1);
      [num_rows, num_columns] = size(gnom(i).pr);
      gnom(i).pr(:,2:end) = gnom(i).pr(:,2:end)/sum(gnom(i).pr(:,2))/ ...
          (gnom(i).pr(end,1)-gnom(i).pr(1,1))*(num_rows-1);
   end
   % reduce the number of points if exceeding maxnum_points
   [num_rows, num_columns] = size(gnom(i).iq);
   if (num_rows > maxnum_points)
      gnom(i).iq = gnom(i).iq(1:ceil(num_rows/maxnum_points):end,:);
   end
   [num_rows, num_columns] = size(gnom(i).pr);
   if (num_rows > maxnum_points)
      gnom(i).pr = gnom(i).pr(1:ceil(num_rows/maxnum_points):end,:);
   end

   axes(ha);    % I(Q)
   multi_factor = (length(gnom)-i+1)/length(gnom);
   if (kratky_plot == 1)
      iq=kratky(gnom(i).iq);
      hIq(i) = errorbar(iq(2:end,1), iq(2:end,2)*multi_factor, iq(2:end,3)* ...
                        multi_factor, 'LineStyle', 'none', 'Marker', ...
                        '.', 'Color', colororder(mod(i-1,end)+1,:));
      plot(iq(2:end,1), iq(2:end,4)*multi_factor,  'Color', get(hIq(i), 'Color'));
   else
      hIq(i) = errorbar(gnom(i).iq(:,1), gnom(i).iq(:,2)*multi_factor, ...
                        gnom(i).iq(:,3)*multi_factor, 'LineStyle', ...
                        'none', 'Marker', '.', 'Color', ...
                        colororder(mod(i-1,end)+1,:));
      plot(gnom(i).iq(:,1), gnom(i).iq(:,4)*multi_factor, 'Color', ...
           get(hIq(i), 'Color'));
   end
   
   axes(hb);    % P(r)
   hPr(i) = plot(gnom(i).pr(:,1), gnom(i).pr(:,2), ...
                    'Color', get(hIq(i), 'Color'));

   lege1{i} = [gnom(i).title(1:min(21,end)) sprintf([',I0=%0.1e,chi2=%0.2g'], ...
                                     gnom(i).i0(1), gnom(i).chi2)];

   lege2{i} = [gnom(i).title(1:min(21,end)) sprintf(',Rg=%0.1f,Dmax=%0.1f', ...
                                     gnom(i).rg(1), gnom(i).pr(end,1))];
end

axes(ha); % I(Q)
legend(hIq, lege1, 'Location','NorthWestOutside', 'FontSize', 8, ...
       'Interpreter', 'None');
legend boxoff
xylabel('iq');
if (kratky_plot == 1)
   ylabel('Q^2*I(Q)');
   autolimit('kratky');
else
   set(gca, 'xscale', 'log', 'yscale', 'log');
   autolimit('loglog');
end

axes(hb); % P(r)
legend(hPr, lege2, 'Location','NorthWestOutside', 'FontSize', 8, ...
       'Interpreter', 'None');
legend boxoff
axis tight;
prlabel
