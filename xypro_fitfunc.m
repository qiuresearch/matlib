function xydata = xypro_fitfunc(xydata, varargin)
% --- Usage:
%        xydata = xypro_dataprep(xydata, varargin)
% --- Purpose:
%        preprocess data for compatibility/consistency issues,
%        0) re-read all the data 
%        1) double check the q_min, and q_max
%        2) interpolate all the form factor in compliance with sqfit.iq_raw
%
% --- Parameter(s):
%
% --- Return(s):
%        results -
%
% --- Example(s):
%
% $Id: xypro_fitfunc.m,v 1.4 2015/02/23 03:31:20 xqiu Exp $
%
verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end
calc_only = 0;
init_fitpar = 0;
parse_varargin(varargin);

num_sets = length(xydata);
for i = 1:num_sets
    % initialize fitpar
    if (init_fitpar(1) ~= 0);
        if (length(xydata(i).funclist) > length(xydata(i).fitpar))
            xydata(i).fitpar = [xydata(i).fitpar, ...
                                repmat(struct('ifunc', [], 'funclist', [], 'xmin', ...
                                 [], 'xmax', [], 'ialgorithm', [], ...
                                 'algorithmlist', [], 'lm_lambda', ...
                                 [], 'maxiter', [], 'maxdiff', [], ...
                                 'name', [], 'hfunc', [], 'value', ...
                                 [], 'num_pars', [], 'delta', [], 'fit', [], 'limit', ...
                                 [], 'upper', [], 'lower', [], 'chi2', ...
                                 [], 'oldvalue', [], 'calcdata', ...
                                 [], 'fitdata', [], 'TolFun', 1e-8), 1, ...
                          length(xydata(i).funclist)-length(xydata(i).fitpar))];
        end
        
        for k=init_fitpar
            xydata(i).fitpar(k).ifunc = k;
            xydata(i).fitpar(k).funclist = xydata(i).funclist;
            xydata(i).fitpar(k).hfunc = xyfit_getfunc(xydata(i).funclist{xydata(i).fitpar(k).ifunc});
            [xydata(i).fitpar(k).name, xydata(i).fitpar(k).value] = feval(xydata(i).fitpar(k).hfunc);
            num_pars = length(xydata(i).fitpar(k).value);
            xydata(i).fitpar(k).num_pars = num_pars;
            xydata(i).fitpar(k).delta = zeros(1,num_pars);
            xydata(i).fitpar(k).fit = ones(1, num_pars);
            xydata(i).fitpar(k).limit = zeros(1, num_pars);
            xydata(i).fitpar(k).upper = repmat(Inf, 1, num_pars);
            xydata(i).fitpar(k).lower = repmat(-Inf, 1, num_pars);
            
            xydata(i).fitpar(k).ialgorithm = 1;
            xydata(i).fitpar(k).algorithmlist = xydata(i).algorithmlist;
            % lm_lambda is for LevenbergMarquardt method only  
            % 1e-10: similar to Gauss-Newton method (seem to converge better); ->inf: close to Steepest Descent method
            xydata(i).fitpar(k).lm_lambda = 1e-2;
            xydata(i).fitpar(k).maxiter = 23;
            xydata(i).fitpar(k).xmin = -Inf;
            xydata(i).fitpar(k).xmax = Inf;
            
            xydata(i).fitpar(k).maxdiff = 0.01; % (not used for now)
        end
        continue
    end % if (init_fitpar(1) ~= 0);
    
    j = xydata(i).ifunc;

    % calclate the model results
    hfunc = xydata(i).fitpar(j).hfunc;
    xydata(i).calcdata = xydata(i).data;
    xydata(i).calcdata(:,2) = feval(hfunc, xydata(i).fitpar(j).value, xydata(i).data(:,1));
    xydata(i).fitpar(j).calcdata = xydata(i).calcdata;
    
    if (calc_only == 1); continue; end
    
    % fit the data (how to deal with not to fit parameters)
    fitpar = xydata(i).fitpar(j);
    ifixed = find(fitpar.fit == 0);
    if ~isempty(ifixed)
        fitpar.limit(ifixed) = 1;
        fitpar.upper(ifixed) = fitpar.value(ifixed)+1e-6;
        fitpar.lower(ifixed) = fitpar.value(ifixed)-1e-6;
    end
    fitpar.Algorithm = fitpar.algorithmlist{fitpar.ialgorithm};
    if strcmpi(fitpar.Algorithm, 'levenberg-marquardt')
        fitpar.Algorithm={'levenberg-marquardt', fitpar.lm_lambda};
    end
    
    fitres = xyfit(xydata(i).data, xydata(i).funclist{j}, ...
                   fitpar.value(1:fitpar.num_pars), fitpar);
    xydata(i).fitdata = [fitres.x, fitres.y_fit];
    xydata(i).fitpar(j).fitdata = xydata(i).fitdata;
    xydata(i).fitpar(j).oldvalue = xydata(i).fitpar(j).value;
    xydata(i).fitpar(j).value(1:fitpar.num_pars) = fitres.par_fit;
    xydata(i).fitpar(j).delta(1:fitpar.num_pars) = fitres.par_error;
    xydata(i).fitpar(j).chi2 = fitres.chi2;
end
