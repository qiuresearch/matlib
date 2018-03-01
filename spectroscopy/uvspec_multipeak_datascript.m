% Note on Variable Names:
%    Variables with a mix of lower and upper cases 

clear uvspec peakdata peakdata_colnames

sBkgMethod = {'baseline', 'bufferdata'};
if ~exist('iBkgMethod', 'var') || isempty(iBkgMethod)
   iBkgMethod = 1;
end

sPeakMethod = {'ODmax', 'peak fitting', 'slope fitting', ['peak ' ...
                    'fitting-bkg slope'], 'ODmax-bkg slope'};
if ~exist('iPeakMethod', 'var') || isempty(iPeakMethod)
   iPeakMethod = 3;
end

%s specdata = [];
%s for ifile = 1:length(specfiles)
%s    % 1) read the spectrum
%s    specdata = [specdata, uvspec_readspectrum([FilePrefix specfiles{ifile} FileSuffix])];
%s end

if exist('iSkipped', 'var') && ~isempty(iSkipped)
   if (length(samnames) == length(specdata))
      samnames(iSkipped) = [];
   end
   xvalues(iSkipped) = [];
   specdata(iSkipped) = [];
end

uvspec = [];
peakdata = [];
for i = 1:length(specdata)
   specdata(i).rawdata = specdata(i).data;
   data = specdata(i).rawdata;
   
   % 2) background removal
   specdata(i).sBkgMethod = sBkgMethod;
   specdata(i).iBkgMethod = iBkgMethod;
   switch iBkgMethod
      case 1 % baseline
         specdata(i).iminbkg = locate(data(:,1), BkgData(1));
         specdata(i).imaxbkg = locate(data(:,1), BkgData(2));
         specdata(i).bkgdata = mean(data(specdata(i).iminbkg:specdata(i).imaxbkg, 2));
         data(:,2) = data(:,2) - specdata(i).bkgdata;
      case 2 % buffer data
         specdata(i).BkgData = BkgData;
         if ischar(BkgData)  % in another file
            specdata(i).bkgdata = uvspec_readspectrum(BkgData);
         else % two dimension data
            specdata(i).bkgdata = BkgData;
         end
         data(:,2) = data(:,2) - specdata(i).bkgdata(:,2);
      otherwise
         specdata(i).bkgdata = 0;
   end
   specdata(i).data = data;
   
   % 3) extract the absorption peak
   specdata(i).peakdata = xvalues(i);
   specdata(i).peakfit = [];
   for ip = 1:length(PeakData(:,1))
      imin = locate(data(:,1), PeakData(ip,1));
      imax = locate(data(:,1), PeakData(ip,2));
      switch iPeakMethod
         case 1   % Method #1: peak search
            [ymax, iy] = max(data(imin:imax,2));
            specdata(i).peakdata = [specdata(i).peakdata, ymax, data(imin+iy-1,1)];
         case 2  % Method #2: peak fitting
            fitres = xyfit(data(imin:imax,:), 'lorentz', ...
                           [(PeakData(ip,1)+PeakData(ip,2))/2, ...
                            (PeakData(ip,2)-PeakData(ip,1))/3, ...
                            (PeakData(ip,2)-PeakData(ip,1))*0.2]);
            specdata(i).peakfit = [specdata(i).peakfit, fitres.x0, fitres.y0_fit];
            specdata(i).peakdata = [specdata(i).peakdata, max(fitres.y0_fit), fitres.par_fit(1)];
      end
      
      % 4) Find baseline 
      if (length(specdata(i).bkgdata) > 2)
         specdata(i).peakdata = [specdata(i).peakdata, ...
             specdata(i).bkgdata(locate(specdata(i).bkgdata(:,1), ...
                                     specdata(i).peakdata(3*ip)), 2)];
      else
         specdata(i).peakdata = [specdata(i).peakdata, specdata(i).bkgdata(1)];
      end
   end
   
   % correct the Dilutuion factor
   if ~exist('Dilution_Factor', 'var') || isempty(Dilution_Factor)
      Dilution_Factor = 1;
   end
   if (length(Dilution_Factor) < i)
      specdata(i).peakdata([2,4]) = specdata(i).peakdata([2,4])* Dilution_Factor(1);
   else
      specdata(i).peakdata([2,4]) = specdata(i).peakdata([2,4])* Dilution_Factor(i);
   
   end
   if exist('samnames', 'var') && (length(samnames) == length(specdata))
      specdata(i).title = samnames{i};
   else
      specdata(i).title = [specdata(i).title '-' specdata(i).samnames];
   end
   
   % 5) pool data together
   uvspec = [uvspec, specdata(i)];
   peakdata = [peakdata; specdata(i).peakdata];
end
   
% 6) save data
spec_stru.title = [SaveFileName ' Peak method: ' sPeakMethod{iPeakMethod}];
peaknames = repmat({'ODmax', 'Lambdamax', 'Baseline'}, 1, length(PeakData(:,1)));
spec_stru.columnnames = {strrep(xname, ' ', '-'), peaknames{:}};
if isfield(specdata, 'pathlength')
   spec_stru.pathlength = specdata(1).pathlength;
