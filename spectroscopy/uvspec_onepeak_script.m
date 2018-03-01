% Note on Variable Names:
%    Variables with a mix of lower and upper cases 

clear specdata uvspec peakdata peakdata_colnames

sBkgMethod = {'baseline', 'bufferdata'};
if ~exist('iBkgMethod', 'var') || isempty(iBkgMethod)
   iBkgMethod = 1;
end

sPeakMethod = {'ODmax', 'peak fitting', 'slope fitting', ['peak ' ...
                    'fitting-bkg slope'], 'ODmax-bkg slope'};
if ~exist('iPeakMethod', 'var') || isempty(iPeakMethod)
   iPeakMethod = 3;
end

for i = 1:length(samnames)
   
   % 1) read the spectrum
   specdata =uvspec_readspectrum([FilePrefix samnames{i} FileSuffix]);
   specdata.rawdata = specdata.data;
   data = specdata.rawdata;
   
   % 2) background removal
   specdata.sBkgMethod = sBkgMethod;
   specdata.iBkgMethod = iBkgMethod;
   switch iBkgMethod
      case 1 % baseline
         specdata.iminbkg = locate(data(:,1), XMinBkg);
         specdata.imaxbkg = locate(data(:,1), XMaxBkg);
         specdata.bkgdata = mean(data(specdata.iminbkg:specdata.imaxbkg, 2));
         data(:,2) = data(:,2) - specdata.bkgdata;
      case 2 % buffer data
         specdata.BkgData = BkgData;
         if ischar(BkgData)  % in another file
            specdata.bkgdata = uvspec_readspectrum(BkgData);
         else % two dimension data
            specdata.bkgdata = BkgData;
         end
         data(:,2) = data(:,2) - specdata.bkgdata(:,2);
      otherwise
         specdata.bkgdata = 0;
   end
   specdata.data = data;
   
   % 3) extract the absorption peak
   imin = locate(data(:,1), XMin);
   imax = locate(data(:,1), XMax);
   switch iPeakMethod
      case 1   % Method #1: peak search
         [ymax, iy] = max(data(imin:imax,2));
         specdata.peakdata = [xvalues(i), ymax, data(imin+iy-1,1)];
      case 2  % Method #2: peak fitting
         fitres = xyfit(data(imin:imax,:), 'lorentz', [(XMin+XMax)/2, ...
                             (XMax-XMin)/3, (XMax-XMin)*0.2]);
         specdata.peakfit = [fitres.x0, fitres.y0_fit];
         specdata.peakdata = [xvalues(i), max(fitres.y0_fit), fitres.par_fit(1)];
   end
   
   % 4) Find baseline and correct the Dilutuion factor
   if (length(specdata.bkgdata) > 2)
      specdata.peakdata(4) = specdata.bkgdata(locate(specdata.bkgdata(:,1), ...
                                                     specdata.peakdata(3)), 2);
   else
      specdata.peakdata(4) = specdata.bkgdata(1);
   end
   if ~exist('Dilution_Factor', 'var') || isempty(Dilution_Factor)
      Dilution_Factor = 1;
   end
   specdata.peakdata([2,4]) = specdata.peakdata([2,4])*Dilution_Factor;
   specdata.title = [specdata.title '-' samnames{i}];
   
   % 5) pool data together
   uvspec(i) = specdata;
   peakdata(i,:) = specdata.peakdata;
end
   
% 6) save data
spec_stru.title = [SaveFileName ' Peak method: ' sPeakMethod{iPeakMethod}];
spec_stru.columnnames = {strrep(xname, ' ', '-'), 'ODmax', 'Lambdamax', ...
                    'Baseline'};
if isfield(specdata, 'pathlength')
   spec_stru.pathlength = specdata.pathlength;
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
hline=zeros(length(samnames),1);
for i=1:length(samnames)
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
for i=1:length(samnames)
   hline(i)=xyplot(uvspec(i).data);
   if isfield(uvspec(i),  'peakfit')
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
                       XMinBkg, XMaxBkg);
   case 2
      bkgstr = [sBkgMethod(iBkgMethod) '<' BkgData '>'];
end
title([SaveFileName ', BkgMethod: ' bkgstr], 'Interpreter', 'None', ...
      'FontSize', fontsize);
axis tight; zoomout(0.07);

% Peak data
axes(hAxes(3)); hold all
hline=plot(peakdata(:,1), peakdata(:,2), symbolorder{1});
hline(2)=plot(peakdata(:,1), peakdata(:,2)+peakdata(:,4), symbolorder{2});
axis tight; zoomout(0.07); 
title(sprintf('Peak between [%1.0f,%1.0f], Method: %s', XMin, XMax, ...
              sPeakMethod{iPeakMethod}), 'FontSize', fontsize);
xlabel(xname); ylabel('Peak OD');
legend_add(hline, {SaveFileName, [SaveFileName '+baseline']}, ...
           'Interpreter', 'None', 'FontSize', fontsize);
legend boxoff;

% Numerical data output
axes(hAxes(4));

peakstr = num2str(peakdata, '%-06.3g');
text(0.1, 0.98, [xname, ' | PeakOD', ' | \lambda', ' | baseline'], ...
     'VerticalAlignment', 'Top');

text(0.1,0.9, peakstr, 'VerticalAlignment', 'Top', 'FontName', 'fixedwidth');
