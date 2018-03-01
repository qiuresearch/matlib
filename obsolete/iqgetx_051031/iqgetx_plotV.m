function hf = iqgetx_plotV(sIqgetx, varargin)
% --- Usage:
%        result = iqgetx_plotiq(sIqgetx)
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
% $Id: iqgetx_plotV.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $
%

if nargin < 1
   help iqgetx_plotdata
   return
end

newfigure = 1;
hidden=0;
savefigure = 0;
printfigure = 0;
match_range = [0.15 0.27];
parse_varargin(varargin);
style_plot={'-', '-.', '--', ':'};
varargin_figure = { 'PaperPosition', [0.25,2,8,7], 'defaultlinelinewidth', ...
                    0.5, 'defaultaxeslinewidth', 0.4, 'position', ...
                    [26,270,600,660]};
num_data = length(sIqgetx);
for i=1:num_data
   if (newfigure == 1)
      if (hidden == 1)
         hf=figure('visible', 'off', varargin_figure{:});
      else
         hf=figure(varargin_figure{:});
      end
   else
      hf=gcf;
      position = get(hf, 'Position');
      varargin_figure{end} = position;
      set(hf, varargin_figure{:});
   end
   
   % 1) raw sample - raw buffer
   subplot(3,2,1);
   title(sIqgetx(i).title)
   hold all;
   xlabel(['Q (' char(197) '^{-1})'])
   ylabel('I(Q)');
   
   plot(sIqgetx(i).sam.iq(:,1), sIqgetx(i).sam.iq(:,2), style_plot{3});
   plot(sIqgetx(i).buf.iq(:,1), sIqgetx(i).buf.iq(:,2), style_plot{2});
   plot(sIqgetx(i).iq(:,1), sIqgetx(i).iq(:,2), style_plot{1});
   axis tight
   legend({'sample', 'buffer', 'sam-buf'});
   if isfield(sIqgetx(i), 'buf1') && isfield(sIqgetx(i), 'buf2')
      plot(sIqgetx(i).buf1.iq(:,1), sIqgetx(i).buf1.iq(:,2), style_plot{3});
      plot(sIqgetx(i).buf2.iq(:,1), sIqgetx(i).buf2.iq(:,2), style_plot{3});
      legend({'sample', 'buffer', 'sam-buf', 'buf1', 'buf2'});
   end
   legend boxoff
   
   % 2) X-ray counters
   subplot(3,2,2)
   hold all;
   title(['X-ray counters (' sIqgetx(i).label ')'])
   xlabel('image number')
   ylabel('counts');

   data = iqgetx_getmetadata(sIqgetx(i));
   for k=1:4
      [x,y] = stairs(data(:,1), data(:,k+2));
      x=[x; x(end)+1]-0.5;
      y=[y; y(end)];
      plot(x, y, style_plot{max([mod(k, length(style_plot)+1),1])})
   end
   axis tight
   legend({'xflash', 'i1', 'i0', 'cesr'})
   legend boxoff

   % 3) raw buffer
   subplot(3,2,3);
   hold all;
   title(['raw buffers (' sIqgetx(i).label ')']);
   xlabel(['Q (' char(197) '^{-1})'])
   ylabel('I(Q)');
   bufimgs = [];
   if isfield(sIqgetx(i), 'bufimgs')
      bufimgs = sIqgetx(i).bufimgs;
   else
      if isfield(sIqgetx(i), 'buf1imgs')
         bufimgs = [bufimgs, sIqgetx(i).buf1imgs];
      end
      if isfield(sIqgetx(i), 'buf2imgs')
         bufimgs = [bufimgs, sIqgetx(i).buf2imgs];
      end
   end
   for k=1:length(bufimgs)
      plot(bufimgs(k).iq(:,1), bufimgs(k).iq(:,2), ...
           style_plot{max([mod(k,length(style_plot)+1),1])});
      legend_plot{k} = [bufimgs(k).prefix int2str(bufimgs(k).num)];
   end
   
   axis tight
   legend(legend_plot); legend_plot = [];
   legend boxoff
      
   % 4) raw sample
   subplot(3,2,4)
   hold all
   title(['raw sample (' sIqgetx(i).label ')'])
   xlabel(['Q (' char(197) '^{-1})'])
   ylabel('I(Q)');
   if isfield(sIqgetx(i), 'samimgs')
      for k=1:length(sIqgetx(i).samimgs)
         plot(sIqgetx(i).samimgs(k).iq(:,1), sIqgetx(i).samimgs(k).iq(:,2), ...
              style_plot{max([mod(k,length(style_plot)+1),1])});
         legend_plot{k} = [sIqgetx(i).samimgs(k).prefix ...
                           int2str(sIqgetx(i).samimgs(k).num)];
      end
   end
   axis tight
   legend(legend_plot); legend_plot = [];
   legend boxoff
      
   % 5) matched buffer data
   subplot(3,2,5);
   hold all;
   title(['buffers matched (' num2str(match_range(1)), ', ', ...
          num2str(match_range(2)), ')']);
   xlabel(['Q (' char(197) '^{-1})'])
   ylabel('I(Q)');
   for k=1:length(bufimgs)
      if (k == 1)
         dummy = bufimgs(1).iq;
         scale = 1.0;
      else
         [dummy(:,:), scale] = match(bufimgs(k).iq, bufimgs(1).iq, ...
                                     match_range);
      end
      plot(bufimgs(k).iq(:,1), bufimgs(k).iq(:,2)*scale, ...
           style_plot{max([mod(k,length(style_plot)+1),1])});
      legend_plot{k} = [bufimgs(k).prefix int2str(bufimgs(k).num) ...
                        '*' num2str(scale, '%4.2f')];
   end
   
   axis tight
   legend(legend_plot); legend_plot = [];
   legend boxoff

   % 6) matched sample data
   subplot(3,2,6);
   hold all;
   title(['sample matched (' num2str(match_range(1)), ', ', ...
          num2str(match_range(2)), ')']);
   xlabel(['Q (' char(197) '^{-1})'])
   ylabel('I(Q)');
   if isfield(sIqgetx(i), 'samimgs')
      for k=1:length(sIqgetx(i).samimgs)
         if (k == 1)
            dummy = sIqgetx(i).samimgs(1).iq;
            scale = 1.0;
         else
            [dummy(:,:), scale] = match(sIqgetx(i).samimgs(k).iq, ...
                                        sIqgetx(i).samimgs(1).iq, match_range);
         end
         plot(sIqgetx(i).samimgs(k).iq(:,1), ...
              sIqgetx(i).samimgs(k).iq(:,2)*scale, ...
              style_plot{max([mod(k,length(style_plot)+1),1])});
         legend_plot{k} = [sIqgetx(i).samimgs(k).prefix ...
                           int2str(sIqgetx(i).samimgs(k).num) '*' ...
                           num2str(scale, '%4.2f')];
      end
   end
   axis tight
   legend(legend_plot); legend_plot = [];
   legend boxoff

   annotation('TextBox', [0.36,0.985,0.28,0.005], 'FitHeightToText', 'on', ...
           'HorizontalAlignment', 'center', 'VerticalAlignment', ...
           'middle', 'String', sIqgetx(1).title);

   if (savefigure == 1)
      saveps(gcf, [sIqgetx(i).label '_V' int2str(i) '.ps']);
   end
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% --- Change History:
%
% $Log: iqgetx_plotV.m,v $
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