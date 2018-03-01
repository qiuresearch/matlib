function [osmocoef, fitres] = osmodata_fit(osmodata, par, fitopts, varargin)
% --- Usage:
%        fitres = fitosmodata(osmodata, par, fitopts)
%
% --- Purpose:
%        fit with osmotic stress data with one or two exponentials.
%        The osmocoef will give the the pressure/distance curve in
%        (dyne/cm^2) verus Angstrom.
%
% --- Parameter(s):
%        par   - [mag_repulsion, decay_repulsion, mag_attraction, decay_att]
%        fitopts - fitopts.upper, fitopts.lower are useful
%        varargin - fitfun_name
%
% --- Return(s): 
%
% --- Example(s):
%
% $Id: osmodata_fit.m,v 1.12 2016/10/26 15:21:57 xqiu Exp $
%

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end
global DNA_Equilibrium_Spacing

% 1) set up default fitting options
fitfun_name = 'osmodata';
if ~exist('par', 'var') || isempty(par)
    par = [0, 2.4, 0, 4.8];

    [pmax, imax] = max(osmodata(:,2));
    par(1) = 10^pmax/exp(-osmodata(imax,1)/par(2));
    xmax = max(osmodata(:,1));
    par(3) = -par(1)*exp(-xmax/par(2))/exp(-xmax/par(4));
end
if ~exist('fitopts', 'var') || isempty(fitopts)
   fitopts.Algorithm = 'trust-region-reflective'; % {'levenberg-marquardt', 1e-11};
   fitopts.upper = repmat(Inf, 1, length(par)); 
   fitopts.upper(2) = 3;
   fitopts.lower = repmat(-Inf, 1, length(par)); 
   fitopts.lower(2:2:end) = 2*(1:length(fitopts.lower(2:2:end)));
end
% handle other parameters
if isfield(fitopts, 'fitfun_name');
    fitfun_name = fitopts.fitfun_name;
end
parse_varargin(varargin);

% 2) fit
if strcmpi(fitfun_name, 'osmodata2')
    % arbitrary error bar!!!
    osmodata(:,4) = osmodata(:,2).^0.3/200;
    
    % do the fitting using "xyfit"
    fitres = xyfit(osmodata, fitfun_name, par, fitopts);
    fitres.fitopts = fitopts;
    fitres.DNA_Equilibrium_Spacing =  DNA_Equilibrium_Spacing;
    fitres.osmocoef = fitres.par_fit;
    osmocoef = fitres.osmocoef;
else % is "osmodata_xyfit" is used for fitting
    
    % 1) convert to linear scale, and scale data
    osmodata(:,2) = 10.^(osmodata(:,2));
    [dmin, imin] = min(osmodata(:,1)); % subtract the mininum d-spacing
    dmin = dmin-1;
    if (DNA_Equilibrium_Spacing ~= 0)
        DNA_Equilibrium_Spacing = DNA_Equilibrium_Spacing - dmin;
    end
    osmodata(:,1) = osmodata(:,1) - dmin;
    [scale, imax] = max(osmodata(:,2)); % miminum pressure as scale
    scale = 0.5/scale;

    % !!! arbitrary error bar
    osmodata(:,4) = abs(osmodata(:,2).*log10(osmodata(:,2)).*(osmodata(:,1)+dmin).^4/8e7);
    %log10(osmodata(:,2)/scale)*scale;
    %%1./abs(log10(osmodata(:,2)))/1000
    osmodata(:,[2,4]) = osmodata(:,[2,4])*scale;
    
    % check if the last expential is lambda/2
    if (mod(length(par), 2) == 0)
        par(1:2:end) = par(1:2:end)*scale./exp(dmin./par(2:2:end));
        if isfield(fitopts, 'upper')
            fitopts.upper(1:2:end) = fitopts.upper(1:2:end)*scale./exp(dmin./par(2:2:end));
        end
        if isfield(fitopts, 'lower')
            fitopts.lower(1:2:end) = fitopts.lower(1:2:end)*scale./exp(dmin./par(2:2:end));
        end
    else
        par(1:2:end) = par(1:2:end)*scale./[exp(dmin./par(2:2:end)),exp(dmin/par(2)/2)];
        if isfield(fitopts, 'upper')
            fitopts.upper(1:2:end) = fitopts.upper(1:2:end)*scale./ ...
                [exp(dmin./par(2:2:end)), exp(dmin/par(2)/2)];
        end
        if isfield(fitopts, 'lower')
            fitopts.lower(1:2:end) = fitopts.lower(1:2:end)*scale./ ...
                [exp(dmin./par(2:2:end)), exp(dmin/par(2)/2)];
        end
    end
    
    % re-adjust the last two parameters for vdw force
    if strcmpi(fitfun_name, 'osmodata_vdw')
        if isfield(fitopts, 'upper')
            fitopts.upper(end-1) = fitopts.upper(end-1)*exp(dmin/par(end));
            fitopts.lower(end-1) = fitopts.lower(end-1)*exp(dmin/par(end));
            fitopts.upper(end) = fitopts.upper(end)-dmin;
            fitopts.lower(end) = fitopts.lower(end)-dmin;
        end
        par(end-1) = par(end-1)*exp(dmin/par(end));
        par(end) = par(end) - dmin;
    end
    
    % 4) do the fitting using "xyfit"
    fitres = xyfit(osmodata, fitfun_name, par, fitopts);
    fitres.dmin = dmin;
    fitres.scale = scale;
    fitres.fitopts = fitopts;
    
    % note: .par_fit is not the same as .osmocoef
    if (DNA_Equilibrium_Spacing ~= 0)
        DNA_Equilibrium_Spacing = DNA_Equilibrium_Spacing + dmin;
    end
    fitres.DNA_Equilibrium_Spacing =  DNA_Equilibrium_Spacing;
    fitres.osmocoef = fitres.par_fit;
    fitres.osmocoef_error = reshape(fitres.par_error, size(fitres.osmocoef));
    % correct the force coefficients because of the different d-spacings
    % used in fitting
    if (mod(length(par), 2) == 0)
        dspacing_factor = exp(dmin./fitres.osmocoef(2:2:end));
    else
        dspacing_factor = [exp(dmin./fitres.osmocoef(2:2:end)), ...
                           exp(dmin/fitres.osmocoef(2)/2)];
    end
    fitres.osmocoef(1:2:end) = fitres.osmocoef(1:2:end).*dspacing_factor/fitres.scale;
    fitres.osmocoef_error(1:2:end) = fitres.osmocoef_error(1:2:end).*dspacing_factor/fitres.scale;

    % if van der Waals force is the last term (t^2.5 dependence)
    if strcmpi(fitfun_name, 'osmodata_vdw')
        fitres.osmocoef(end-1) = fitres.osmocoef(end-1)/exp(dmin/fitres.osmocoef(end));
        fitres.osmocoef(end) = fitres.osmocoef(end)+dmin;
    end
    osmocoef = fitres.osmocoef;
end
