function sqfit = sqfit_calmsasqiq(sqfit, varargin)
%        sqfit = sqfit_calmsasqiq(sqfit, varargin)
% --- Purpose:
%    calculate the MSA S(Q) using sqfit_msafit('nofit') -> sqfit.sq_cal
%    multily the form factor (decoupling approximation) -> sqfit.iq_cal
%
%    offset and scale corrections are NOT applied here!!!
%
% --- Parameter(s):
%    sqfit   -- an array of structure (see sqfit_init.m for detail)
%    extraopts_   -- a structure to specify the options on call 
%
% --- Return(s):
%    sqfit - updated sqfit structure
%
% --- Calling Method(s):
%
% --- Example(s):
%
% $Id: sqfit_calmsasqiq.m,v 1.2 2011-03-01 03:56:53 xqiu Exp $

if (nargin < 1) 
   error('No parameter passed!')
   return
end
verbose = 1;
parse_varargin(varargin);

% 
num_sets = length(sqfit);
for iset = 1:num_sets

   % get Q values
   if (length(sqfit(iset).iq_raw) < 5) % no raw data
      q = linspace(0,0.4,401);
      sqfit(iset).q_min = 0.0;
      sqfit(iset).q_max = 0.5;
      sqfit(iset).i_min = 1;
      sqfit(iset).i_max = 501;
      sqfit(iset).iq_raw = repmat(q',1,4);
      sqfit(iset).iq = sqfit(iset).iq_raw;
      sqfit(iset).qrange_rescale = [0.3,0.4];
   elseif (length(sqfit(iset).iq) < 5) % haven't norm iq yet
      sqfit(iset) = sqfit_getexpiqsq(sqfit(iset));
   end
   
   % calculate S(Q) first --> get sqfit(iset).sq_cal (size as sqfit.iq)
   if (sqfit(iset).ff_use == 5) && (sqfit(iset).use_diameter_equiv ...
                                    == 1)   % reset the diameter if
                                            % necessary
      sqfit(iset).diameter_equiv = ...
          diameter_equiv_cylinder(sqfit(iset).radius_cyl*2, ...
                                  sqfit(iset).height_cyl);
      sqfit(iset).msa.sigma = sqfit(iset).diameter_equiv;
   end

   sqfit(iset) = sqfit_msafit(sqfit(iset), 1,'calc_only');
   
   % Get the form factor
   if (sqfit(iset).ff_use == 5) && (sqfit(iset).calc_ff_cyl == 1)
      [ff_norm, ff_mean2] = iq_cylinderff(sqfit(iset).radius_cyl, ...
                                          sqfit(iset).height_cyl, ...
                                          sqfit(iset).iq(:, 1));
      ff_norm(:,3) = ff_mean2(:,2);
      if (sqfit(iset).auto_rescale == 1)
         ff_norm = match(ff_norm, [1,1], sqfit(iset).qrange_rescale);
      end
      sqfit(iset).ff_cyl = ff_norm;
      sqfit(iset).calc_ff_cyl = 0;  % do not re-calculate unless
                                    % diameters changed
   end
   ff_names = {'ff_sol', 'ff_vac', 'ff_exp', 'ff_inp', 'ff_cyl'};
   ff_norm = sqfit(iset).(ff_names{sqfit(iset).ff_use});
   ff_norm = ff_norm(sqfit(iset).i_min:sqfit(iset).i_max, :);
   if (sqfit(iset).ff_use ~= 5)
      ff_norm(:,3) = ff_norm(:,2);
   end
   
   % calculate I(Q) now
   % I(Q) = scale*f2m*(1+fm2/f2m*(S(Q)-1)) + offset
   sqfit(iset).iq_cal = sqfit(iset).sq_cal;
   for icol = 2:size(sqfit(iset).sq_cal, 2)
      sqfit(iset).iq_cal(:,icol) = ff_norm(:,2).*(1+ff_norm(:, 3)./ ...
                             ff_norm(:, 2).*(sqfit(iset).sq_cal(:,icol)-1));
   end
end
