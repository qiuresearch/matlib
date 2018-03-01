function dmax = gnom_optimizeDmax(gnomcfg, dmax)

verbose = 1;
if ~exist('dmax', 'var') || isempty(dmax)
   dmax =  [-30:5:30] + gnomcfg.RMAX.value;
end

for i = 1:length(dmax)
   gnomcfg.RMAX.value= dmax(i);
   sgnom(i) = gnom_runcfg(gnomcfg);
end

% first check the chi2
rubric_data = [sgnom.chi2]./[sgnom.total_estimate];

[ymin, imin] = min(rubric_data);

if (imin ~= 1) && (imin ~= length(dmax))
   showinfo(sprintf('Local minimum Chi2=%0.2f is found at dmax=%0.1f', ...
                    sgnom(imin).chi2, dmax(imin)));
   dmax = dmax(imin);
else
   showinfo(sprintf(['No local minimum in Chi2 found! (dmax=0.1f ' ...
                     'Chi2=%0.2f; dmax=0.1f Chi2=%0.2f)'], dmax(1), ...
                    sgnom(1).chi2, dmax(end), sgnom(end).chi2));
   dmax = dmax(1);
end
