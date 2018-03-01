% Debug with the Wu and Chen paper data

clf

% 1) the Cytochrome C form factor

cc_model = load('-ascii', 'cytochromec_model.iq');
cc_wc = load('-ascii', 'wc_fig1_ccff.dat');

subplot(2,1,1), hold all
xyplot(cc_model);
hold all
plot(cc_wc(:,1), cc_wc(:,2), '+')
xylabel
xlim([0.0, 0.35])
ylim([0.0,1.1])
title('The form factor of Cytochrome c')
legend({'My calculation', 'From Wu and Chen paper'})
      
% 2) the structure factor S(Q) from Fig. 9

msa=msa_init();
msa.T = 298.0;
msa.sigma = 32.6;    % diameter of the macromolecule
msa.n = 7.61;        % the concentration (mM)
msa.z_m = 20;        % effective charge
msa.I=14.77;   % ionic strengh (calculated from mM)
msa.epsilon = 78.3;  % Dielectric constant of the solvent
msa.method=2;

% calcualte bunch of z_m
z_m = [14.5, 12.4, 8.2];
n = [13.650, 3.413, 0.683];
I = [157.70, 42.73, 11.79];

q = 0.005:0.005:0.5;
sq = zeros(length(q), 1+length(z_m));

for ii = 1:length(z_m)
   msa.z_m = z_m(ii);
   msa.n = n(ii);
   msa.I = I(ii);
   msa = msa_getpar(msa);
   sq(:,[1,ii+1]) = msa_calcsq(msa, q);
end

data_sb1 = load('-ascii', 'wc_fig9_sb1.dat');
data_sb2 = load('-ascii', 'wc_fig9_sb3.dat');
data_sb3 = load('-ascii', 'wc_fig9_sb5.dat');

subplot(2,1,2), hold all
title('Fig. 9 of Wu and Chen paper')
plot(sq(:,1), sq(:,2:end))
plot(data_sb1(:,1), data_sb1(:,2), '+')
plot(data_sb2(:,1), data_sb2(:,2), '+')
plot(data_sb3(:,1), data_sb3(:,2), '+')

