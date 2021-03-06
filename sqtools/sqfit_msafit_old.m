function sqfit = sqfit_msafit(sqfit, fitopts, varargin)
%        sqfit = sqfit_msafit(sqfit, fitopts, varargin)
% --- Purpose:
%    calculate exprimental S(Q) -> sqfit.sq_cal
%    fit the experimental S(Q) to obtain parameters
%
%    batch calculation of sqfit.sq_cal with array of z_m, sigma, I
%    are also supported
%
% --- Parameter(s):
%    sqfit   -- an array of structure (see sqfit_init.m for detail)
%    fitopts -- fitting options. The fitted parameter is order as
%               the following: scale, z_m, I, sigma, n
%    varargin  -- see parase_varargin.m for input
%                 formats. Supported inputs are: 'nofit' [0,1], 'z_m',
%                 [], 'sigma', [], 'I', [].
%
% --- Return(s):
%        sqfit - the same as input with updated results
%
% --- Calling Method(s):
%
% --- Example(s):
%
% $Id: sqfit_msafit_old.m,v 1.1 2011-09-08 15:22:55 xqiu Exp $
%

% 1) handle the input parameters
if (nargin < 1) 
  error('No parameter passed!')
  return
end

user_fitopts = 0; % if set to 1, we do nothing about the fitting
                  % options. if set to 0, the program will use some
                  % default settings, and take parameter limits from
                  % the MSA structure

if (nargin >= 2) && ~isempty(fitopts)
   user_fitopts = 1;
end

% default options
calc_only = 0;   % if set to 0, only calculation will be performed
parse_varargin(varargin);
if exist('z_m', 'var');   z_m_passed = 1; else z_m_passed =0; end
if exist('sigma', 'var'); sigma_passed =1; else sigma_passed=0; end
if exist('I', 'var');     I_passed=1; else I_passed=0; end

% 2) do the calculation and fit

