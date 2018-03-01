function varargout = sqfit_saveresults(sqfit, prefix, varargin)
%        varargout = sqfit_saveresults(sqfit, prefix, varargin)
% --- Purpose:
%    save each sqfit structure into the .msa file, and summarize
%    the MSA model parameters into msa_results.dat
%
% --- Parameter(s):
%
% --- Return(s):
%        results -
%
% --- Calling Method(s):
%
% --- Example(s):
%
% $Id: sqfit_saveresults.m,v 1.3 2012/02/07 00:09:53 xqiu Exp $
%

if (nargin < 1)
   error('sqfit structure should be passed!')
   return
end
if ~exist('prefix', 'var')
   prefix = 'sqfit';
end

suffix = '.msa';
savehst=1;
savefitpar=0;
saveiq = 0;
parse_varargin(varargin);

% 2)

num_sets = length(sqfit);

% save the  all MSA results into one file in the same format as the
% hst so that it can be loaded into back later. 

if (savehst == 1)
   hstfile = [prefix '.hst'];
else
   hstfile = '.sqfit.hst';
end

if(savefitpar == 1)
   fitparfile = [prefix '_fitpar.dat'];
else
   fitparfile = '.sqfit_fitpar.dat';
end

hstunit = fopen(hstfile, 'w');
fitparunit = fopen(fitparfile, 'w');

header{1} = ['# SQFIT modeling parameters  written @ ', datestr(now) '\n'];
header{2} = ['# By program xsqfit\n'];
header{3} = '# note: the line may be too long, but do NOT cut it!\n';

for i=1:length(header)
   fprintf(hstunit, header{i});
   fprintf(fitparunit, header{i});
end

% use the first one as the general hst
fprintf(hstunit, 'molweight=%0i\n', sqfit(1).molweight);
fprintf(hstunit, 'smooth_width=%0i\n', sqfit(1).smooth_width);
fprintf(hstunit, 'smooth_degree=%0i\n', sqfit(1).smooth_degree);
fprintf(hstunit, 'q_min=%0.4f\n', sqfit(1).q_min);
fprintf(hstunit, 'q_max=%0.4f\n', sqfit(1).q_max);
fprintf(hstunit, 'hqratio=%0.4f\n', sqfit(1).hqratio);
fprintf(hstunit, 'hqmethod=%0i\n', sqfit(1).hqmethod);
fprintf(hstunit, 'ff_use=%0i\n', sqfit(1).ff_use);
fprintf(hstunit, 'ff_sol=%s\n', sqfit(1).fname_ff_sol);
fprintf(hstunit, 'ff_vac=%s\n', sqfit(1).fname_ff_vac);
fprintf(hstunit, 'ff_exp=%s\n', sqfit(1).fname_ff_exp);
fprintf(hstunit, 'ff_inp=%s\n', sqfit(1).fname_ff_inp);
fprintf(hstunit, 'radius_cyl=%0.4f\n', sqfit(1).radius_cyl);
fprintf(hstunit, 'height_cyl=%0.4f\n', sqfit(1).height_cyl);
fprintf(hstunit, 'msamethod=%0.4f\n', sqfit(1).msa.method);

fprintf(hstunit, '#S 0 SQFIT setup parameters\n');
str_colnames = ['#L x filename  z_m diameter concen. scale_msa ' ...
                'temperature  I  epsilon q_min q_max ' ...
                'auto_rescale ff_use  hqratio hqmethod ' ...
                'offset_iq scale_iq  radius_cyl height_cyl ' ...
                'diameter_equiv use_diameter_equiv z_m2 I2 msa-method fname_ff_inp\n'];
fprintf(hstunit, str_colnames); 

fprintf(fitparunit, '#S 1 SQFIT fitting parameters\n');
fprintf(fitparunit, ['#L x z_m z_m_delta sigma sigma_delta I I_delta ' ...
                    'n n_delta z_m2 z_m2_delta I2 I2_delta\n']);

maxlen_fname = max(cellfun('length', {sqfit.fname}));
format_str = ['%4g %' num2str(maxlen_fname) 's %6.2f %6.1f %7.4f ' ...
              '%0.2g %5.1f %7.2f %5.1f %6.4f %6.4f %1i %1i %4.2f ' ...
              '%1i %+4.2e ' '%+4.2e %5.2f %5.2f %5.2f %1i %6.2f ' ...
              '%7.2f %1i %s\n'];
