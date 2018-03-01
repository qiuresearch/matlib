function varargout = xtick(ha, num)

if (nargin < 1)
   get(gca, 'XTICK')
   return
end

if (nargin < 2)
   num = ha;
   ha = gca;
end

xlimit = get(ha, 'XLIM');

gridsize = (xlimit(2)-xlimit(1))/(num-1);

gridsize = str2num(sprintf('%0.2e', gridsize));

tickarr = str2num(sprintf('%0.2e', xlimit(1))) + (0:(num-1))* gridsize;

set(ha, 'XTICK', tickarr);

