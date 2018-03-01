function sqfit = sqfit_2ndvirial(sqfit, varargin)
%        varargout = sqfit_2ndvirial(sqfit, varargin)
% --- Purpose:
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
% $Id: sqfit_2ndvirial.m,v 1.5 2012/04/10 21:51:12 xqiu Exp $
%

if (nargin < 1)
   error('sqfit structure should be passed!')
   return
end

verbose=1;
guinier_range = [0.008, 0.02];
match_range = [0.08,0.13];
plot_isa=0;
parse_varargin(varargin);

if (plot_isa == 1)
   figure; hold all;
end

for isqfit=1:length(sqfit)
   % number of particles per A^3
   pho=sqfit(isqfit).msa.n*1e-3*6.0221415e23*1e-27; 

   % method #1: guinier region extrapolation, divided by form
   % factor, get the I(Q)/P(Q)|Q=0
   
   iq=sqfit(isqfit).iq;
   guinier_fit = gyration(iq, guinier_range);
   ff_names = {'ff_sol', 'ff_vac', 'ff_exp', 'ff_inp', 'ff_cyl'};
   ff = load('-ascii', sqfit(isqfit).(['fname_' ff_names{sqfit(isqfit).ff_use}]));
   if (ff(1,1) ~=0)
      ff(1,2) = spline(ff(:,1), ff(:,2), 0);
   end
   factor = mean(ff(locate(ff(:,1), match_range(1)):locate(ff(:,1), ...
                                                     match_range(2)),2)) ...
            / mean(iq(locate(iq(:,1), match_range(1)): locate(iq(:,1), ...
                                                     match_range(2)),2));
   iq0(1) = guinier_fit.i0(1);
   iq0_error(1) = guinier_fit.i0(2);
   sq0(1)=guinier_fit.i0(1)/(ff(1,2)/factor);
   sq0_error(1) = guinier_fit.i0(2)/(ff(1,2)/factor);
   virial_B2(1)=(1/sq0(1)-1)/2/pho;
   virial_B2_error(1) = sq0_error(1)/sq0(1)/sq0(1)/2/pho;
   
   if (plot_isa==1)
      plot(iq(:,1), iq(:,2));
      plot(guinier_fit.fit(:,1), guinier_fit.fit(:,2));
   end
   
   % method #2: calculate the S(Q) at Q=0
   
   msa=msa_getpar(sqfit(isqfit).msa);
   [sq,gr,ur,cr]=msa_calcsq(msa, linspace(0,0.1,101), linspace(msa.sigma, ...
                                                     msa.sigma*13, 2001));

   sq0(2)=sq(1,2);
   sq0_error(2) = 0;
   virial_B2(2)=(1/sq(1,2)-1)/2/pho;
   virial_B2_error(2) = 0;
   
   % Added on 06/02/2007: to calculate the internal energy, which
   % is in reality the electrostatic repulsive energy.
   %    figure(1);  hold all
   %    xyplot(gr)
   %    figure(2); hold all
   %    xyplot(ur);
   % calculate the averge internal energy per DNA
   sqfit(isqfit).U = 2*pi*pho*total(ur(:,2).*gr(:,2).*(ur(:,1).^2)* ...
                                    (ur(2,1)-ur(1,1)));

   % calculate the partial pressure
   sqfit(isqfit).PV = 1-2*pi*pho/3*total((ur(:,2)-[ur(1,2);ur(1: ...
                                                     end-1,2)]).* ...
                                         gr(:,2).*(ur(:,1).^3));
   
   % what about the entropy and free energy
   sqfit(isqfit).TS = log(sqfit(1).msa.n/sqfit(isqfit).msa.n);
   sqfit(isqfit).U_TS = sqfit(isqfit).U + sqfit(isqfit).TS;
   sqfit(isqfit).G = sqfit(isqfit).U + sqfit(isqfit).PV - sqfit(isqfit).TS;
   
   % method #3: calculate from the potential U(r)
   virial_B2(3)=2*pi*msa.sigma^3/3 + ...
                2*pi*total((1-exp(-ur(:,2))).*(ur(:,1).^2))*(ur(2,1)-ur(1,1));
   virial_B2_error(3) = 0;
   
   % convert virial_B2 in A^3 to A2
   virial_A2 = secondvirial_B22A2(virial_B2, sqfit(isqfit).molweight);
   virial_A2_error = secondvirial_B22A2(virial_B2_error, sqfit(isqfit).molweight);

   sqfit(isqfit).virial.pho=pho;
   sqfit(isqfit).virial.pho_unit = '#/A^3';
   sqfit(isqfit).virial.c=pho*sqfit(isqfit).molweight/6.0221415e23*1e24;
   sqfit(isqfit).virial.c_unit = 'g/ml';
   
   sqfit(isqfit).virial.IQ0=iq0;
   sqfit(isqfit).virial.IQ0_error=iq0_error;

   sqfit(isqfit).virial.SQ0=sq0;
   sqfit(isqfit).virial.SQ0_error=sq0_error;
   sqfit(isqfit).virial.legend={'Extrapolated I(0)/P(0)', ['Model ' ...
                                 'S(0)'], 'U(r) integration'};
   sqfit(isqfit).virial.B2=virial_B2;
   sqfit(isqfit).virial.B2_error=virial_B2_error;
   sqfit(isqfit).virial.B2_unit = 'A^3/#';
   sqfit(isqfit).virial.A2=virial_A2;
   sqfit(isqfit).virial.A2_error=virial_A2_error;
   sqfit(isqfit).virial.A2_unit = 'ml*mol/g^2';
   sqfit(isqfit).virial.sq = sq;
   sqfit(isqfit).virial.ur = ur;
   
   disp(sprintf('#%i: %s, B2: [%g, %g, %g], A2: [%g, %g, %g]', ...
                sqfit(isqfit).num, sqfit(isqfit).legend, ...
                sqfit(isqfit).virial.B2, sqfit(isqfit).virial.A2));
end

if (plot_isa ==1)
   ylimit = get(gca, 'Ylim');
   line([guinier_range(1), guinier_range(1)], ylimit);
   line([guinier_range(2), guinier_range(2)], ylimit);
end
