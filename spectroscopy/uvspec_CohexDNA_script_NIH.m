
clear ODcohex_dna ODcohex_dna_colnames samnotes ha

if ~exist('iCohexMethod', 'var') || isempty(iCohexMethod)
   iCohexMethod = 3;
end

sCohexMethod = {'ODmax', 'peak fitting', 'slope fitting', ['peak ' ...
                    'fitting-bkg slope'], 'ODmax-bkg slope'};

for i = 1:length(samnames)
   
   % 1) read the DNA data and get the maximum absorption
   data = uvspec_subbaseline(uvspec_readspectrum([DIR_DNAdata ...
                       samnames{i} '.SP']), [320,360]);

   specdata = data.data; % (samnames{i});
   i250 = locate(specdata(:,1), 250);
   i270 = locate(specdata(:,1), 270);
   [ymax, iy] = max(specdata(i250:i270,2));

   data.ODmax = [specdata(i250+iy-1,1), ymax];
   dnadata.(samnames{i}) = data;


   % 2) read the Cohex data and get the maximum absorption
   data = uvspec_subbaseline(uvspec_readspectrum([samnames{i} '.SP']), ...
                             [700,720]);
   
   specdata = data.data; %(samnames{i});
   i430 = locate(specdata(:,1), 430);
   i520 = locate(specdata(:,1), 520);
   
   % there are several ways to extract the [Cohex] concentration
   switch iCohexMethod
      
      case 1   % Method #1: peak search
         [ymax, iy] = max(specdata(i430:i520,2));
         xmax = specdata(i430+iy-1,1);
      
      case 2  % Method #2: peak fitting
         i440 = locate(specdata(:,1), 440);
         i510 = locate(specdata(:,1), 510);
         fitres = xyfit(specdata(i440:i510,:), 'lorentz', [470, 100, 2]);
         data.fit = [fitres.x0, fitres.y0_fit];
         xmax = fitres.par_fit(1);
         ymax = max(fitres.y0_fit);

      case 3  % Method #3: slope fitting
         i385 = locate(specdata(:,1), 385);
         i395 = locate(specdata(:,1), 395);
         lineardata = specdata(i385:i395,:);

         i600 = locate(specdata(:,1), 600);
         i610 = locate(specdata(:,1), 610);
         lineardata = [lineardata; specdata(i600:i610,:)];
         fitres2 = xyfit(lineardata, 'linear', [-0.01, 10]);

         i495 = locate(specdata(:,1), 495);
         i520 = locate(specdata(:,1), 520);
         fitres = xyfit(specdata(i495:i520,:), 'linear', [-0.006, 5]);
         data.fit = [[fitres2.x0;nan;fitres.x0], [fitres2.y0_fit;nan;fitres.y0_fit]];
         xmax = fitres.par_fit(2);
         % number without any background slope subtraction
         % ymax = fitres.par_fit(1)*-55.15; 

         % corrected based on 081215 data with bkg_slope subtraction
         ymax = (fitres.par_fit(1)-fitres2.par_fit(1))*-55.15/0.975;
         data.baseline = fitres2.par_fit(1)*-55.15/0.975;
   
      case 4  % Method #4: peak fitting after subtracting
              % background slope
         i385 = locate(specdata(:,1), 385);
         i395 = locate(specdata(:,1), 395);
         lineardata = specdata(i385:i395,:);

         i600 = locate(specdata(:,1), 600);
         i610 = locate(specdata(:,1), 610);
         lineardata = [lineardata; specdata(i600:i610,:)];
         fitres2 = xyfit(lineardata, 'linear', [-0.01, 10]);

         specdata(:,2) = specdata(:,2) - (fitres2.par_fit(1)*specdata(:,1) ...
                                          +fitres2.par_fit(2));
         
         i440 = locate(specdata(:,1), 400);
         i510 = locate(specdata(:,1), 570);
         fitres = xyfit(specdata(i440:i510,:), 'lorentz', [470, 100, ...
                             2, 0, -0.01]);
         data.fit = [fitres.x0, fitres.y0_fit] ;
         xmax = fitres.par_fit(1);
         ymax = fitres.par_fit(3)*2/pi/fitres.par_fit(2); % lorentz
