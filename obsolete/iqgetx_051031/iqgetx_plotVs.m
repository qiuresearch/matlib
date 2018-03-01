function hf = iqgetx_plotVs(sIqgetx, varargin)
% --- Usage:
%        hf = iqgetx_plotVs(sIqgetx, varargin)
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
% $Id: iqgetx_plotVs.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $
%

if nargin < 1
   help iqgetx_plotVs
   return
end

savefile = 0;
newfigure = 1;
hidden = 0;
match_range = [0.15,0.27];
parse_varargin(varargin);

varargin_figure = {'PaperPosition', [0.25,1,8,9], 'defaultlinelinewidth', ...
                   0.5, 'defaultaxeslinewidth', 0.4, 'position', ...
                   [26,270,600,760]};
if (newfigure == 1)
   if (hidden == 1)
      hf=figure('visible', 'off', varargin_figure{:});
   else
      hf=figure();
      set(hf, varargin_figure{:});
   end
else
   hf=gcf;
   position = get(hf, 'Position');
   varargin_figure{end} = position;
   set(hf, varargin_figure{:});
end

num_data = length(sIqgetx);
style_plot={'-', '-.', '--', ':'};
counter_data = [];
for i=1:num_data
   
   % 1) final I(Q)s
   subplot(4,2,1);
   title('Final I(Q)')
   hold all;
   xlabel(['Q (' char(197) '^{-1})'])
   ylabel('I(Q)');
   plot(sIqgetx(i).iq(:,1), sIqgetx(i).iq(:,2), ...
        style_plot{max([mod(i,length(style_plot)+1),1])});

   % 2) matched I(Q)s
   subplot(4,2,2)
   hold all
   title(['matched I(Q)  (' num2str(match_range(1)), ', ', ...
          num2str(match_range(2)), ')'])
   xlabel(['Q (' char(197) '^{-1})'])
   ylabel('I(Q)');
   if (i == 1)
      dummy = sIqgetx(1).iq;
      scale = 1.0;
   else
      [dummy(:,:), scale] = match(sIqgetx(i).iq, sIqgetx(1).iq, match_range);
   end
   plot(sIqgetx(i).iq(:,1), sIqgetx(i).iq(:,2)*scale, ...
        style_plot{max([mod(i,length(style_plot)+1),1])});
   legend_2{i} = [sIqgetx(i).title '*' num2str(scale, '%4.2f')];
   
   % 3) raw sample
   subplot(4,2,3);
   hold all;
   title('raw sample');
   xlabel(['Q (' char(197) '^{-1})'])
   ylabel('I(Q)');
   if isfield(sIqgetx(i), 'sam')
      plot(sIqgetx(i).sam.iq(:,1), sIqgetx(i).sam.iq(:,2), ...
           style_plot{max([mod(i,length(style_plot)+1),1])});
   end
   
   % 4) matched raw sample
   subplot(4,2,4);
   hold all;
   title(['matched sample (' num2str(match_range(1)), ', ', ...
          num2str(match_range(2)), ')'])
   xlabel(['Q (' char(197) '^{-1})'])
   ylabel('I(Q)');
   if isfield(sIqgetx(i), 'sam')
      if (i == 1)
         dummy = sIqgetx(1).iq;
         scale = 1.0;
      else
         [dummy(:,:), scale] = match(sIqgetx(i).sam.iq, sIqgetx(1).sam.iq, ...
                                     match_range);
      end
      plot(sIqgetx(i).sam.iq(:,1), sIqgetx(i).sam.iq(:,2)*scale, ...
           style_plot{max([mod(i,length(style_plot)+1),1])});
   end
   legend_4{i} = [sIqgetx(i).title '*' num2str(scale, '%4.2f')];
   
   % 5) raw buffer
   subplot(4,2,5);
   hold all;
   title('raw buffer');
   xlabel(['Q (' char(197) '^{-1})'])
   ylabel('I(Q)');
   if isfield(sIqgetx(i), 'buf')
      plot(sIqgetx(i).buf.iq(:,1), sIqgetx(i).buf.iq(:,2), ...
           style_plot{max([mod(i,length(style_plot)+1),1])});
   end
   
   % 6) matched raw buffer
   subplot(4,2,6);
   hold all;
   title(['matched buffer (' num2str(match_range(1)), ', ', ...
          num2str(match_range(2)), ')'])
   xlabel(['Q (' char(197) '^{-1})'])
   ylabel('I(Q)');
   if isfield(sIqgetx(i), 'buf')
      if (i == 1)
         dummy = sIqgetx(1).iq;
         scale = 1.0;
      else
         [dummy(:,:), scale] = match(sIqgetx(i).buf.iq, sIqgetx(1).buf.iq, ...
                                     match_range);
      end
      plot(sIqgetx(i).buf.iq(:,1), sIqgetx(i).buf.iq(:,2)*scale, ...
           style_plot{max([mod(i,length(style_plot)+1),1])});
   end
   legend_6{i} = [sIqgetx(i).title '*' num2str(scale, '%4.2f')];
   
   % 7) X-ray counters
   subplot(4,2,7)
   hold all;
   title(['X-ray counters'])
   xlabel('image number')
   ylabel('count');
   counter_data = [counter_data;  iqgetx_getmetadata(sIqgetx(i), ...
                                                 'sortdata', 0, ...
                                                 'normalize', 0)];
   % 8) mean count
   subplot(4,2,8)
   hold all
   title(['Average count']);
   xlabel('image number')
   ylabel('count');
