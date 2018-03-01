function sq = fitfun_msa(scale, z_m, I, sigma, n, q)
%
%  **** not supposed to be called by user ***
%
% the fitting function used by sqfit_msafit.m
% 
%

global msa_fitfun

msa_fitfun.scale = scale;
msa_fitfun.z_m = z_m;
msa_fitfun.I = I;
msa_fitfun.sigma = sigma;
msa_fitfun.n = n; 

msa_fitfun = msa_getpar(msa_fitfun);
sq = msa_calcsq(msa_fitfun); % use default Q values to compute wider range

sq = msa_fitfun.scale*(spline(sq(:,1), sq(:,2), q)-1) + 1.0;
