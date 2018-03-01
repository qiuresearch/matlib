function [hfig_all, hfig_fit] = osmodata_fitplot(fitres, dspacing)

   global symbolorder colororder

   hfig_all = figure_fullsize(figure()); 
   set(hfig_all, 'PaperPosition', [0.25,1,8,4.5], 'DefaultAxesFontSize', ...
                 10, 'DefaultLineLineWidth', 1.2, 'DefaultLineMarkerSize', 6);
   
   hfig_fit = figure_fullsize(figure());
   set(hfig_fit, 'PaperPosition', [0.5,0.5,8,10], 'DefaultAxesFontSize', ...
                 10, 'DefaultLineLineWidth', 1.2, 'DefaultLineMarkerSize', ...
                 6, 'DefaultTextFontSize', 10);
   haxes_fit = axes_create(3,4,'xmargin', 0, 'ymargin', 0);
   
   % get xmin, xmax, ymin, ymax
   xmin = Inf; xmax = -Inf; ymin = Inf; ymax = -Inf;
   
   for i=1:length(fitres)
      if iscell(fitres)
         fitres_tmp = fitres{i};
      else
         fitres_tmp = fitres(i);
      end
      if isfield(fitres_tmp, 'scale') && (fitres_tmp.scale ~= 1)
          % fitting was on the exponential force
          xmin = min([xmin; fitres_tmp.x+fitres_tmp.dmin]);
          xmax = max([xmax; fitres_tmp.x+fitres_tmp.dmin]);
          ymin = min([ymin; log10(fitres_tmp.y/fitres_tmp.scale)]);
          ymax = max([ymax; log10(fitres_tmp.y/fitres_tmp.scale)]);
      else
          xmin = min([xmin; fitres_tmp.x]);
          xmax = max([xmax; fitres_tmp.x]);
          ymin = min([ymin; fitres_tmp.y]);
          ymax = max([ymax; fitres_tmp.y]);
      end
   end
   
   % plot
   figure(hfig_all);
   subplot(2,2,1); hold all;
   err_offset = round(ymin-1);
   xlim([xmin-1,xmax+1]);
   ylim([err_offset-0.5, ymax+0.5]);
   hline(err_offset, 'color', 'k', 'linestyle', '--');
   
   subplot(2,2,2); hold all;
   xlim([xmin-1,xmax+1]); logy;
   
   figure(hfig_fit);
   for i=1:3:length(haxes_fit)
       axes(haxes_fit(i));
       xylabel('osmoforce_pascal');
       xlabel([]);
   end
   for i=length(haxes_fit)-3:length(haxes_fit)
       axes(haxes_fit(i));
       xlabel('inter-axial spacing (A)');
   end
   
   for i=1:length(fitres)
      if iscell(fitres)
         fitres_tmp = fitres{i};
      else
         fitres_tmp = fitres(i);
      end
      [energydata, pressuredata] = osmocoef2energy(fitres_tmp.osmocoef, ...
                                                   20:0.02:max(40, xmax+2), ...
                                                   fitres_tmp.DNA_Equilibrium_Spacing);
      osmocoef(i,:) = fitres_tmp.osmocoef;
      clear osmodata
      if isfield(fitres_tmp, 'scale') && (fitres_tmp.scale ~= 1)
          osmodata(:,1) = fitres_tmp.data(:,1) + fitres_tmp.dmin;
          osmodata(:,2) = log10(fitres_tmp.data(:,2)/fitres_tmp.scale);
          osmodata(:,3) = fitres_tmp.data(:,4)./fitres_tmp.data(:,2)/log(10);
      else
          osmodata = fitres_tmp.data(:,[1,2,4]);
      end
      
      [dummyenergy, dummypressure] = osmocoef2energy(fitres_tmp.osmocoef, ...
                                     osmodata(:,1), fitres_tmp.DNA_Equilibrium_Spacing);
      osmodata(:,4) = osmodata(:,2)-log10(dummypressure(:,2)) + err_offset;
      
      % #1) Pressure vs distance
      for ii=1:2
          switch ii
            case 1
              figure(hfig_fit); axes(haxes_fit(i));
            case 2
              figure(hfig_all); subplot(2,2,1);
            otherwise
          end
              
          hexpt(i)= errorbar(osmodata(:,1), osmodata(:,2), osmodata(:,3), ...
                             symbolorder{i}, 'Color', colororder(i,:));
          %  'MarkerEdgeColor', colororder(i,:),  'MarkerFaceColor', 'w', ... %colororder(i,:), ...
          
          plot(osmodata(:,1), osmodata(:,4), symbolorder{i}, 'color', colororder(i,:));
          
          if isempty(fitres_tmp.DNA_Equilibrium_Spacing) || ...
                  (fitres_tmp.DNA_Equilibrium_Spacing < 1)
              ieq = sum(pressuredata(:,2)>0); % only plot positive values
          else
              ieq = locate(pressuredata(:,1), fitres_tmp.DNA_Equilibrium_Spacing);
          end
          
          set(plot(pressuredata(1:ieq,1), log10(pressuredata(1:ieq,2))), ...
              'color', colororder(i,:));
          
          % some cosmetics
          if isfield(fitres_tmp, 'title')
              lege{i} = [fitres_tmp.title, sprintf(' (%-5.2e, %5.2fA)', ...
                                                   fitres_tmp.osmocoef)];
          else
              lege{i}=sprintf('COEF (%-5.2e, %5.2fA)', fitres_tmp.osmocoef);
          end
          
          % add an arrow at DNA_Equilibrium_Spacing
          ylimit = get(gca, 'Ylim');
          if ~isempty(fitres_tmp.DNA_Equilibrium_Spacing) && ...
                  (fitres_tmp.DNA_Equilibrium_Spacing > 1);
              arrow([fitres_tmp.DNA_Equilibrium_Spacing,0.85*ylimit(1)+ ...
                     0.15*ylimit(2)], [fitres_tmp.DNA_Equilibrium_Spacing, ...
                                  0.98*ylimit(1)+0.02*ylimit(2)], ...
                    'linewidth', 1.8, 'baseangle', 45, 'EdgeColor', ...
                    colororder(i,:), 'FaceColor', colororder(i,:));
          end
          
          % annotate pressure at given d spacings
          if exist('dspacing', 'var') && ~isempty(dspacing)
              ishow = locate(pressuredata(:,1), dspacing);
              puttext(0.1,0.2, sprintf('(%5.2fA, %6.2e)', pressuredata(ishow,1:2)));
          end
          
          % additional setting for the "hfig_fit"
          if (ii == 1)
              hline(err_offset, 'color', 'k', 'linestyle', '--');
              xlim([min(osmodata(:,1))-0.5, max(osmodata(:,1))+ 0.5]);
              ylim([err_offset-0.5, max(osmodata(:,2))+0.5]);
              %legend(hexpt(i), lege{i}); legend boxoff;
              puttext(0.05,0.35, strrep(lege{i}, '(', sprintf('\n(')));
          end
      end
      
      % #2) Energy vs distance
      figure(hfig_all);
      subplot(2,2,2);
      xyplot(energydata, [symbolorder{i} '-']);
      if exist('dspacing', 'var') && ~isempty(dspacing)
         ishow = locate(energydata(:,1), dspacing);
         puttext(0.5,0.6, sprintf('(%5.2fA, %6.2e)', energydata(ishow,1:2)));
      end
   end
   
   subplot(2,2,1); 
   osmolabel;
   % legend(hexpt, lege, 'FontSize', 6, 'Location', 'NorthEast'), legend boxoff;

   subplot(2,2,2);
   osmolabel; ylabel('Energy (kT/A)');
   legend(lege, 'FontSize', 6); legend boxoff; 
   % set(hline(0.0), 'Color', 'k');

   [num_rows, num_cols] = size(osmocoef);

   % force coefficient
   subplot(2,2,3); hold all;
   xlabel('curve #');
   ylabel('force coefficient 1');
   if (num_cols <= 2)
       plot(1:num_rows, osmocoef(:,1), 's-');
   else
       [ax, h1, h2] = plotyy(1:num_rows, osmocoef(:,1), 1:num_rows, osmocoef(:, 3));
       set([h1,h2], 'Marker', 's');
       %       axis(ax(2)); ylabel('force coefficient 2');
   end
   
   % decay length
   subplot(2,2,4); hold all
   xlabel('curve #');
   ylabel('decay length');
   if (num_cols <= 3)
       plot(1:num_rows, osmocoef(:,2), 's-');
   else
       [ax, h1, h2] = plotyy(1:num_rows, osmocoef(:,2), 1:num_rows, osmocoef(:, 4));
       set([h1,h2], 'Marker', 's');
       %       axis(ax(2));  ylabel('decay length 2');
   end
