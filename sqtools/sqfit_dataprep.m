function sqfit = sqfit_dataprep(sqfit, varargin)
% --- Usage:
%        sqfit = sqfit_dataprep(sqfit, varargin_)
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
% $Id: sqfit_dataprep.m,v 1.2 2011-04-11 20:38:14 xqiu Exp $
%

if (nargin < 1) 
   error('No parameter passed!')
   return
end
verbose = 1;
readiq = 1;
parse_varargin(varargin);

% 2) do the normalization

num_sets = length(sqfit);
for iset = 1:num_sets

   % 0) re-read the iq_raw
   if readiq == 1
      sqfit(iset).iq_raw = loadxy(sqfit(iset).fname);
   end
   % 1) add the error bar if not present
   num_rowcols = size(sqfit(iset).iq_raw);
   if (num_rowcols(2) < 4)
      sqfit(iset).iq_raw(:,4) = sqrt(abs(iq_raw(:,2)));
   end

   % 2) reset the q_min, q_max if not properly set
   sqfit(iset).q_min = max([sqfit(iset).q_min, sqfit(iset).iq_raw(1,1)]);
   sqfit(iset).q_max = min([sqfit(iset).q_max, sqfit(iset).iq_raw(end,1)]);
   sqfit(iset).i_min = locate(sqfit(iset).iq_raw(:,1), sqfit(iset).q_min);  
   sqfit(iset).i_max = locate(sqfit(iset).iq_raw(:,1), sqfit(iset).q_max);
   
   % 3) interpoloate all form factors to have the same q grid
   ff_names = {'ff_sol', 'ff_vac', 'ff_exp', 'ff_inp', 'ff_cyl'};
   for iff =1:length(ff_names)   % cycle through all form factors
      if (readiq == 1) && isfield(sqfit(iset), ['fname_' ff_names{iff}])
         fname_ff_norm = ['fname_' ff_names{iff}];
         ff_norm = loadxy(sqfit(iset).(fname_ff_norm));
      else
         ff_norm = sqfit(iset).(ff_names{iff});
      end
      
      if (length(ff_norm) < 4)
         disp(['Form factor ' ff_names{iff} '(#' num2str(iff) ') has ' ...
                             'too few data points, skip it!'])
         continue
      end
      
      size_ff = size(ff_norm);
      % interpolate it if necessary
      if ~isequal(ff_norm(:,1), sqfit(iset).iq_raw(:,1))
         disp(['Interpolate Q vector for form factor ' num2str(iff)])
         
         % handle the case of non-unique X of the form factor
         [dummy, index_unique] = unique(ff_norm(:,1));
         ff_norm = ff_norm(index_unique, :);
         
         ff_norm_old = ff_norm;
         ff_norm = sqfit(iset).iq_raw;
         ff_norm(:,2) = interp1(ff_norm_old(:,1), ff_norm_old(:,2), ...
                                ff_norm(:,1), 'pchip', ff_norm_old(end,2));
         if (size_ff(2) > 2)
            ff_norm(:,3) = interp1(ff_norm_old(:,1), ff_norm_old(:,3), ...
                                   ff_norm(:,1), 'pchip', ff_norm_old(end,3));
         end
      end
      
      if (size_ff(2) == 2) % third column is for decoupling approximation
         ff_norm(:,3) = ff_norm(:,2);
      end
      % assign back different form factors
      sqfit(iset).(ff_names{iff}) = ff_norm;
   end
end