for iset = 1:num_sets
   if ~isfield(sqfit(iset).msa, 'kappa')
      sqfit(iset).msa = msa_getpar(sqfit(iset).msa);
   end
   msa = sqfit(iset).msa;

   sqfit_hst = sprintf(format_str, sqfit(iset).x, sqfit(iset).fname, ...
                       msa.z_m, msa.sigma, msa.n, msa.scale, msa.T, ...
                       msa.I, msa.epsilon, sqfit(iset).q_min, ...
                       sqfit(iset).q_max, sqfit(iset).auto_rescale, ...
                       sqfit(iset).ff_use, sqfit(iset).hqratio, ...
                       sqfit(iset).hqmethod, sqfit(iset).offset_iq, ...
                       sqfit(iset).scale_iq, sqfit(iset).radius_cyl, ...
                       sqfit(iset).height_cyl, sqfit(iset).diameter_equiv, ...
                       sqfit(iset).use_diameter_equiv, ...
                       sqfit(iset).msa.z_m2, sqfit(iset).msa.I2, ...,
                       sqfit(iset).msa.method, ...
                       sqfit(iset).fname_ff_inp);

   fprintf(hstunit, sqfit_hst);

   str_hst = sprintf(['%4g %6.2f %5.3f %6.2f %5.3f %7.2f ' ...
                       '%5.3f %6.3f %5.3f %6.2f %5.3f %7.2f %6.3f\n'], ...
                       sqfit(iset).x, msa.z_m, ...
                       msa.z_m_delta, msa.sigma, msa.sigma_delta, ...
                       msa.I, msa.I_delta, msa.n, msa.n_delta, ...
                       msa.z_m2, msa.z_m2_delta, msa.I2, msa.I2_delta);
   fprintf(fitparunit, str_hst);
   
   if (saveiq == 1) % save data: I(Q), S(Q)
      [dummy, savefile] = fileparts(sqfit(iset).fname);
      savefile = [savefile, suffix];
      wunit = fopen(savefile, 'w');
      fprintf(wunit, '# MSA modeling data written at %s\n', datestr(now));
      fprintf(wunit, '# By program xsqfit\n');
      fprintf(wunit, '##### SQFIT PARAMETERS\n');
      fprintf(wunit, 'smooth_width=%0i\n', sqfit(iset).smooth_width);
      fprintf(wunit, 'smooth_degree=%0i\n', sqfit(iset).smooth_degree);
      fprintf(wunit, 'q_min=%0.4f\n', sqfit(iset).q_min);
      fprintf(wunit, 'q_max=%0.4f\n', sqfit(iset).q_max);
      fprintf(wunit, 'hqratio=%0.4f\n', sqfit(iset).hqratio);
      fprintf(wunit, 'hqmethod=%0i\n', sqfit(iset).hqmethod);
      fprintf(wunit, 'ff_use=%0i\n', sqfit(iset).ff_use);
      fprintf(wunit, 'ff_sol=%s\n', sqfit(iset).fname_ff_sol);
      fprintf(wunit, 'ff_vac=%s\n', sqfit(iset).fname_ff_vac);
      fprintf(wunit, 'ff_exp=%s\n', sqfit(iset).fname_ff_exp);
      fprintf(wunit, 'ff_inp=%s\n', sqfit(iset).fname_ff_inp);
      fprintf(wunit, 'radius_cyl=%0.4f\n', sqfit(iset).radius_cyl);
      fprintf(wunit, 'height_cyl=%0.4f\n', sqfit(iset).height_cyl);
      
      fprintf(wunit, '#S 1 SQFIT setup parameters\n');
      fprintf(wunit, '## MSA T=%f sigma=%f z_m=%f kappa=%f n=%f\n', ...
              sqfit(iset).msa.T, sqfit(iset).msa.sigma, ...
              sqfit(iset).msa.z_m, sqfit(iset).msa.kappa, ...
              sqfit(iset).msa.n);
      fprintf(wunit, str_colnames);   fprintf(wunit, sqfit_hst);
      
      fprintf(wunit, '##### START DATA\n');
      fprintf(wunit, '#S 2 MSA model fitting results\n');
      fprintf(wunit, '#L Q    I(Q)   I(Q)_fit  S(Q)  S(Q)_fit\n');
      if (length(sqfit(iset).iq_fit) < 3)
         sqfit(iset).iq_fit = sqfit(iset).iq;
      end
      if (length(sqfit(iset).sq) < 3);
         sqfit(iset).sq = sqfit(iset).iq;
      end
      if (length(sqfit(iset).sq_fit) < 3);
         sqfit(iset).sq_fit = sqfit(iset).sq;
      end
      fprintf(wunit, '%0.4e  %0.4e  %0.4e  %0.4e  %0.4e\n', ...
              [sqfit(iset).iq(:,[1,2]), sqfit(iset).iq_fit(:,2), ...
               sqfit(iset).sq(:,2), sqfit(iset).sq_fit(:,2)]');
      fclose(wunit);
      disp(sprintf('Wrote data set #%2i to file %s ...', iset, savefile))
   end
end
fclose(hstunit);
fclose(fitparunit);
if (savehst == 1)
   disp(sprintf(['SQFIT setup parameters are summarized into file ' ...
                 '%s.'], hstfile))
end
if (savefitpar == 1)
   disp(sprintf('      fitting parameters are saved into file %s.', fitparfile))
end
