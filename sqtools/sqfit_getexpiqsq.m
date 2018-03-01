function sqfit = sqfit_getexpiqsq(sqfit, varargin)
%        sqfit = sqfit_getexpiqsq(sqfit, varargin)
% --- Purpose:
%    apply corrections to experimental I(Q), sqfit.iq_raw -> sqfit.iq
%    normalize by form factor to get experimental S(Q) -> sqfit.sq
%
%    I(Q) corrections are: 1) low and high Q cutoff, 2) smoothening
%         3) offset and scale, 4) autoscale to 1, 5) normalization
%         by form factor to get S(Q)
%
%    S(Q) generated are: sqfit.sq, sqfit.sq_vac, sqfit.sq_sol, etc..
%
% --- Parameter(s):
%    sqfit   -- an array of structure (see sqfit_init.m for detail)
%
% --- Return(s):
%        sqfit - updated sqfit structure
%
% --- Calling Method(s):
%
% --- Example(s):
%
% $Id: sqfit_getexpiqsq.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $

if (nargin < 1) 
   error('No parameter passed!')
   return
end
iq_only = 0;
verbose = 1;
parse_varargin(varargin);

% 2) do the normalization

num_sets = length(sqfit);
for iset = 1:num_sets
   
   % find I(Q) range index of I(Q)_raw
   i_min = locate(sqfit(iset).iq_raw(:,1), sqfit(iset).q_min);  
   i_max = locate(sqfit(iset).iq_raw(:,1), sqfit(iset).q_max);
   sqfit(iset).i_min = i_min;
   sqfit(iset).i_max = i_max;
   
   % smooth it?
   iq_raw = sqfit(iset).iq_raw;
   if (sqfit(iset).smooth_width ~= 0)
      iq_raw(:,2) = smooth(iq_raw(:,2), sqfit(iset).smooth_width,'sgolay', ...
                           sqfit(iset).smooth_degree);
   end
   
   % get I(Q) to within range
   sqfit(iset).iq = iq_raw(i_min:i_max, :);

   % apply the offset and scale
   if (sqfit(iset).offset_iq ~= 0)
      sqfit(iset).iq(:,2) = sqfit(iset).iq(:,2) - sqfit(iset).offset_iq;
   end
   if (sqfit(iset).scale_iq ~= 1.0)
      sqfit(iset).iq(:,[2,4]) = 1/sqfit(iset).scale_iq*sqfit(iset).iq(:,[2,4]);
   end

   % calculate the cylindrical form factor if it is used!
   if ((sqfit(iset).ff_use == 5) || (sqfit(iset).getall_sq == 1)) && ...
          (sqfit(iset).calc_ff_cyl == 1)
      showinfo('calculate cylindrical form factor ...')
      [sqfit(iset).ff_cyl, ff_mean2] = ...
          iq_cylinderff(sqfit(iset).radius_cyl, sqfit(iset).height_cyl, ...
                        sqfit(iset).iq_raw(:, 1));
      sqfit(iset).ff_cyl(:,3) = ff_mean2(:,2);
      sqfit(iset).calc_ff_cyl = 0;
   end
   
   % automatic rescale all I(Q), ffs
   if (sqfit(iset).auto_rescale == 1)
      % find the indexes
      switch sqfit(iset).hqmethod
         case 1 % high Q region (here to get the index for S(Q) only)
            i_smin = ceil((i_max-i_min+1)*(1.0-sqfit(iset).hqratio));
            i_smax = i_max-i_min+1; 
         case 2 % low Q region
            i_smin = 1;
            i_smax = ceil((i_max-i_min+1)*sqfit(iset).hqratio);
         case 3 % medium Q region
            i_smin = ceil((i_max-i_min+1)*(1-sqfit(iset).hqratio)/2.0);
            i_smax = i_smin + ceil((i_max-i_min+1)* ...
                                   sqfit(iset).hqratio);
         otherwise
            i_smin = 1;
            i_smax = i_max - i_min + 1;
      end
      
      % rescale them
      qrange = [sqfit(iset).iq_raw(i_smin,1), sqfit(iset).iq_raw(i_smax,1)];
      sqfit(iset).qrange_rescale = qrange;
      [sqfit(iset).iq, scale] = match(sqfit(iset).iq, [1,1], qrange);
      % adjust the scale accordingly to match the form factors
      sqfit(iset).scale_iq = sqfit(iset).scale_iq/scale; 
      sqfit(iset).ff_sol = match(sqfit(iset).ff_sol, [1,1], qrange);
      sqfit(iset).ff_vac = match(sqfit(iset).ff_vac, [1,1], qrange);
      sqfit(iset).ff_exp = match(sqfit(iset).ff_exp, [1,1], qrange);
      sqfit(iset).ff_inp = match(sqfit(iset).ff_inp, [1,1], qrange);
      sqfit(iset).ff_cyl = match(sqfit(iset).ff_cyl, [1,1], qrange);
   end
   
   % SKIP S(Q)!!!
   if (iq_only == 1); continue; end
   
   % normalize the I(Q)s using ffs
   ff_names = {'ff_sol', 'ff_vac', 'ff_exp', 'ff_inp', 'ff_cyl'};
   sq_names = {'sq_sol', 'sq_vac', 'sq_exp', 'sq_inp', 'sq_cyl'};
   for iff =1:length(ff_names)    % cycle through all form factors

      % check whether need to cycle through all normalizations
      if (sqfit(iset).getall_sq ~= 1) && (iff ~= sqfit(iset).ff_use)
         continue
      end
      
      ff_norm = sqfit(iset).(ff_names{iff});
      sq = sqfit(iset).(sq_names{iff});

      if (length(ff_norm) < 4)
         showinfo(['Form factor ' ff_names{iff} '(#' num2str(iff) ...
                   ') has too few data ' 'points, skip it!'])
         continue
      end

      % assume the same dimension (should be after sqfit_dataprep)
      ff_norm = ff_norm(i_min:i_max, :);
      
      % allocate data if necessary
      if ~isequal(size(sq), [i_max-i_min+1, 2])
         sq = zeros(i_max-i_min+1, 2);
      end
      
      % normalization (brutal and raw)
      sq(:,1) = sqfit(iset).iq(:, 1);
      sq(:,2) = 1 + (sqfit(iset).iq(:, 2) - ff_norm(:,2)) ./ ff_norm(:, 3);

      % assign back different S(Q)s
      sqfit(iset).(sq_names{iff}) = sq;
   end
   
   % set the sqfit(iset).sq to be the used one
   sqfit(iset).sq = sqfit(iset).(sq_names{sqfit(iset).ff_use});
end
