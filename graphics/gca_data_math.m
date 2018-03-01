function [hline, data] = gca_data_math(mathstr, varargin)
% --- Usage:
%        [hline, data] = gca_data_math(mathstr, varargin)
%
% --- Purpose:
%        To manipulate data in current axis, or passed through
%        varargin
%
% --- Return(s): 
%
% --- Parameter(s):
%        mathstr - example: 'x=x; y=log(y);'
%
%        varargin   -  'ha': which axis
%                   'hline': which lines
%
% --- Example(s):
%
% $Id: gca_data_math.m,v 1.1 2013/04/03 16:06:07 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

% default settings
ha = gca;
hline = [0];
for i_axis =1:length(ha)
  hline = [hline; findobj(ha(i_axis), 'Type', 'line')];
end
hline = hline(2:end);

parse_varargin(varargin);

% math operation
for i = 1:length(hline)
   x = get(hline(i), 'XDATA')';
   y = get(hline(i), 'YDATA')';
   
   eval([mathstr ';']);
   
   set(hline(i), 'XDATA', x', 'YDATA', y');
end
