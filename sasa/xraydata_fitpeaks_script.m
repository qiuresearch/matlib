
% Used variables:
%  datadir samnames xvalues peakrange peakname x_label numplots_slice
%  flag_saveall flag_plot flag_osmotic flag_dnapeak flag_hexagonal
%
%  PEG_weights: [PEG%_nominal, PEGweight, Bufweight, PEG%_actual]
%
%

y_label = 'Inter-axial Distance (A)';

% 1) fit to get all the peaks

clear peakpar hpeakplot;
hpeakplot = [];
suffix = '.iq';

% check whether samnames is a numeric array or cellstr
if isnumeric(samnames);
   [fullfilenames, filenames, samnames] = gwxray_getfilebynum(samnames, 'datadir', ...
                                                   datadir, 'suffix', suffix);
end

for i=1:length(samnames)
   
   % can think of getting data info from siqgetx later
   iqdata = loadxy([datadir samnames{i} suffix]);
   if isempty(iqdata)
      disp(['No data found for ' samnames{i}])
      continue
   end

   % adding the background data in 5th column
   if exist('flag_addbkg', 'var') && (flag_addbkg == 1) && ...
          (length(iqdata(1,:)) >= 5);
      iqdata(:,2) = iqdata(:,2) + iqdata(:,5);
   end
   
   % raw data
   samdata(i).x = xvalues(i);
   samdata(i).iqraw = iqdata;
   samdata(i).iq = iqdata;
  
   % change [center, width] to [min,max] for "peak_range"
   if exist('flag_peakpos', 'var') && (flag_peakpos == 1);
       peakwidth = peakrange(i,2);
       peakrange(i,[1,2]) = [peakrange(i,1)-peakwidth/2, peakrange(i,1)+ ...
                           peakwidth/2];
       imin = locate(samdata(i).iq(:,1), peakrange(i,1));
       imax = locate(samdata(i).iq(:,1), peakrange(i,2));
       % find the max
       [dummy, icen] = max(samdata(i).iq(imin:imax,2));
       peakrange(i,1) = samdata(i).iq(imin+icen-1,1)-peakwidth/2;
       peakrange(i,2) = samdata(i).iq(imin+icen-1,1)+peakwidth/2;
   end
   
   % removing a linear background defined by peak range
   if exist('flag_subbaseline', 'var') && (flag_subbaseline == 1);
      imin = locate(samdata(i).iq(:,1), peakrange(i,1));
      imax = locate(samdata(i).iq(:,1), peakrange(i,2));
      samdata(i).iq(:,2) = samdata(i).iq(:,2) - ...
          (samdata(i).iq(:,1)-samdata(i).iq(imin,1))* ...
          (samdata(i).iq(imax,2)-samdata(i).iq(imin,2))/ ...
          (samdata(i).iq(imax,1)-samdata(i).iq(imin,1)) - samdata(i).iq(imin,2);
   end

   % multiply the I(Q) by Q.^peakrange(i,3)
   if (length(peakrange(i,:)) > 2) && (peakrange(i,3) ~= 0)
       samdata(i).iq(:,2) = samdata(i).iq(:,2).*(samdata(i).iq(:,1).^peakrange(i,3));
   end
   
   fitres = fit_onepeak(samdata(i).iq, peakrange(i,1), peakrange(i,2), ...
                        'dnapeak', flag_dnapeak, 'noslope', flag_noslope, ...
                        'gauss', flag_gauss);
   samdata(i).peakpar = [fitres.par_fit, fitres.par_init(1), fitres.chi2];
   samdata(i).peakerror = [fitres.par_error', 0, 0];

   % compile all peak information into an array
   % [x, peakpos, peak_width, peakpos_err]

   peakpar(i,:) = [samdata(i).x, samdata(i).peakpar(1), ...
                    abs(samdata(i).peakpar(2)), samdata(i).peakerror(1), ...
                    samdata(i).peakerror(2)];

   if issparse(peakpar)
      peakpar = full(peakpar);
   end
   
   % plot the peak fitting result
   if (mod(i, numplots_slice(1)*numplots_slice(2)) == 1)
      hpeakplot = [hpeakplot figure_fullsize];
      figure_format('smallprint');
      haxes = axes_create(numplots_slice(1), numplots_slice(2), ...
                          'xmargin', 0, 'ymargin', 0);
      figure_paperpos(gcf, 'kingsize');
   end
   iplot = mod(i, numplots_slice(1)*numplots_slice(2));
   if (iplot == 0);
      iplot = numplots_slice(1)*numplots_slice(2);
   end
   axes(haxes(iplot)); set(haxes(iplot), 'XAxisLocation', 'Top'); hold all

   % subtract the baseline, and show the peak center
   fitres.y0 = fitres.y0 - (fitres.par_fit(4)+fitres.par_fit(5)*fitres.x0);
   fitres.y0_fit = fitres.y0_fit - (fitres.par_fit(4)+fitres.par_fit(5)*fitres.x0);
   fitres.y_fit = fitres.y_fit - (fitres.par_fit(4)+fitres.par_fit(5)*fitres.x);
   xyfit_plot(fitres); %set(legend, 'Location', 'SouthWest', 'Fontsize', 9);
   [ymax, iymax] = max(abs(fitres.y_fit));
   if (fitres.y_fit(iymax) > 0)
      ylim([0,ymax*1.3]);
   else
      ylim([-ymax*1.3,0]);
   end
   vline(fitres.par_fit(1), 'color', 'b', 'linestyle', '--');
   puttext(0.05,0.86, {samnames{i}, num2str(2*pi/peakpar(i,2),'d_brag=%6.2fA'), ...
                      num2str(2*pi/peakpar(i,2)*2/sqrt(3),'d_hexa=%6.2fA')}, ...
           'Interpreter', 'None', 'Fontsize', 10);
end
% save plot of each peak fitting
if (flag_saveall == 1) && ~isempty(hpeakplot)
   for i=1:length(hpeakplot)
      saveps(hpeakplot(i), [peakname '_peakfit_' num2str(i) '.eps']);
   end
end
% display peak parameters
showinfo('Fitted peak parameters:')
disp(peakpar)

% 2) convert Q to DNA spacing and flip the data for osmotic series if necessary
if (flag_hexagonal == 1)
    geom_factor = 2/sqrt(3);