end
spec_stru.data = peakdata;
specdata_savefile(spec_stru, [SaveFileName '.dat']);
 
% 7) Plot
if ~exist('hAxes', 'var') || isempty(hAxes) || isempty(axescheck(hAxes(1)))
   set(gcf, 'OuterPosition', get(0, 'ScreenSize'), 'PaperPosition', ...
            [0.25,1,8,9]);
   hAxes = axes_create(2,2, 'newfigure', 0);
end
set(gcf, 'DefaultAxesFontSize', 10, 'DefaultTextFontSize', 10);
fontsize = 10;

% Raw spectrum
axes(hAxes(1)); hold all;
for i=1:length(uvspec)
   hline(i)=xyplot(uvspec(i).rawdata);
end
legend_add(hline, {uvspec.title}, 'fontsize', fontsize, 'Interpreter', ...
           'None'); legend boxoff
uvspec_label;

if isfield(uvspec(1), 'pathlength')
   titlestr = sprintf('Raw, path: %0.1fmm', uvspec(1).pathlength);
else
   titlestr = 'Raw';
end
title([SaveFileName ' ' titlestr], 'Interpreter', 'None', 'FontSize', ...
      fontsize);
axis tight; zoomout(0.07);

% baseline corrected spectrum
axes(hAxes(2)); hold all;
for i=1:length(uvspec)
   hline(i)=xyplot(uvspec(i).data);
   if isfield(uvspec(i),  'peakfit') && ~isempty(uvspec(i).peakfit)
      plot(uvspec(i).peakfit(:,1), uvspec(i).peakfit(:,2), '.--k', ...
           'color', get(hline(i), 'color'));
   end
   %   showcoord(eval([samnames{i} '.ymax']));
end
legend_add(hline, {uvspec.title}, 'fontsize', fontsize, 'Interpreter', ...
           'None'); legend boxoff;
uvspec_label;
ylabel([]);
switch iBkgMethod
   case 0
      bkgstr = 'None';
   case 1
      bkgstr = sprintf('%s [%1.0f,%1.0f]', sBkgMethod{iBkgMethod}, ...
                       BkgData(1), BkgData(2));
   case 2
      if ischar(BkgData)
         bkgstr = [sBkgMethod(iBkgMethod) '<' BkgData '>'];
      else
         bkgstr = [sBkgMethod(iBkgMethod) '<User 2D Data>'];
      end
end
title([SaveFileName ', BkgMethod: ' bkgstr], 'Interpreter', 'None', ...
      'FontSize', fontsize);
axis tight; zoomout(0.07);

% Peak data
axes(hAxes(3)); hold all
for ip = 1:length(PeakData(:,1));
   hline=plot(peakdata(:,1), peakdata(:,3*ip-1), ['b' symbolorder{ip}]);
   hline(2)=plot(peakdata(:,1), peakdata(:,3*ip-1)+peakdata(:,3*ip+1), ['r' symbolorder{ip}]);
   legend_add(hline, {num2str(PeakData(ip,:), '[%1.0f, %1.0f]'), ...
                      num2str(PeakData(ip,:), '[%1.0f, %1.0f]+baseline')}, ...
              'Interpreter', 'None', 'FontSize', fontsize);
end
axis tight; zoomout(0.07); 
title(sprintf('Peak Data of %s, Method: %s', SaveFileName, ...
              sPeakMethod{iPeakMethod}), 'FontSize', fontsize, ...
      'Interpreter', 'None');
xlabel(xname); ylabel('Peak OD');
legend boxoff;

%% Numerical data output
%axes(hAxes(4));
%
%peakstr = num2str(peakdata, '%-06.3g');
%text(0.1, 0.98, [xname, ' | PeakOD', ' | \lambda', ' | baseline'], ...
%     'VerticalAlignment', 'Top');
%
%text(0.1,0.9, peakstr, 'VerticalAlignment', 'Top', 'FontName', 'fixedwidth');

% Numerical data output
axes(hAxes(4));
for ip = 1:length(PeakData(:,1));
   hline=plot(peakdata(:,1), peakdata(:,3*ip-1)/peakdata(1,3*ip-1), ['b' symbolorder{ip}]);
   hline(2)=plot(peakdata(:,1), (peakdata(:,3*ip-1)+peakdata(:,3*ip+1))/(peakdata(1,3*ip-1)+peakdata(1,3*ip+1)), ['r' symbolorder{ip}]);
   legend_add(hline, {num2str(PeakData(ip,:), '[%1.0f, %1.0f]'), ...
                      num2str(PeakData(ip,:), '[%1.0f, %1.0f]+baseline')}, ...
              'Interpreter', 'None', 'FontSize', fontsize);
end
axis tight; zoomout(0.07); 
title('Normalized Peak Data', 'FontSize', fontsize, ...
              'Interpreter', 'None');
xlabel(xname); ylabel('Peak OD');
legend boxoff;
