% set initial conditions

length_dna = 25;

z_m = 10;   % charge
n = [0.1,1,10]; % concentration
I = 15; [1:5:15];
sigma = [25];% diameter

num_cals = length(z_m)*length(n)*length(I)*length(sigma);

Q = 0.0:0.005:0.6;
sq = zeros(length(Q), num_cals+1);
sq(:,1) = Q(:);
datalege = repmat({}, num_cals);

msa = msa_init();
msa.method =1;
figure(1); clf;

i_cal = 1;
i_plot = 1;
for isigma = 1:length(sigma)
   for iI = 1:length(I)
      for in = 1:length(n)
         for iz_m = 1:length(z_m)
            i_cal = i_cal + 1;
            msa.z_m = z_m(iz_m);
            msa.n = n(in);
            msa.I = I(iI);
            msa.sigma = sigma(isigma);
            
            msa = msa_getpar(msa);
            [sq_tmp, gr_tmp, ur_tmp, cr_tmp] = msa_calcsq(msa);
            sq(:,i_cal) = spline(sq_tmp(:,1), sq_tmp(:,2), Q(:));
            datalege{i_cal-1} = sprintf(['Charge:%2i, Diameter: ' ...
                                '%2i (Concen=%2iuM, I=%2i mM)'], ...
                                        z_m(iz_m), sigma(isigma), ...
                                        n(in)*1000, I(iI)); 
         end
         subplot(2,1,1); hold all;
         xyplot(sq_tmp);
         subplot(2,1,2); hold all;
         xyplot(cr_tmp);
%         plot(sq(:,1), sq(:,(i_plot-1)*length(z_m)+2:i_plot* length(z_m)+1));
%         legend(datalege{(i_plot-1)*length(z_m)+1:i_plot* ...
%                         length(z_m)}, 'Location', 'SouthEast');
         
         xlim([0.0,0.5]);
         ylim([0.5,1.2]);
         xlabel(['Q (' char(197) '^{-1})']);
         ylabel('S(Q)', 'rotation', 90.0)
%         saveas(gcf, sprintf('diameter%2i_conc%2iuM_ionic%2imM.fig', ...
%                             sigma(isigma), n(in)*1000,I(iI)), 'fig');
         i_plot = i_plot + 1;
      end
   end
end

for iplot=1:4

end


