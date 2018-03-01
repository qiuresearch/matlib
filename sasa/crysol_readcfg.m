function config = crysol_readcfg(cfgfile, varargin)
% read in a cfg file, or initialize without a cfgfile

verbose =1;

% initialize default values

config.option.type = 'I';
config.option.value = 0; % evaluate I(Q)
config.option.note = 'Option';

config.PDB_file.type = 'C';
config.PDB_file.value = '';
config.PDB_file.note = 'PDB file name';

config.process_chains.type = 'I';
config.process_chains.value = 0;
config.process_chains.note = 'Process all chains (0: all)';

config.max_harmonic.type = 'I';
config.max_harmonic.value = 50;
config.max_harmonic.note = 'Max # of harmonics (1-50)';

config.fibonacci_order.type = 'I';
config.fibonacci_order.value = 18;
config.fibonacci_order.note = 'Order of Fibonacci grid (10-18)';

config.qmax.type = 'R';
config.qmax.value  = 0.5;
config.qmax.note = 'Max Q (1/A) (up to 1.0)';

config.num_points.type = 'I';
config.num_points.value = 251;
config.num_points.note = 'Number of points (max 256)';

config.explicit_hydrogen.type = 'C';
config.explicit_hydrogen.value = 'No';
config.explicit_hydrogen.note = 'Account for explicit hydrogen?';

config.fit_curve.type = 'C';
config.fit_curve.value = 'No';
config.fit_curve.note = 'Fit experimental data curve?';

config.solvent_density.type = 'R';
config.solvent_density.value = 0.3340;
config.solvent_density.note = 'Electron density of the solvant';

config.contrast_solvation.type = 'R';
config.contrast_solvation.value = 0.03;
config.contrast_solvation.note = 'Contrast of solvation shell';

config.atomic_radius.type = 'I';
config.atomic_radius.value = 1.536;
config.atomic_radius.note = 'Average atomic radius';

config.excluded_volume.type = 'I';
config.excluded_volume.value = [];
config.excluded_volume.note = 'Excluded volume (use program calculated value)';


% Optional: read in each row from the file, and assign values
% according to the data's type.
if exist('cfgfile', 'var') && exist(cfgfile, 'file');
   
   cellarr = cellarr_readascii(cfgfile);
   cellarr = strtrim(cellarr);
   
   row_names = fieldnames(config);
   for i=1:length(row_names)
      tokens = strtrim(strsplit(cellarr{i}, ' '));
      
      switch config.(row_names{i}).type
         case 'R'  % Real number
            config.(row_names{i}).value = str2num(tokens{1});
         case 'I'  % Integer
            config.(row_names{i}).value = str2num(tokens{1});
         case 'C'  % character
            config.(row_names{i}).value = strtrim(tokens{1});
         otherwise
      end
   end
end