num_sets = length(sqfit);
for iset = 1:num_sets
   if (length(sqfit(iset).iq) < 3)
      sqfit(iset) = sqfit_getexpiqsq(sqfit(iset));
   end
   
   q = sqfit(iset).iq(:,1);
   sqfit(iset).msa.I = abs(sqfit(iset).msa.I);
   sqfit(iset).msa = msa_getpar(sqfit(iset).msa); % update some values

  % -- the only supported batched calculation. In case of
  % calculation only, the sqfit.sq_calc will be of multiple column
  % form. ---
  if (z_m_passed == 0); z_m = sqfit(iset).msa.z_m; end
  if (sigma_passed == 0); sigma = sqfit(iset).msa.sigma; end
  if (I_passed == 0); I = sqfit(iset).msa.I; end
  
  num_cals = length(z_m) * length(sigma) * length(I);
  sqfit(iset).sq_cal = repmat(q, 1, num_cals+1);
  sqfit(iset).gr_cal = [];
  sqfit(iset).ur_cal = [];
  sqfit(iset).cr_cal = [];
  
  % -- whether to fit???
  if (calc_only == 0)  % do fit, initialize the fitting structure
     
     % WARNING
     if (sqfit(iset).scale_iq_fit == 1) && (sqfit(iset).auto_rescale ==1)
        disp('WARNING:: I(Q) scale is fit while auto rescale is ON! ')
     end
     
     sqfit(iset).sq_fit = sqfit(iset).sq_cal;
     sqfit(iset).iq_fit = sqfit(iset).sq_fit;
     
     if (user_fitopts == 0) % construct fitopts if not passed!
        switch sqfit(iset).fitmethod
           case 1   % lsqcurvefit
              fitopts = optimset('Display', 'iter', 'MaxIter', ...
                                 sqfit(iset).fitmaxiter, 'LargeScale', ...
                                 'off', 'LevenbergMarquardt', 'on', ...
                                 'LineSearchType', 'quadcubic', ...
                                 'DiffMaxChange', sqfit(iset).fitmaxdiff);
              switch sqfit(iset).fitalgorithm 
                 case 1          %  'Levenberg-Marquardt'
                    fitopts.LargeScale = 'off';
                    fitopts.LevenbergMarquardt = 'on';
                 case 2          % 'Guass-Newton'
                    fitopts.LargeScale = 'off';
                    fitopts.LevenbergMarquardt = 'off';
                 case 3          % 'Trust-Region'
                    fitopts.LargeScale = 'on';
                    fitopts.LevenbergMarquardt = 'off';
                 otherwise
              end
           case 2   % fit from the curve fit toolbox
              global msa_fitfun
              msa_fitfun = sqfit(iset).msa;
              fitopts = fitoptions('Method', 'NonLinearLeastSquares', ...
                                   'Algorithm', sqfit(iset).fitalgorithmname{sqfit(iset).fitalgorithm},  ...
                                   'MaxIter', sqfit(iset).fitmaxiter, ...
                                   'Display', 'iter', 'Robust', ...
                                   'off', 'DiffMaxChange', ...
                                   sqfit(iset).fitmaxdiff);
              msafittype = fittype(['fitfun_msa(scale, z_m, ionic, ' ...
                                  'sigma, n, x)'], 'coeff', {'scale', ...
                                  'z_m', 'ionic', 'sigma', 'n'}, fitopts);
           otherwise
              error('ERROR:: the fit method has to be 1 or 2!')
        end
     end
  end
  
  % start the calculation and/or fitting
  i_col = 1;
  for iz_m = 1:length(z_m)
     for isigma = 1:length(sigma)
        for iI = 1:length(I)
           % calculate the S(Q), G(r) based on current parameters
           i_col = i_col + 1;
           sqfit(iset).msa.z_m = z_m(iz_m);
           sqfit(iset).msa.sigma = sigma(isigma);
           sqfit(iset).msa.I = I(iI);

           sqfit(iset).msa = msa_getpar(sqfit(iset).msa);
           % ALWAYS!!! use default Q values to compute S(Q), then spline
           [sq, gr, ur, cr] = msa_calcsq(sqfit(iset).msa); 
           sqfit(iset).sq_cal(:,i_col) = sqfit(iset).msa.scale* ...
               (spline(sq(:,1), sq(:,2), q)-1) +1;
           % [sq(:,1), sqfit(iset).msa.scale*(sq(:,2)-1.0)+1];
           sqfit(iset).gr_cal(:,[1,i_col]) = gr;
           sqfit(iset).ur_cal(:,[1,i_col]) = ur;
           sqfit(iset).cr_cal(:,[1,i_col]) = cr;
           
           if (calc_only == 0) % do the fit
              if (user_fitopts == 0)  % fitopts is not passed!
                                      % set start values
                 [fitpar, sParInfo] = lsq_getpar(sqfit(iset));
                 if isempty(fitpar)
                    error(['ERROR:: no parameter is selected to fit!' '!!'])
                    return
                 end
                 fitopts = struct_assign(sParInfo, fitopts, 'append');
                 output_format = strcat(fitopts.name, '=%0.4f,  ');
                 disp(['Starting values: ' num2str(fitopts.startpoint, ...
                                                   [output_format{:}])])
              end
              % fitting with a selected method
              switch sqfit(iset).fitmethod
                 case 1
                    % [RESNORM,RESIDUAL,EXITFLAG,OUTPUT] =
                    % LSQCURVEFIT(FUN,X0,XDATA,YDATA,LB,UB)
                    disp(['Method: lsqcurvefit, Options: LargeScale(' ...
                          fitopts.LargeScale, '), LevenbergMarquardt(', ...
                          fitopts.LevenbergMarquardt ')'])
                    if (sqfit(iset).fitalgorithm == 3)
                       [fitpar, resnorm, residue, exitflag, output, ...
                        lambda, jacobian] = lsqcurvefit(@curvefitfun_msa, ...
                                                        fitopts.startpoint, ...
                                                        sqfit(iset), ...
                                                        zeros(length(q),1), ...
                                                        fitopts.lower, ...
                                                        fitopts.upper, ...
                                                        fitopts);
                    else
                       [fitpar, resnorm, residue, exitflag, output, ...
                        lambda, jacobian] = lsqcurvefit(@curvefitfun_msa, ...
                                                        fitopts.startpoint, ...
                                                        sqfit(iset), ...
                                                        zeros(length(q),1), ...
                                                        [], [], fitopts);
                    end                       
                    % refined pars: [scale_factor, eff_charge, num_density]
                    sqfit(iset) = lsq_setpar(sqfit(iset), fitpar);
                 case 2
                    % fit, and save results (not working now)
                    disp(['Method: fit, Options: LargeScale(' ...
                          fitopts.LargeScale, '), LevenbergMarquardt(', ...
                          fitopts.LevenbergMarquardt ')'])
                    fitopts
                    msa_fitfun = sqfit(iset).msa;
                    msafitmod = fit(q, sqfit(iset).sq(:,2), msafittype, ...
                                    fitopts)
                    fitpar = coeffvalues(msafitmod);
                    sqfit(iset).msa.scale = fitpar(1);
                    sqfit(iset).msa.z_m = fitpar(2);
                    sqfit(iset).msa.I = fitpar(3);
                    sqfit(iset).msa.sigma = fitpar(4);
                    sqfit(iset).msa.n = fitpar(5);
                 otherwise
                    warning(['Only two fitting methods are available,', ...
                             'your choice is not available!']);
              end
              % caculate again to get sq_fit and iq_fit and the difference
              sqfit(iset) = sqfit_getexpiqsq(sqfit(iset), 'iq_only', 0);
              sqfit_dummy = sqfit_calmsasqiq(sqfit(iset));
              sqfit(iset).msa = sqfit_dummy.msa;
              sqfit(iset).sq_fit = sqfit_dummy.sq_cal;
              sqfit(iset).iq_fit = sqfit_dummy.iq_cal;
              sqfit(iset).sq_dif = sqfit(iset).sq;
              sqfit(iset).sq_dif(:,2) = sqfit(iset).sq(:,2) - ...
                  sqfit(iset).sq_fit(:,2);
              sqfit(iset).iq_dif = sqfit(iset).iq_fit;
              sqfit(iset).iq_dif(:,2) = sqfit(iset).iq(:,2) - ...
                  sqfit(iset).iq_fit(:,2);
              % the CHI**2 and uncertainties of fitted parameters
              WEIGHT = (1./sqfit(iset).iq(:,4)).^2;
              sqfit(iset).chi2 = total(sqfit(iset).iq_dif(:,2).^2.*WEIGHT)/ ...
                  (length(sqfit(iset).iq_dif(:,1))-length(fitpar));
              disp(['CHI**2 is ' num2str(sqfit(iset).chi2)])
              if exist('jacobian', 'var')
                 % calculate the inverse of variant-covariant matrix
                 for ip1 =1:length(fitpar)
                    for ip2=ip1:length(fitpar)
                       varcovar(ip1,ip2) = total((jacobian(:,ip1).* ...
                                                  jacobian(:,ip2).* WEIGHT));
                       varcovar(ip2,ip1) = varcovar(ip1,ip2);
                    end
                 end
                 % inverse it and multiply the CHI**2 to error bar
                 varcovar = inv(varcovar);
                 dfitpar = [];
                 for ip = 1:length(fitpar)
                    dfitpar(ip) = sqrt(varcovar(ip,ip)*sqfit(iset).chi2);
                 end
                 % set it to the structure
                 disp(['Error bars are: ' num2str(dfitpar)])
                 sqfit(iset) = lsq_setpar(sqfit(iset), fitpar, dfitpar);
                 sqfit(iset).varcovar = varcovar;
              end
           end %        if (calc_only == 0)
        end %        for iI = 1:length(I)
     end %     for isigma = 1:length(sigma)
  end %  for iz_m = 1:length(z_m)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Fitting function
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [iq_diff, sqfit] = curvefitfun_msa(par, sqfit)

