function varargout = ytick(ha, num)
%        varargout = ytick(ha, num)

if (nargin < 1)
   get(gca, 'YTICK')
   return
end

if (nargin < 2)
   num = ha;
   ha = gca;
end

ylimit = get(ha, 'YLIM');

gridsize = (ylimit(2)-ylimit(1))/(num-1);

gridsize = str2num(sprintf('%0.2g', gridsize));

tickarr = str2num(sprintf('%0.2g', ylimit(1))) + (0:(num-1))* gridsize;

set(ha, 'YTICK', tickarr);

