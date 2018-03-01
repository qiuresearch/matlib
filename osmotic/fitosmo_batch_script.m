
% initialize some variables
clear osmocoef_fit
fitres = {}; osmocoef_fit(:,[1,2]) = osmocoef_init(:,[1,2]);
if ~exist('idata2fit', 'var') || isempty(idata2fit)
   idata2fit=1:length(datafiles);
end

for i=idata2fit
   [pathstr, fileprefix] = fileparts([datadir, datainfo{i,7}]);
   
   specdata = specdata_readfile([datadir, datainfo{i,7}]);
   osmodata =  specdata.data;
   
   if (flag_flipxy == 1)
       osmodata(:,[1,2]) = osmodata(:,[2,1]);
   end

   % apply dmin, dmax, doffset
   imin = locate(osmodata(:,1), datainfo{i,3});
   imax = locate(osmodata(:,1), datainfo{i,4});
   osmodata = osmodata(min([imin,imax]):max([imin,imax]),:);
   osmodata(:,1) = osmodata(:,1)+datainfo{i,5};
   
   % set up fitting 
   fitopts.fitfun_name = fitfun_name;
   fitopts.LargeScale = 'off';
   fitopts.Algorithm = {'levenberg-marquardt', 1e-11}; % no upper
                                                       % or lower bounds
   fitopts.Algorithm = 'trust-region-reflective';
   fitopts.Algorithm = fitfun_algorithm;
   %fitopts.LevenbergMarquardt = 'off';
   fitopts.upper = osmocoef_upper(i,3:num_pars+2);
   fitopts.lower = osmocoef_lower(i,3:num_pars+2);
   fitopts.MaxIter = 100;
   
   % if an equilibration spacing is given, only use two pars
   if (osmocoef_init(i,2) ~= 0)
      par_init = osmocoef_init(i, 3:4);
   else
      par_init = osmocoef_init(i, 3:num_pars+2);
   end

   [osmocoef, fitres_tmp] = osmodata_fit(osmodata, par_init, fitopts, ...
                                         'DNA_Equilibrium_Spacing', ...
                                         osmocoef_init(i,2));
   fitres = {fitres{:} fitres_tmp};
   fitres{end}.title = datainfo{i,6};
   num_osmocoefs = length(fitres{end}.osmocoef);
   osmocoef_fit(i,3:2+num_osmocoefs) = fitres{end}.osmocoef;
   osmocoef_fit(i,3+num_osmocoefs:2+2*num_osmocoefs) = fitres{end}.osmocoef_error;
end

% save the osmotic coefficient data
specdata.scannum = 1;
specdata.title = ['Osmotic coefficients for ' series_name ' series'];
osmocoef_names = {'mag_1', 'decaylen_1', 'mag_2', 'decaylen_2', ...
                  'mag_3', 'decaylen_3'};
dosmocoef_names = strcat(repmat({'d_'},1,length(osmocoef_names)), osmocoef_names);

num_osmocoefs = (length(osmocoef_fit(1,:))-2)/2;
specdata.columnnames = {x_label, 'equil_spacing', osmocoef_names{1: ...
                    num_osmocoefs}, dosmocoef_names{1:num_osmocoefs}};
specdata.data = osmocoef_fit;

if (flag_saveall == 1)
   specdata_savefile(specdata, [series_name '_osmocoef.dat']);
   specdata_savefile(specdata, [series_name num2str(num_pars, '_osmocoef_par%i.dat')]);
end

% plot the fitting results
if (flag_plot == 1);
    [hfig_all, hfig_fit] = osmodata_fitplot(fitres);
    if (flag_saveall == 1)
        saveps(hfig_all, [series_name '_osmocoef.eps']);
        saveps(hfig_all, [series_name num2str(num_pars, ...
                                              '_osmocoef_par%i.eps')]);
        
        saveps(hfig_fit, [series_name '_osmofit.eps']);
        saveps(hfig_fit, [series_name num2str(num_pars, ...
                                              '_osmofit_par%i.eps')]);
    end
end