%         ymax = fitres.par_fit(3)/fitres.par_fit(2)/sqrt(2*pi); % gauss
         data.baseline = fitres.par_fit(4)+fitres.par_fit(5)* ...
             fitres.par_fit(1)+data.baseline;
         
      case 5  % Method #5: ODmax after subtracting background slope
         i385 = locate(specdata(:,1), 385);
         i395 = locate(specdata(:,1), 395);
         lineardata = specdata(i385:i395,:);

         i600 = locate(specdata(:,1), 600);
         i610 = locate(specdata(:,1), 610);
         lineardata = [lineardata; specdata(i600:i610,:)];
         fitres2 = xyfit(lineardata, 'linear', [-0.01, 10]);

         specdata(:,2) = specdata(:,2) - (fitres2.par_fit(1)*specdata(:,1) ...
                                          +fitres2.par_fit(2));

         i430 = locate(specdata(:,1), 430);
         i520 = locate(specdata(:,1), 520);
         [ymax, iy] = max(specdata(i430:i520,2));
         xmax = specdata(i430+iy-1,1);
         data.fit = [fitres2.x0, fitres2.y0_fit] ;
         data.baseline = fitres2.par_fit(2)+fitres2.par_fit(1)*xmax+data.baseline;
   end
   
   data.ODmax = [xmax, ymax];
   cohexdata.(samnames{i}) = data;
   
   % 3) convert the ODs to mM (assuming DNA 10xdilution)
   if ~exist('DNA_dilution', 'var') || isempty(DNA_dilution)
      DNA_dilution = 10;
   end
   ODdna = dnadata.(samnames{i}).ODmax(2)*50/310*DNA_dilution;
   ODdna_baseline =  dnadata.(samnames{i}).baseline*50/310*10;
   ODcohex = cohexdata.(samnames{i}).ODmax(2)/0.05711;
   ODcohex_baseline =  cohexdata.(samnames{i}).baseline/0.05711;
   
   ODcohex_dna_colnames = {xname, 'OD_CoHex', 'OD_CoHex+baseline', ...
                       'OD_DNA', 'OD_DNA+baseline'};
   ODcohex_dna(i,1:5) = [xvalues(i), ODcohex, ODcohex+ODcohex_baseline, ...
                       ODdna, ODdna+ODdna_baseline];
 
   if (ODdna<0.05) || ((ODdna+ODdna_baseline)<0.05)
       ODdna=1;
       ODdna_baseline = 0;
   end
   % charge ratio
   ODcohex_dna_colnames = {ODcohex_dna_colnames{:}, 'CoHex/DNA', ...
                       'CoHex+base/DNA+base', 'CoHex/DNA+base', ...
                       'CoHex_base/DNA'};
   ODcohex_dna(i,6:9) = 3*[ODcohex/ODdna, ...
       (ODcohex+ODcohex_baseline)/(ODdna+ODdna_baseline), ...
       ODcohex/(ODdna+ODdna_baseline), (ODcohex+ODcohex_baseline)/ODdna ];
   
   % 4) make up label for each sample
   samnotes{i} = [cohexdata.(samnames{i}).note '-' samnames{i}];
end
% convert 
%ODcohex_dna(:,[6:9]) = ODcohex_dna(:,[6:9]); %/0.05711/20*31*3;

% save the data?
spec_stru.title = [savename ' ([CoHex] using ' sCohexMethod{iCohexMethod} ')'];
spec_stru.columnnames = ODcohex_dna_colnames;
spec_stru.scannum = 1;
spec_stru.data = ODcohex_dna;
specdata_savefile(spec_stru, [savename '.dat']);

figure('OuterPosition', get(0, 'ScreenSize'), 'PaperPosition', ...
       [0.25,1,8,9]); clf; 

% Cohex UV spectrum
subplot(2,2,1); hold all;
for i=1:length(samnames)
   eval(['data=cohexdata.' samnames{i} '.data;']);
   ha(i)=xyplot(data);
   if isfield(cohexdata.(samnames{i}), 'fit')
      eval(['data=cohexdata.' samnames{i} '.fit;']);
      plot(data(:,1), data(:,2), '.--k', 'color', get(ha(i), 'color'));
   end
%   showcoord(eval([samnames{i} '.ymax']));
end
legend(ha,samnotes, 'fontsize', 8);
legend boxoff
uvspec_label;
title('Cohex Absorption & Fits')
xlim([350,720]); ylim auto;

% DNA UV spectrum
subplot(2,2,2); hold all
for i=1:length(samnames)
   eval(['data=dnadata.' samnames{i} '.data;']);
   ha(i)=xyplot(data);
end
legend(ha,samnotes, 'fontsize', 8);
legend boxoff
uvspec_label; title('DNA Absorption')
xlim([220,320]); ylim auto;

% 3) concentrations of Cohex and DNA in mM
subplot(2,2,3); hold all
plot(ODcohex_dna(:,1), ODcohex_dna(:,2), symbolorder{1});
plot(ODcohex_dna(:,1), ODcohex_dna(:,3), symbolorder{2});
plot(ODcohex_dna(:,1), ODcohex_dna(:,4), symbolorder{3});
plot(ODcohex_dna(:,1), ODcohex_dna(:,5), symbolorder{4});
axis tight; zoomout(0.1); 
title(['Concentrations (Co^{3+}:' sCohexMethod{iCohexMethod} ')']);
xlabel(xname); ylabel('[Cohex], [Phosphate] (mM)');
legend({'[Cohex]', '[Cohex]+baseline', '[DNA]', '[DNA]+baseline'}, ...
       'fontsize', 10, 'Location', 'NorthWest');
legend boxoff

% 4) charge ratio of Cohex to DNA
subplot(2,2,4); hold all
plot(ODcohex_dna(:,1), ODcohex_dna(:,6), symbolorder{1});
plot(ODcohex_dna(:,1), ODcohex_dna(:,7), symbolorder{2});
plot(ODcohex_dna(:,1), ODcohex_dna(:,8), symbolorder{3});
plot(ODcohex_dna(:,1), ODcohex_dna(:,9), symbolorder{4});
set(plot([xvalues(1), xvalues(end)], [1,1]), 'LineStyle', '--', 'Color', 'k');
axis tight
zoomout(0.1);
xlabel(xname);
ylabel('Cobalt/DNA Charge Ratio');
title(savename, 'Interpreter', 'none');
legend({'[Cohex]/[DNA]', 'baseline/baseline', 'DNA+baseline', ...
        'Cohex+baseline'}, 'FontSize', 10, 'Location', 'SouthEast');
legend boxoff

saveps(gcf, [savename '.ps']);
