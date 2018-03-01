function ha = aspect_ratio(ha, factor, varargin)
% --- Usage:
%        ha = aspect_ratio(ha, factor, varargin)
% --- Description:
%        change the aspect ratio of the axis in real prints. The ratio
%        is set to Y/X
%
% $Id: aspect_ratio.m,v 1.2 2013/02/28 16:52:10 schowell Exp $
%
if ~exist('factor', 'var')
   factor = 0.618; % the golden number
end

hf = get(ha, 'Parent');
papersize = get(hf, 'PaperSize');
paperpos = get(hf, 'PaperPosition');
axispos = get(ha, 'Position');

axissize = axispos(3:4).*paperpos(3:4);

if (axissize(2)/axissize(1) > factor)
   axispos(4) = axispos(4)*axissize(1)/axissize(2)*factor;
else
   axispos(3) = axispos(3)*axissize(2)/axissize(1)/factor;
end
set(ha, 'Position', axispos);
