

% 1) initialize the data
sqfit = sqfit_init();
sqfit.qmin = 0.01175;
sqfit.qmax = 0.20;
sqfit.hqratio = 0.40;

sqfit.iq = load('-ascii', 'dnalo174.iq');

% 2) initialize the form factor
sqfit.ff_sol = load('-ascii', '25mer00.int');
sqfit.ff_vac = sqfit.ff_sol(:,[1,3]);
sqfit.ff_exp = 0;

% 3) get the expeirmental S(Q)

sqfit = sqfit_normiq(sqfit, 0); % mode: 0 --> use solution ff

% 4) fit

sqfit = sqfit_msafit(sqfit);