% 1) get sqfit

if ~exist('sqfit')
   error('ERROR:: sqfit structure must be passed!')
   return
end

% 2) calculate
sqfit = lsq_setpar(sqfit, par);
% don't need to calculate the cylinder form factor if not necessary
if (sqfit.radius_cyl_fit == 1) || (sqfit.height_cyl_fit == 1) 
   sqfit.calc_ff_cyl = 1;
else 
   sqfit.calc_ff_cyl = 0;
end
if (sqfit.offset_iq_fit == 1) || (sqfit.scale_iq_fit == 1) 
   sqfit = sqfit_getexpiqsq(sqfit, 'iq_only');
end
sqfit = sqfit_calmsasqiq(sqfit);
iq_diff = sqfit.iq_cal(:,2) - sqfit.iq(:,2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [par, fitopts] = lsq_getpar(sqfit)

% This routine returns the par array to lsqcurvefit, with the
% non-fit parameters removed!

fitopts.name = {'offset_iq', 'scale_iq', 'radius_cyl', 'height_cyl', ...
                'msa-scale', 'msa-z_m', 'msa-I', 'msa-sigma', 'msa-n', ...
                'msa-z_m2', 'msa-I2'};
fitopts.startpoint = [sqfit.offset_iq, ...
                    sqfit.scale_iq, ...
                    sqfit.radius_cyl, ...
                    sqfit.height_cyl, ...
                    sqfit.msa.scale, ...
                    sqfit.msa.z_m, ...
                    sqfit.msa.I, ...
                    sqfit.msa.sigma, ...
                    sqfit.msa.n, ...
                    sqfit.msa.z_m2, ...
                    sqfit.msa.I2]; 

% setting lower and upper boundary
fitopts.lower = [sqfit.offset_iq_ll, ...
                 sqfit.scale_iq_ll, ...
                 sqfit.radius_cyl_ll, ...
                 sqfit.height_cyl_ll, ...
                 sqfit.msa.scale_ll, ...
                 sqfit.msa.z_m_ll, ...
                 sqfit.msa.I_ll, ...
                 sqfit.msa.sigma_ll, ...
                 sqfit.msa.n_ll, ...
                 sqfit.msa.z_m2_ll, ...
                 sqfit.msa.I2_ll];

fitopts.upper = [sqfit.offset_iq_ul, ...
                 sqfit.scale_iq_ul, ...
                 sqfit.radius_cyl_ul, ...
                 sqfit.height_cyl_ul, ...
                 sqfit.msa.scale_ul, ...
                 sqfit.msa.z_m_ul, ...
                 sqfit.msa.I_ul, ...
                 sqfit.msa.sigma_ul, ...
                 sqfit.msa.n_ul, ...
                 sqfit.msa.z_m2_ul, ...
                 sqfit.msa.I2_ul];

% reset to INF if limit not set
inolimit = find([1, 1, sqfit.radius_cyl_limit, ...
                 sqfit.height_cyl_limit, 1, ...
                 sqfit.msa.z_m_limit, ...
                 sqfit.msa.I_limit, ...
                 sqfit.msa.sigma_limit, ...
                 sqfit.msa.n_limit, ...
                 sqfit.msa.z_m2_limit, ...
                 sqfit.msa.I2_limit] == 0);
if ~isempty(inolimit)
   fitopts.lower(inolimit) = -Inf;
   fitopts.upper(inolimit) = Inf;
end

ifit =  find([sqfit.offset_iq_fit, ...
              sqfit.scale_iq_fit, ...
              sqfit.radius_cyl_fit, ...
              sqfit.height_cyl_fit, ...
              sqfit.msa.scale_fit, ...
              sqfit.msa.z_m_fit, ...
              sqfit.msa.I_fit, ...
              sqfit.msa.sigma_fit, ...
              sqfit.msa.n_fit, ...
              sqfit.msa.z_m2_fit, ...
              sqfit.msa.I2_fit] == 1);

% ****** REMOVE parameters that are not fit!!! *******
if ~isempty(ifit)
   fitopts.name = fitopts.name(ifit);
   fitopts.startpoint = fitopts.startpoint(ifit);
   fitopts.lower = fitopts.lower(ifit);
   fitopts.upper = fitopts.upper(ifit);
   par = fitopts.startpoint;
else
   fitopts = [];
   par = [];
end


%
function sqfit = lsq_setpar(sqfit, par, dpar)

% this routine sets the parameter values of the sqfit structure
% depending on which parameters are selected to fit.

old_par   =[sqfit.offset_iq, ...
            sqfit.scale_iq, ...
            sqfit.radius_cyl, ...
            sqfit.height_cyl, ...
            sqfit.msa.scale, ...
            sqfit.msa.z_m, ...
            sqfit.msa.I, ...
            sqfit.msa.sigma, ...
            sqfit.msa.n, ...
            sqfit.msa.z_m2, ...
            sqfit.msa.I2]; 

old_dpar  =[sqfit.offset_iq_delta, ...
            sqfit.scale_iq_delta, ...
            sqfit.radius_cyl_delta, ...
            sqfit.height_cyl_delta, ...
            sqfit.msa.scale_delta, ...
            sqfit.msa.z_m_delta, ...
            sqfit.msa.I_delta, ...
            sqfit.msa.sigma_delta, ...
            sqfit.msa.n_delta, ...
            sqfit.msa.z_m2_delta, ...
            sqfit.msa.I2_delta]; 

ifit =  find([sqfit.offset_iq_fit, ...
              sqfit.scale_iq_fit, ...
              sqfit.radius_cyl_fit, ...
              sqfit.height_cyl_fit, ...
              sqfit.msa.scale_fit, ...
              sqfit.msa.z_m_fit, ...
              sqfit.msa.I_fit, ...
              sqfit.msa.sigma_fit, ...
              sqfit.msa.n_fit, ...
              sqfit.msa.z_m2_fit, ...
              sqfit.msa.I2_fit] == 1);

if isempty(ifit) || (length(ifit) ~= length(par))
   error('ERROR:: no fit parameters or dimension does not match!')
   return
end

old_par(ifit) = par; % assign the new values here!!!
old_par = num2cell(old_par); % conversion to cell is necessary
[sqfit.offset_iq, ...
 sqfit.scale_iq, ...
 sqfit.radius_cyl, ...
 sqfit.height_cyl, ...
 sqfit.msa.scale, ...
 sqfit.msa.z_m, ...
 sqfit.msa.I, ...
 sqfit.msa.sigma, ...
 sqfit.msa.n, ...
 sqfit.msa.z_m2, ...
 sqfit.msa.I2] = deal(old_par{:});

if exist('dpar', 'var')
old_dpar(ifit) = dpar; % assign the new values here!!!
old_dpar = num2cell(old_dpar); % conversion to cell is necessary
[sqfit.offset_iq_delta, ...
 sqfit.scale_iq_delta, ...
 sqfit.radius_cyl_delta, ...
 sqfit.height_cyl_delta, ...
 sqfit.msa.scale_delta, ...
 sqfit.msa.z_m_delta, ...
 sqfit.msa.I_delta, ...
 sqfit.msa.sigma_delta, ...
 sqfit.msa.n_delta, ...
 sqfit.msa.z_m2_delta, ...
 sqfit.msa.I2_delta] = deal(old_dpar{:});
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% --- Change History:
%
% $Log: sqfit_msafit_old.m,v $
% Revision 1.1  2011-09-08 15:22:55  xqiu
% *** empty log message ***
%
% Revision 1.2  2011-03-01 03:56:53  xqiu
% *** empty log message ***
%
% Revision 1.1.1.1  2007-09-19 04:45:38  xqiu
% A new start of my matlab library with new directory structure.
%
% Revision 1.2  2006/08/09 02:20:29  xqiu
% regular update
%
% Revision 1.1  2005/11/03 00:34:39  xqiu
% *** empty log message ***
%
% Revision 1.12  2005/11/03 00:16:00  xqiu
% *** empty log message ***
%
% Revision 1.11  2005/08/27 03:41:04  xqiu
% *** empty log message ***
%
% Revision 1.9  2005/07/06 14:13:24  xqiu
% general overal improvements
%
% Revision 1.8  2005/06/22 21:31:21  xqiu
% *** empty log message ***
%
% Revision 1.7  2005/03/25 16:40:11  xqiu
% Daily progress being made, and checked back into CVS!
%
% Revision 1.6  2005/03/23 23:20:37  xqiu
% close to completion on 05/03/23!
%
% Revision 1.5  2005/03/23 05:46:54  xqiu
% In the process of improving xsqfit program!
%
% Revision 1.4  2004/10/27 20:08:02  xqiu
% xsqfit basically working, msa tested again!
%
% Revision 1.3  2004/10/25 23:29:47  xqiu
% end of the day
%
% Revision 1.2  2004/10/22 20:38:46  xqiu
% my xsqfit basically works now!
%
% Revision 1.1  2004/10/20 01:43:15  xqiu
% Some initilization or small modifications!
%
%
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