else
    geom_factor = 1;
end
peakpar(:,2) = 2*pi./peakpar(:,2)*geom_factor;
peakpar(:,4) = 1/2/pi*peakpar(:,4).*peakpar(:,2).*peakpar(:,2)/geom_factor;
if (flag_saveall == 1)
   specdata.scannum = 1;
   specdata.title = sprintf('%s (%2i points)', peakname, length(samnames));
   specdata.columnnames = {strrep(x_label, ' ', '_'), 'dspacing', ...
                       'peakwdith', 'd_dspacing', 'd_peakwidth'};
   specdata.data = peakpar;
   if exist('flag_osmotic', 'var') && (flag_osmotic == 1)
      specdata.columnnames = {'PEG%_actual', 'dspacing', 'peakwidth', ...
                          'd_dspacing', 'd_peakwidth'};
      specdata.data(:,1) = PEG_weights(:,4);
   end
   specdata_savefile(specdata, [peakname '_dspacing.dat']);
end

if exist('flag_osmotic', 'var') && (flag_osmotic == 1)
   peakpar = peakpar(:,[2,1,4,3,5]);
   label_tmp = x_label;  x_label = y_label;  y_label = label_tmp;

   % fit the peak
   [osmocoef, osmofitres] = osmodata_fit(peakpar(:,[1,2]));
   
   if (flag_saveall == 1)
       specdata.osmocoef = osmocoef;
       specdata.columnnames = {'dspacing', 'pressure(Pascal)', 'd_dspacing', ...
                          'peakwidth', 'd_peakwidth', 'PEG%_actual'};
      specdata.data = [peakpar,PEG_weights(:,4)];
      specdata_savefile(specdata, [peakname, '_osmoforce.dat']); 
   end
end

eval([peakname '=samdata;']);

% 3) visualization

if (flag_plot == 1)
   % Plot #1: Zoom in I(Q) around the peak, and peak position/width
   figure_fullsize; clf; 
   clear hplot;
   haxes = axes_create(2, 1, 'queensize', 0, 'xmargin', 0.1);
   axes(haxes(1)); hold all
   ymax = 0;
   for i=1:length(samnames)
      if isempty(samdata(i).iq)
         disp(['No data found for ' samnames{i}])
         continue
      end
      data = match(samdata(i).iq, [1,1], peakrange(i,[1,2]));
      data(:,2) = data(:,2) + (i-1)/20;
      hplot(i) = xyplot(data);
      ilow = locate(samdata(i).iq(:,1), peakrange(i,1));
      ipeakcen = locate(samdata(i).iq(:,1), samdata(i).peakpar(1));
      ihigh = locate(samdata(i).iq(:,1), peakrange(i,2));
      plot(data([ilow,ihigh],1), data([ilow,ihigh],2), 'ok', 'color', ...
           get(hplot(i), 'Color'), 'MarkerFaceColor', get(hplot(i), 'Color'));
      plot([samdata(i).peakpar(1), samdata(i).peakpar(1)], ...
           data([ipeakcen],2)+[-0.5,0.2], '--', 'color', get(hplot(i), ...
                                                        'Color'));
