function sqfit = sqfit_normiq(sqfit, extraopts_)
%        sqfit = sqfit_normiq(sqfit, extraopts_)
% --- Purpose:
%    normalize the I(Q) to get experimental S(Q). This also
%    rescales the data to 1.0
%
% --- Parameter(s):
%    sqfit   -- an array of structure (see sqfit_init.m for detail)
%    extraopts_   -- a structure to specify the options on call 
%
% --- Return(s):
%        sqfit - updated sqfit structure
%
% --- Calling Method(s):
%
% --- Example(s):
%
% $Id: sqfit_normiq.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $

if (nargin < 1) 
   error('No parameter passed!')
   return
end

% 2) do the normalization

num_sets = length(sqfit);
for iset = 1:num_sets
   
   % update the structure to have the extra options
   if (nargin > 1)
      sqfit(iset) = struct_assign(sqfit(iset), extraopts_);
   end
   
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
      sqfit(iset).iq(:,2) = 1/sqfit(iset).scale_iq*sqfit(iset).iq(:,2);
   end

   % calculate the cylindrical form factor if it is used!
   if ((sqfit(iset).ff_use == 5) || (sqfit(iset).getall_sq == 1)) && ...
          (sqfit(iset).calc_ff_cyl == 1)
      disp('SQFIT_NORMIQ:: calculate cylindrical form factor ...')
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
      
   % normalize the I(Q)s using ffs
   for iff =1:5    % cycle through all form factors

      % check whether need to cycle through all normalizations
      if (sqfit(iset).getall_sq ~= 1) && (iff ~= sqfit(iset).ff_use)
         continue
      end
      
      switch iff
         case 1  
            ff_norm = sqfit(iset).ff_sol;
            sq = sqfit(iset).sq_sol;
         case 2 
            ff_norm = sqfit(iset).ff_vac;
            sq = sqfit(iset).sq_vac;
         case 3
            ff_norm = sqfit(iset).ff_exp;
            sq = sqfit(iset).sq_exp;
         case 4
            ff_norm = sqfit(iset).ff_inp;
            sq = sqfit(iset).sq_inp;
         case 5                % cylinder analytical form factor
            ff_norm = sqfit(iset).ff_cyl;
            sq = sqfit(iset).sq_cyl;
         otherwise 
            disp('Some error in sqfit_normiq, check it out!') 
      end

      if (length(ff_norm) < 4)
         disp(['Form factor ' num2str(iff) ' has too few data points,' ...
               ' skip it!'])
         continue
      end

      ff_norm = ff_norm(i_min:i_max, :);
      
      % allocate data if necessary
      if ~isequal(size(sq), [i_max-i_min+1, 2])
         sq = zeros(i_max-i_min+1, 2);
      end
      
      % normalization (brutal and raw)
      sq(:,1) = sqfit(iset).iq(:, 1);
      sq(:,2) = 1 + (sqfit(iset).iq(:, 2) - ff_norm(:,2)) ./ ff_norm(:, 3);
      % assign back different S(Q)s
      switch iff
         case 1  
            sqfit(iset).sq_sol = sq;
         case 2 
            sqfit(iset).sq_vac = sq;
         case 3
            sqfit(iset).sq_exp = sq;
         case 4
            sqfit(iset).sq_inp = sq;
         case 5
            sqfit(iset).sq_cyl = sq;
         otherwise
      end
   end
   
   % set the sqfit(iset).sq to be the used one
   switch sqfit(iset).ff_use
      case 1 
         sqfit(iset).sq = sqfit(iset).sq_sol;
      case 2 
         sqfit(iset).sq = sqfit(iset).sq_vac;
      case 3
         sqfit(iset).sq = sqfit(iset).sq_exp;
      case 4
         sqfit(iset).sq = sqfit(iset).sq_inp;
      case 5 
         sqfit(iset).sq = sqfit(iset).sq_cyl;
      otherwise
         disp('Some error in sqfit_normiq, check it out!')
   end
end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% --- Change History:
%
% $Log: sqfit_normiq.m,v $
% Revision 1.1.1.1  2007-09-19 04:45:38  xqiu
% A new start of my matlab library with new directory structure.
%
% Revision 1.9  2005/06/22 21:31:21  xqiu
% *** empty log message ***
%
% Revision 1.8  2005/06/16 18:35:42  xqiu
% *** empty log message ***
%
% Revision 1.7  2005/03/25 16:40:11  xqiu
% Daily progress being made, and checked back into CVS!
%
% Revision 1.6  2005/03/23 23:20:38  xqiu
% close to completion on 05/03/23!
%
% Revision 1.5  2005/03/23 05:46:54  xqiu
% In the process of improving xsqfit program!
%
% Revision 1.4  2004/12/20 04:48:29  xqiu
% minor changes only
%
% Revision 1.3  2004/10/25 23:29:47  xqiu
% end of the day
%
% Revision 1.2  2004/10/22 20:38:46  xqiu
% my xsqfit basically works now!
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
