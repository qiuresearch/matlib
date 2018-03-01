function [hline, data] = gca_save_alldata(varargin)
% --- Usage:
%        [hline, data] = rematch_data_gca(match_range)
%
% --- Purpose:
%
% --- Return(s): 
%
% --- Parameter(s):
%        varargin   -  'ha'
%
% --- Example(s):
%
% $Id: gca_data_saveall.m,v 1.1 2013/04/03 16:06:07 xqiu Exp $
%

verbose = 1;
if nargin == 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end
ha = gca;
filenames = [];
suffix = '.iq';

parse_varargin(varargin);

hline = [0];
for i_axis =1:length(ha)
  hline = [hline; findobj(ha(i_axis), 'Type', 'line')];
end
hline = hline(2:end);

for i = 1:length(hline)
   xydata = [get(hline(i), 'XDATA')', get(hline(i), 'YDATA')'];
   switch length(filenames)
      case 0
         fname = [get(hline(i), 'DisplayName') suffix];
      case 1
         fname = [filenames '_' num2str(i) suffix]; 
      otherwise
         fname = [filenames{i} suffix];
   end
   saveascii(xydata, fname);
   showinfo(sprintf('saving data #%i to: %s', i, fname));
end
