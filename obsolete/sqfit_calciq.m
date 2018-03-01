function sqfit = sqfit_calciq(sqfit, extraopts_)

if (nargin < 1) 
   error('No parameter passed!')
   return
end

% 
num_sets = length(sqfit);
for iset = 1:num_sets
   % update the structure to have the extra options
   if (nargin > 1)
      sqfit(iset) = struct_assign(sqfit(iset), extraopts_);
   end

   % get Q values
   if (length(sqfit(iset).iq_raw) < 3) % no raw data
      q = linspace(0,0.4,401);
      sqfit(iset).q_min = 0.0;
      sqfit(iset).q_max = 0.4;
      sqfit(iset).i_min = 1;
      sqfit(iset).i_max = 401;
      sqfit(iset).iq_raw = repmat(q',1,2);
      sqfit(iset).iq = sqfit(iset).iq_raw;
      sqfit(iset).qrange_rescale = [0.3,0.4];
   elseif (length(sqfit(iset).iq) < 3) % haven't norm iq yet
      sqfit(iset) = sqfit_normiq(sqfit(iset));
   end
   
   
   % calculate S(Q) first --> get sqfit(iset).sq_cal
   if (sqfit(iset).ff_use == 5) && (sqfit(iset).use_diameter_equiv ...
                                    == 1)   % reset the diameter if
                                            % necessary
      sqfit(iset).diameter_equiv = ...
          diameter_equiv_cylinder(sqfit(iset).radius_cyl*2, ...
                                  sqfit(iset).height_cyl);
      sqfit(iset).msa.sigma = sqfit(iset).diameter_equiv;
   end

   sqfit(iset) = sqfit_msafit(sqfit(iset), 1,'nofit'); 
   
   % calculate I(Q) now
   % I(Q) = scale*f2m*(1+fm2/f2m*(S(Q)-1)) + offset
   
   size_sq = size(sqfit(iset).sq_cal);
   sqfit(iset).iq_cal = sqfit(iset).sq_cal;
   for icol = 1:(size_sq(2)-1)
      sq = sqfit(iset).sq_cal(:,[1,icol+1]);
      
      % select the form factor
      switch sqfit(iset).ff_use
         case 1
            ff_norm = sqfit(iset).ff_sol;
         case 2
            ff_norm = sqfit(iset).ff_vac;
         case 3
            ff_norm = sqfit(iset).ff_exp;
         case 4
            ff_norm = sqfit(iset).ff_inp;
         case 5 % cylinder analytical form factor
            if (sqfit(iset).calc_ff_cyl == 1)
               [ff_norm, ff_mean2] = iq_cylinderff(sqfit(iset).radius_cyl, ...
                                                   sqfit(iset).height_cyl, ...
                                                   sqfit(iset).iq(:, 1));
               ff_norm(:,3) = ff_mean2(:,2);
               if (sqfit(iset).auto_rescale == 1)
                  ff_norm = match(ff_norm, [1,1], sqfit(iset) .qrange_rescale);
               end
               sqfit(iset).ff_cyl = ff_norm;
               sqfit(iset).calc_ff_cyl = 0;
            else
               ff_norm = sqfit(iset).ff_cyl;
            end
         otherwise 
            disp('Some error in sqfit_calciq, check it out!')
      end
      
      ff_norm = ff_norm(sqfit(iset).i_min:sqfit(iset).i_max, :);
      
      % ready to compute 
      sqfit(iset).iq_cal(:,icol+1) = ff_norm(:,2).*(1+ff_norm(:, 3) ...
                                                    ./ ff_norm(:, ...
                                                        2) .*(sq(:, ...
                                                        2)-1));
      % update the experimental I(Q) as well
      sqfit(iset).iq(:,2) = 1/sqfit(iset).scale_iq * ...
          (sqfit(iset).iq_raw(sqfit(iset).i_min: sqfit(iset).i_max,2) ...
           - sqfit(iset).offset_iq);
      if (sqfit(iset).smooth_width ~=0) 
         sqfit(iset).iq(:,2) = smooth(sqfit(iset).iq(:,2), ...
                                      sqfit(iset).smooth_width, ...
                                      'sgolay', sqfit(iset).smooth_degree);
      end
   end
end
