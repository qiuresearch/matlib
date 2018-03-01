function [hline, data] = rematch_data_gca(match_range, varargin)
% --- Usage:
%        [hline, data] = rematch_data_gca(match_range)
%
% --- Purpose:
%
% --- Return(s): 
%
% --- Parameter(s):
%        varargin   -  'haxis', 'scale', 'offset'
%
% --- Example(s):
%
% $Id: rematch_data_gca.m,v 1.2 2014/03/22 13:37:00 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end
scale = 1;
offset = 0;
haxis= gca;
parse_varargin(varargin);

hline = [0];
for i_axis =1:length(haxis)
  hline = [hline; findobj(haxis(i_axis), 'Type', 'line')];
end
hline = hline(2:end);

refdata = [get(hline(1), 'XDATA')', get(hline(1), 'YDATA')'];
for i = 2:length(hline)
   xydata = [get(hline(i), 'XDATA')', get(hline(i), 'YDATA')'];
   xydata = match(xydata, refdata, match_range, 'scale', scale, 'offset', offset);
   
   set(hline(i), 'YDATA', xydata(:,2)');
end
