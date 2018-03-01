function [xlimit, ylimit] = autolimit(plotype, varargin)
% --- Usage:
%        [xlimit, ylimit] = autolimit(plotype, varargin)
%
% --- Purpose:
%         It is meant to work for I(Q)s to determine the "optimal"
%         limits for plots
% --- Return(s): 
%
% --- Parameter(s):
%        varargin   -  'ha'
%
% --- Example(s):
%
% $Id: autolimit.m,v 1.4 2015/09/25 19:03:16 schowell Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end
offset = 0;
ha = gca;
parse_varargin(varargin);

% initialize
xlimit = [Inf, -Inf];
ylimit = [Inf, -Inf];

% get handles to all plotted data
hline = [];
for i_axis =1:length(ha)
  hline = [hline; findobj(ha(i_axis), 'Type', 'line')];
end

switch upper(plotype)
   case upper('loglog')
      for i = 1:length(hline)
         % use the first 10% of the data to find out the point
         % with sharpest rise, presumably from beam stop to real data
         xydata = [get(hline(i), 'XDATA')', get(hline(i), 'YDATA')'];
         if (length(xydata) > 2) && isnan(xydata(3,1)); continue; end % skipping error bar data

         difdata = (xydata(2:end,2)-xydata(1:end-1,2))./(xydata(2:end,1)-xydata(1:end-1,1));
         [maxslope, imaxslope] = max(difdata(1:fix(end/10)));
         if ~isempty(maxslope)
             if (maxslope <= 0) || (imaxslope > 50); imaxslope = 1; end
         else
             imaxslope = 1;
         end
         xlimit(1) = min(xlimit(1), xydata(imaxslope,1));
         xlimit(2) = max(xlimit(2), xydata(end,1));
         
         ylimit(1) = min(ylimit(1), min(abs(xydata(:,2))));
         ylimit(2) = max(ylimit(2), max(xydata(1:end/2,2)));
      end
      xlimit = xlimit.*[0.94,1.05];
      ylimit(2) = ylimit(2)*1.2;
   case upper('kratky') % kratky
      for i = 1:length(hline)
         % use the first half of the data to find out the point
         % with sharpest rise, presumably from beam stop to real data
         xydata = [get(hline(i), 'XDATA')', get(hline(i), 'YDATA')'];
         if (length(xydata) > 2) && isnan(xydata(3,1)); continue; end % skipping error bar

         xlimit(1) = min(xlimit(1), xydata(1,1));
         xlimit(2) = max(xlimit(2), xydata(end,1));
         
         ylimit(1) = min(ylimit(1), min(xydata(:,2)));
         ylimit(2) = max(ylimit(2), max(xydata(1:end/2,2)));
      end
      ylimit(1) = max(ylimit(1), 0);
      ylimit(2) = ylimit(2)*1.1;
   otherwise
      disp('label option not supported yet, no change')
end
xlim(xlimit);
ylim(ylimit);
