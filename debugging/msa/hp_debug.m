% set initial conditions

clf

% 1) Check against Hayter and Penfold's S(Q) calculation Figure 1

z_m = [20,0.0];
sigma = 50.0;
n=volfrac2con(0.3,sigma/2);
I = 14.77;

num_cals = length(z_m)*length(n)*length(I)*length(sigma);

Q = 0.0:0.005:0.6;
sq = zeros(length(Q), num_cals+1);
sq(:,1) = Q(:);
datalege = repmat({}, num_cals);

msa = msa_init();
msa.method =1;

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
            sq_tmp = msa_calcsq(msa);
            sq(:,i_cal) = spline(sq_tmp(:,1), sq_tmp(:,2), Q(:));
            datalege{i_cal-1} = sprintf(['Charge:%2i, Diameter: ' ...
                                '%2i (Concen=%2iuM, I=%2i mM)'], ...
                                        z_m(iz_m), sigma(isigma), ...
                                        n(in)*1000, I(iI)); 
         end
      end
   end
end

hpdata1 = load('-ascii', 'hpfig1_solid.dat');
hpdata2 = load('-ascii', 'hpfig1_dashed.dat');
hpdata1(:,1) = hpdata1(:,1)/sigma;
hpdata2(:,1) = hpdata2(:,1)/sigma;

subplot(2,1,1), hold all
plot(sq(:,1), sq(:,2:end))
hold all
plot(hpdata1(:,1), hpdata1(:,2), '+')
plot(hpdata2(:,1), hpdata2(:,2),'+')

title('Comparison with Hayter & Penfold Figure 1')
xlim([0.0,0.4])
ylim([0.0,2.0])
xylabel
ylabel S(Q)
legend({'Z=20', 'Z=0.0'})
text(0.23,1.8, {'eta=0.3', 'sigma=50', 'k=2.0'})


% 2) Check against Hayter and Penfold's S(Q) calculation Figure 2

z_m = [0.05, 10, 20, 50, 100, 200];
sigma = 50.0;
n=volfrac2con(0.05,sigma/2);
I = 14.77;

num_cals = length(z_m)*length(n)*length(I)*length(sigma);

Q = 0.0:0.005:0.6;
sq = zeros(length(Q), num_cals+1);
sq(:,1) = Q(:);
datalege = repmat({}, num_cals);

msa = msa_init();
msa.method = 1;

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
            sq_tmp = msa_calcsq(msa);
            sq(:,i_cal) = spline(sq_tmp(:,1), sq_tmp(:,2), Q(:));
            datalege{i_cal-1} = sprintf(['Z=%3i'], z_m(iz_m)); 
         end
      end
   end
end

hpdata1 = load('-ascii', 'hpfig2_e.dat');
hpdata2 = load('-ascii', 'hpfig2_d.dat');
hpdata1(:,1) = hpdata1(:,1)/sigma;
hpdata2(:,1) = hpdata2(:,1)/sigma;
subplot(2,1,2), hold all
plot(sq(:,1), sq(:,2:end))
hold all
plot(hpdata1(:,1), hpdata1(:,2), '+')
plot(hpdata2(:,1), hpdata2(:,2),'+')

title('Comparison with Hayter & Penfold Figure 2')
xlim([0.0,0.4])
ylim([0.0,15.0])
xylabel
ylabel S(Q)
legend(datalege)
text(0.2,12, {'eta=0.05', 'sigma=50', 'k=2.0'})