%      plot(data([ipeakcen],1), data([ipeakcen],2), 'pk', 'color', ...
%           get(hplot(i), 'Color'), 'MarkerFaceColor', get(hplot(i), 'Color'));
      ymax = max([ymax, data(ipeakcen,2)]);
   end
   legend(hplot, samnames, 'FontSize', 9, 'Interpreter', 'None', ...
          'Location', 'SouthWest'); 
   legend boxoff; xylabel('iq');
   xlim([min(peakrange(:,1)), max(peakrange(:,2))]*[1.05 -0.05; -0.05 1.05]);
   ylim([-1,ymax*1.2]);
   
   % the peak position and width data
   axes(haxes(2)); set(haxes(2), 'XColor', 'k', 'YColor', 'k'); hold all;
   xmin =min(peakpar(:,1));
   xmax = max(peakpar(:,1));
   set(xyeplot(peakpar), 'Marker', 's', 'LineStyle', 'none');

   [dummy, pressuredata] = osmocoef2energy(osmocoef, xmin-2:0.02:xmax+2);
   plot(pressuredata(:,1), log10(pressuredata(:,2)), 'b-');

   xlim([xmin,xmax]); 
   ylim([min(peakpar(:,2)), max(peakpar(:,2))]); zoomout(0.1);
   
   xlabel(x_label);  ylabel(y_label);
   legend({['osmocoef:' sprintf('(%-5.2e, %5.2fA)', osmocoef)]}, ...
          'Fontsize', 9, 'Location', 'SouthWest');
   legend boxoff;
   title(peakname, 'Interpreter', 'None');
   xlimits = get(haxes(2), 'XLim');

   % peak width
   haxes_width = axes('Position',get(haxes(2),'Position'), ...
                      'XAxisLocation','bottom', 'YAxisLocation','right', ...
                      'Color','none', 'XColor','k','YColor','r');
   plot(peakpar(:,1), abs(peakpar(:,3)), 'r<', 'LineStyle', 'none');
  
   xlim(xlimits); set(haxes_width, 'XTick', get(haxes(2), 'XTick'), ...
                                   'XTickLabel', []);
   ylabel('Peak width (/A)');
   
   if (flag_saveall == 1)
      saveps(gcf, [peakname '_dspacing.eps']);
   end
   
   % Plot #2: the I(Q) data in a single figure
   figure_fullsize; hold all;
   for i=1:length(samnames)
      if isempty(samdata(i).iq)
         disp(['No data found for ' samnames{i}])
         continue
      end
      if exist('match_range', 'var') && ~isempty(match_range)
         data = match(samdata(i).iqraw, [1,1], match_range);
      else
         data = match(samdata(i).iqraw, [1,1], peakrange(i,[1,2]));
      end
      
      hplot(i) = xyplot(data);
      ilow = locate(samdata(i).iq(:,1), peakrange(i,1));
      ipeakcen = locate(samdata(i).iq(:,1), samdata(i).peakpar(1));
      ihigh = locate(samdata(i).iq(:,1), peakrange(i,2));
      plot(data([ilow,ihigh],1), data([ilow,ihigh],2), 'ok', 'color', ...
           get(hplot(i), 'Color'), 'MarkerFaceColor', get(hplot(i), 'Color') );
      plot([samdata(i).peakpar(1), samdata(i).peakpar(1)], ...
           data([ipeakcen],2)+[-0.5,0.2], '--', 'color', get(hplot(i), ...
                                                        'Color'));
%      plot(data([ipeakcen],1), data([ipeakcen],2), 'pk', 'color', ...
%           get(hplot(i), 'Color'), 'MarkerFaceColor', get(hplot(i), 'Color'));
   end
   legend(hplot, samnames, 'FontSize', 9, 'Interpreter', 'None');
   legend boxoff; xylabel('iq');
   set(gca, 'YScale', 'Linear');
   xlim([min(peakrange(:,1))-0.05, max(peakrange(:,2))+0.05]);
   ylim auto
   grid on
   savefigps(gcf, [peakname '_iq']);
end

if flag_closeall; close all; end