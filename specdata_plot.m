function hplot = specdata_plot(specdata, varargin)

verbose = 1;
new_figure = 0;

ix=1;
iy=2;
pointer=0; % whether to plot an arrow on the boundary
automatch=0;
matchrange = [-inf, +inf];
plotopt = 's--';
parse_varargin(varargin);

if (new_figure == 1)
   figure;
end
hold all;
for i=1:length(specdata)
   if (automatch == 1) && (i ~= 1)
      data = match(specdata(i).data(:,[ix,iy]), specdata(1).data(:, ...
                                                        [ix,iy]), ...
                   matchrange, varargin);
   else
      data = specdata(i).data(:,[ix,iy]);
   end
   
   hplot = xyplot(data, plotopt);
   if (pointer == 1)
      set(arrow(data(1,:), data(2,:)), 'FaceColor', get(hplot, 'Color'));
      set(arrow(data(end-1,:), data(end,:)), 'FaceColor', get(hplot, 'Color'));
   end
end
xlabel(specdata(1).columnnames{ix});
ylabel(specdata(1).columnnames{iy});
title(specdata(1).title);