end

annotation('TextBox', [0.36,0.985,0.28,0.005], 'FitHeightToText', 'on', ...
           'HorizontalAlignment', 'center', 'VerticalAlignment', ...
           'middle', 'String', [sIqgetx(1).title ' ... ' sIqgetx(end).title]);
subplot(4,2,1); axis tight; legend(sIqgetx(:).title); legend boxoff
subplot(4,2,2); axis tight; legend(legend_2); legend boxoff
subplot(4,2,3); axis tight; legend(sIqgetx(:).title); legend boxoff
subplot(4,2,4); axis tight; legend(legend_4); legend boxoff
subplot(4,2,5); axis tight; legend(sIqgetx(:).title); legend boxoff
subplot(4,2,6); axis tight; legend(legend_6); legend boxoff
subplot(4,2,7);
[dummy, iorder] = sort(counter_data(:,1));
counter_data = counter_data(iorder,:);
for k=3:6
   counter_data(:,k) = counter_data(:,k)/counter_data(1,k);
end
for k=1:4
   [x,y] = stairs(counter_data(:,1), counter_data(:,k+2));
   x=[x; x(end)+1]-0.5;
   y=[y; y(end)];
   plot(x, y, style_plot{max([mod(k, length(style_plot)+1),1])})
%   plot(counter_data(:,1), counter_data(:,i+1), ...
%        style_plot{max([mod(i,length(style_plot)+1),1])});
end
axis tight
legend({'xflash', 'i1', 'i0', 'cesr'}); legend boxoff

subplot(4,2,8)
for k=5:5
   [x,y] = stairs(counter_data(:,1), counter_data(:,k+1));
   x=[x; x(end)+1]-0.5;
   y=[y; y(end)];
   plot(x, y)
%   plot(counter_data(:,1), counter_data(:,i+1), ...
%        style_plot{max([mod(i,length(style_plot)+1),1])});
end
axis tight
           
if (savefile == 1)
   saveps(gcf, [sIqgetx(1).label '_Vall.ps']);
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% --- Change History:
%
% $Log: iqgetx_plotVs.m,v $
% Revision 1.1.1.1  2007-09-19 04:45:38  xqiu
% A new start of my matlab library with new directory structure.
%
% Revision 1.4  2005/08/27 01:39:32  xqiu
% lots of small changes!
%
% Revision 1.3  2005/06/27 02:31:49  xqiu
% fix figure postion and getdata to getmetadata
%
% Revision 1.2  2005/06/16 18:35:42  xqiu
% *** empty log message ***
%
% Revision 1.1  2005/06/09 01:54:35  xqiu
% new members!
%
% Revision 1.2  2005/06/03 04:14:06  xqiu
% a more or less working version ready
%
% Revision 1.1  2005/04/29 14:42:49  xqiu
% Initialize the iqgetx standalone package!
%
% Revision 1.4  2004/12/20 04:47:53  xqiu
% IQgetX small improvements
%
% Revision 1.3  2004/11/19 05:04:26  xqiu
% Added comments
%
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%