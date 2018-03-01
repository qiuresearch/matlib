function hl = hline(ydata, varargin)
% --- Usage:
%        hl = hline(ydata, varargin)
% --- Description:
%        draw horizontal lines at positions given by ydata. 
%
% $Id: hline.m,v 1.4 2015/09/27 20:39:48 schowell Exp $
%

if nargin < 1
   help hline
   return
end

linestyle = ':';
color = [.2 .2 .2];
parse_varargin(varargin)

hl = graph2d.constantline(ydata, 'color', color, 'linestyle', linestyle);
changedependvar(hl,'y');
