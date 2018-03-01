function ha = axes_resize(factor, varargin)
% --- Usage:
%        ha = axes_resize(factor, varargin)
% --- Description:
%        resize the axes, usually for smaller print size.
%
% $Id: axes_resize.m,v 1.1 2013/01/06 06:04:27 xqiu Exp $
%
if ~exist('factor', 'var')
   factor = 0.618; % the golden number
end

ha = get(gcf, 'Children');
for i=1:length(ha)
   if strcmpi(get(ha(i),'Type'), 'axes')
      position = get(ha(i), 'Position');
      position(3:4) = position(3:4).*factor;
      set(ha(i), 'Position', position);
   end
end
