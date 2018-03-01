function vl = vline(xdata, varargin)
% --- Usage:
%        vl = vline(xdata, varargin)
% --- Description:
%        draw horizontal lines at positions given by ydata. 
%        varargin - 'xlimit':
%
% $Id: vline.m,v 1.9 2015/09/27 20:39:48 schowell Exp $

if nargin < 1
   help hline
   return
end

linestyle = ':';
color = [.2 .2 .2];
parse_varargin(varargin);

vl = graph2d.constantline(xdata, 'color', color, 'linestyle', linestyle);
changedependvar(vl,'x');
