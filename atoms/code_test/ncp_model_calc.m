
%re_calc = 0;
save_iq = re_calc;
q = linspace(0, 0.5, 251)';

if (re_calc == 1);
   % get the atoms
   pdbfile = '1KX5tailfold';
   %atoms = atoms_readpdb([pdbfile '.pdb']);
   %atoms = atoms_select(atoms, 'restype', [1,2]);
   %atoms_dna = atoms_select(atoms, 'restype', 1);
   %atoms_pro = atoms_select(atoms, 'restype', 2);
   
   atoms_dna = atoms_readpdb([pdbfile '_dna.pdb']);
   atoms_pro = atoms_readpdb([pdbfile '_protein.pdb']);
   
   dna_crysol = gnom_loaddata('1KX5tailfold_dna00.int');
   pro_crysol = gnom_loaddata('1KX5tailfold_protein00.int');
   iq_gw = {};
   pr_gw = {};
   
   % consider parallel computing
   if (matlabpool('size') ~= 0); matlabpool close; end
   matlabpool open 2
   parfor i=1:2
      switch i
         case 1
            iq_gw{i} = iqcalc_atoms(atoms_dna, 'sol', 1, 'q', q, ...
                                    'r0', mean(atoms_dna.radius_crysol(:)));
            pr_gw{i} = pcf_calcatoms(atoms_dna, 'r', linspace(0,150,76));
         case 2
            iq_gw{i} = iqcalc_atoms(atoms_pro, 'vac', 1, 'sol',0, ...
                                    'q', q, 'r0', ...
                                    mean(atoms_dna.radius_crysol(:)));
            pr_gw{i} = pcf_calcatoms(atoms_pro, 'r', linspace(0,150, 76));
            % 1.607 for lysozyme
            % 1.485 for dsDNA25mer
      end
   end
   if (matlabpool('size') ~= 0); matlabpool close; end
   save ncp_calc_test.mat;
   
   saveascii(iq_gw{1}, '1KX5_DNA_only.iq');
   saveascii(iq_gw{2}, '1KX5_protein_only.iq');

   saveascii(pr_gw{1}, '1KX5_DNA_only.pr');
   saveascii(pr_gw{2}, '1KX5_protein_only.pr');

else
   load ncp_calc_test.mat;
end

figure(1); clf; figure_fullsize(gcf);

subplot(2,2,1); hold all; title('DNA scattering in vacuum');

xyplot(iq_gw{1}(:,[1,3]));
xyplot(dna_crysol(:,[1,3]));

subplot(2,2,3); hold all; title('DNA scattering in solution');

xyplot(iq_gw{1}(:,[1,2]));
xyplot(dna_crysol(:,[1,2]));
fastsaxs = loadxy('1KX5tailfold_dna_fastsaxs.iq');
plot(fastsaxs(:,1), 10.^fastsaxs(:,2));

subplot(2,2,2); hold all; title('Protein scattering in vacuum');

xyplot(iq_gw{2}(:,[1,3]));
xyplot(pro_crysol(:,[1,3]));

subplot(2,2,4); hold all; title('Protein scattering in solution');

xyplot(iq_gw{2}(:,[1,2]));
xyplot(pro_crysol(:,[1,2]));

for i=1:4
   subplot(2,2,i);
   xlim([0,0.5]);
   set(gca, 'yscale', 'log');
   xylabel('iq');
   legend('GW Debye equation', 'Crysol'); legend boxoff
end

saveps(figure(1), '1KX5_IQ.eps');

figure(2); clf; figure_fullsize(gcf);
hold all;
xyplot(pr_gw{1});
xyplot(pr_gw{2});

xylabel('pr');

legend('DNA only', 'Protein only');
legend boxoff

saveps(figure(2), '1KX5_PR.eps');
