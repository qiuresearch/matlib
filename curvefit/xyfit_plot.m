function hfigure = xyfit_plot(fitres, varargin);

plot_init = 0;
parse_varargin(varargin);

plot(fitres.x0, fitres.y0, '.');
if (plot_init == 1)
   plot(fitres.x, fitres.y_init);
end
hplot = plot(fitres.x0, fitres.y0_fit);

par_text = '';
for i=1:length(fitres.par_fit)
   par_text = [par_text fitres.par_names{i} sprintf(':  %0.4g\n', ...
                                                    fitres.par_fit(i))];
end

legend_add(hplot, par_text, 'Interpreter', 'None'); legend boxoff
xlim(sort([fitres.x(1), fitres.x(end)]));
ylim auto

