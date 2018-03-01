function sAPBS = apbs_analyze(sAPBS, varargin)
% --- Usage:
%        sAPBS = apbs_analyze(sAPBS, varargin)
% --- Purpose:
%        analyze the APBS results in the following ways: 
%        1) potential versus r assumming cylindrical symmetry, 
%        2) ion numbers populated versus energy cutoff (KT), 
%        3) I(Q) variations due to random populations (time consuming)
% --- Parameter(s):
%        sAPBS - the APBS structure
% --- Return(s): 
%        sAPBS - sAPBS.analysis field updated
%
% --- Example(s):
%
% $Id: apbs_analyze.m,v 1.2 2012/06/16 16:43:24 xqiu Exp $
%

verbose = 1;
pot =1;
ionnum = 1; 
ecutoff = 0:0.05:1;
rcutoff = 10:1:60;
iq = 0;
num_iters = 80;
parse_varargin(varargin);

% 1) analyze the potential as a function of distance
if (pot == 1) % integrate the potential energy
   sAPBS.data = sAPBS.pot;
   [sAPBS.analysis.pot_r, sPar] = apbs_int2d(sAPBS);
   sAPBS.analysis.pot_r_colnames = {'r', 'phi kT/e', 'num_points'};
   sAPBS.analysis.sPar = sPar;
end

% 2) number of ions as a function of energy cut off
if (ionnum == 1)
   rand('state',sum(100*clock)); % reset the random number based on
                                 % current time
   num_ecutoffs = length(ecutoff);
   num_rcutoffs = length(rcutoff);
   num_ions = length(sAPBS.ion);
   ionnum_ecutoff = zeros(num_ecutoffs, num_ions+2);
   ionnum_ecutoff(:,1) = ecutoff(:);
   ionnum_rcutoff = zeros(num_rcutoffs, num_ions+2);
   ionnum_rcutoff(:,1) = rcutoff(:);

   % obtain the distance matrix from the center axle
   izmin_rcutoff = fix(sAPBS.dime(3)/3);
   izmax_rcutoff = fix(sAPBS.dime(3)*2/3);
   distmatrix = sqrt(repmat((((1:sAPBS.dime(1)) - (1+sAPBS.dime(1))/2)'* ...
                             sAPBS.delta(1,1)).^2, 1,sAPBS.dime(2)) ...
                     + repmat((((1:sAPBS.dime(2)) - (1+sAPBS.dime(2))/2)* ...
                               sAPBS.delta(2,2)).^2, sAPBS.dime(1), 1));
   
   for i=1:num_ions
      % the asymptotic value for density in each grid
      sAPBS.ion(i).ndens0 = sAPBS.ion(i).n * 6.0221367e23 * 1e-27 * ...
          det(sAPBS.delta);
      
      % the coulomb energy 
      energy = sAPBS.ion(i).z * sAPBS.pot;
      ndens = sAPBS.ion(i).ndens0 * exp(-energy) .* sAPBS.iacc;
      % remove NaNs
      index_nans = find(isnan(ndens)==1);
      if ~isempty(index_nans)
         showinfo([ num2str(length(index_nans)) ' NaNs found (maybe 0*Inf)!'])
         ndens(index_nans) = 0;
      end
      
      % do ion density as a function of r
      sAPBS.data = ndens;
      iondens_r(:,[1,i+1,i+2]) = apbs_int2d(sAPBS);
      
      % do distance cutoff
      ndens2d = sum(ndens(:,:,izmin_rcutoff:izmax_rcutoff), 3);
      for k=1:length(rcutoff)
         index_nocuts = find(distmatrix < rcutoff(k));
         ionnum_rcutoff(k,i+1) = total(ndens2d(index_nocuts));
      end
      
      % do energy cutoff
      for k = 1:length(ecutoff)
         index_nocuts = find(abs(energy) > ecutoff(k));
         ionnum_ecutoff(k,i+1) = total(ndens(index_nocuts));
      end
   end
   iondens_r(:,end) = sum(iondens_r(:,2:end-1) .* ...
                          repmat([sAPBS.ion.z],length(iondens_r(:,1)),1),2);
   sAPBS.analysis.iondens_r = iondens_r;

   ionnum_ecutoff(:,end) = sum(ionnum_ecutoff(:,2:end-1) .* ...
                               repmat([sAPBS.ion.z],num_ecutoffs,1),2);
   sAPBS.analysis.ecutoff = ecutoff;
   sAPBS.analysis.ionnum_ecutoff = ionnum_ecutoff;
   
   ionnum_rcutoff(:,end) = sum(ionnum_rcutoff(:,2:end-1) .* ...
                               repmat([sAPBS.ion.z],num_rcutoffs,1),2);
   sAPBS.analysis.rcutoff = rcutoff;
   sAPBS.analysis.ionnum_rcutoff = ionnum_rcutoff;
end

% 3) the effect of ecutoff on the pouplated ions and scattering
% intensity I think it doesn't matter much once ecutoff is smaller
% than 1.
if (iq == 1)
   % populating the ions to see the effect on scattering
   for i=1:length(ecutoff)
      multinum = 1;
      iq = []; iq_ecutoff = [];
      for k=1:num_iters
         sAPBS = apbs_popions(sAPBS, 'ecutoff', ecutoff(i), 'multinum', ...
                              multinum, 'num_bins', [5,5,3]);
         sAPBS = apbs_popsolvent(sAPBS, 'totalnum', 86);
         sAPBS = apbs_mergeatoms(sAPBS);
         iq(:,[1,k+1]) = iq_calcatoms(sAPBS.atoms);
      end
      iq_ecutoff(:,i+1) = mean(iq(:,2:end),2);
   end
   sAPBS.analysis.iq = iq;
   sAPBS.analysis.iq_ecutoff = iq_ecutoff;
end
