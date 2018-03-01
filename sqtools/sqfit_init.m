function sqfit = sqfit_init()

sqfit.num = 1;
sqfit.select = 1; % whether this entity is selected for action
sqfit.legend = '';

sqfit.x = 1;   % presumably the X axis for future plot
sqfit.molweight=1;
sqfit.fname = '';
sqfit.fname_ff_sol = '';
sqfit.fname_ff_vac = '';
sqfit.fname_ff_exp = '';
sqfit.fname_ff_inp = '';

sqfit.iq_raw = [0,1,0,1];
sqfit.q_min=0.01;
sqfit.q_max=0.50;
sqfit.i_min = 1;
sqfit.i_max = 1;
sqfit.smooth_width = 0; % whether I(q) needs to be smoothened?
sqfit.q_min_smooth = 0.1;
sqfit.q_max_smooth = 0.23;
sqfit.smooth_degree = 1;
sqfit.iq = [0,1,0,1]; % maybe after smoothening and rescaling

% get fit I(Q)
sqfit.offset_iq = 0.0; % the offset 
sqfit.scale_iq = 1.0;

sqfit.offset_iq_delta = 0;
sqfit.offset_iq_fit = 0;
sqfit.offset_iq_limit = 0;
sqfit.offset_iq_ll = -1.0;
sqfit.offset_iq_ul = 1.0;

sqfit.scale_iq_delta = 1;
sqfit.scale_iq_fit = 1;
sqfit.scale_iq_limit = 0;
sqfit.scale_iq_ll = 0.0;
sqfit.scale_iq_ul = 10.0;

% the form factor to normalize sqfit.iq
sqfit.ff_sol = [0,1];
sqfit.ff_vac = [0,1];
sqfit.ff_exp = [0,1];
sqfit.ff_inp = [0,1];
sqfit.ff_cyl = [0,1,1];  % form factor of a cylinder
sqfit.calc_ff_cyl = 1;   % indicate whether to calculate it again
sqfit.radius_cyl = 10.0; % in Angstrom
sqfit.height_cyl = 85.0; % in Angstrom
sqfit.diameter_equiv = 45.0;
sqfit.use_diameter_equiv = 1; % whether to use equivalent diameter
                              % for MSA calculation
sqfit.radius_cyl_delta = 0;
sqfit.radius_cyl_fit = 0;
sqfit.radius_cyl_limit = 1;
sqfit.radius_cyl_ll = 5;
sqfit.radius_cyl_ul = 20;

sqfit.height_cyl_delta = 0;
sqfit.height_cyl_fit = 0;
sqfit.height_cyl_limit = 1;
sqfit.height_cyl_ll = 50;
sqfit.height_cyl_ul = 120;

sqfit.qrange_rescale = [0.15,0.25];
sqfit.auto_rescale = 1; % and only if the sqfit.scale_iq = 1.0 to
                        % avoid multiple scaling. Data to be scaled:
                        % iq, all ffs;
sqfit.hqratio=0.40;
sqfit.hqmethod = 1; % 1: high Q, 2: low Q, 3: med Q

sqfit.ff_use = 1; % which ff to use

% the S(Q) exprimental
sqfit.sq_sol = [0,1];
sqfit.sq_vac = [0,1];
sqfit.sq_exp = [0,1];
sqfit.sq_inp = [0,1];
sqfit.sq_cyl = [0,1];
sqfit.getall_sq = 0; % whether to compute all S(Q)s
sqfit.sq = [0,1]; % THE experimental S(Q) to use!

% the model 
sqfit.msa = msa_init();
sqfit.ur_cal = [0,1];
sqfit.cr_cal = [0,1];
sqfit.gr_cal = [0,1];
sqfit.sq_cal = [0,1];
sqfit.iq_cal = [0,1];
sqfit.sq_fit = [0,1]; 
sqfit.sq_dif = [0,1];
sqfit.iq_fit = [0,1]; % the fitted I(Q)
sqfit.iq_dif = [0,1];
sqfit.chi2 = 0.0;
sqfit.varcovar = 0;

% fitting options
sqfit.fitmethod = 1; %
sqfit.fitalgorithmname = {'LevenbergMarquardt', 'Gauss-Newton', 'Trust-Region'};
sqfit.fitalgorithm = 1;
% fitlm_lambda is for LevenbergMarquardt method only  
% 1e-10: similar to Gauss-Newton method (seem to converge better); ->inf: close to Steepest Descent method
sqfit.fitlm_lambda = 1e-10;
sqfit.fitmaxiter = 23;
sqfit.fitmaxdiff = 0.01; % (not used for now)
