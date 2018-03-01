function config = dammin_readcfg(cfgfile, varargin)

verbose =1;
cellarr = cellarr_readascii(cfgfile);
num_rows = length(cellarr);

row_names = {'mode', 'Project_file_name', 'Input_data_file', 'title', ...
             'Units', 'Portion_fit', 'Number_knots', ...
             'constant_subtraction', 'Maximum_number_harmonics', ...
             'Initial_file_shape' 'symmetry', 'Sphere_diameter', ...
             'Packing_radius', 'Expected_particle_shape', ...
             'Radius_1st_coordination_sphere', 'Looseness_penalty_weight', ...
             'Disconnectivity_weight_penalty', ...
             'Peripheral_penalty_weight', 'Fixing_thresholds_Los_and_Rf', ...
             'Randomize_structure', 'Weight', 'Initial_scale_factor', ...
             'Fix_scale_factor', 'Initial_annealing_temperature', ...
             'Annealing_schedule_factor', 'number_atoms_to_modify', ...
             'Maximum_iterations_at_each_T', ...
             'Maximum_successes_at_each_T', ...
             'Maximum_successes_to_continue', 'Maximum_annealing_steps' };

% check whether it's for EXPERT mode, or else
index_fastmode = [1,2,3,4,5,6,10,11,14];
if (num_rows == length(row_names))
   showinfo('reading dammin config file for expert mode ...');
elseif (num_rows == length(index_fastmode))
   showinfo('reading dammin config file for non-expert mode ...');
   row_names = row_names(index_fastmode);
else
   showinfo('number of rows in config file is not consistent!', 'warning');
   config = [];
   return
end

cellarr = strtrim(cellarr);

% read in each row
for i=1:num_rows
   tokens = strtrim(strsplit(cellarr{i}, '!', 'preserve_null'));
   if (i ~= 4) && (length(tokens) < 3)
      showinfo('check out this line, maybe wrong:');
      disp(cellarr{i})
      continue
   end
   % check if it's a numeric value or string
   value = str2num(tokens{1});
   if ~isempty(value)
      config.(row_names{i}).type = 'N';
      config.(row_names{i}).value = value;
   else
      config.(row_names{i}).type = 'C';
      config.(row_names{i}).value = tokens{1};
   end
   if (i == 4) % the title row
      config.(row_names{i}).note = '';
   else
      config.(row_names{i}).note = tokens{end};
   end
end
