function damminlog = dammin_readlog(logfile, varargin)
% NOTE: to successfully read in a log file, the log file must be
% generated with the non-expert mode, or with a constant background
% subtraction in the expert mode.

verbose =1;
cellarr = cellarr_readascii(logfile);
% remove lines after "===="
cellarr = strtrim(cellarr);
index = strmatch('====', cellarr);
if ~isempty(index)
   cellarr = cellarr(1:index-1);
end
% remove lines starting with "**"
index = strmatch('**', cellarr);
cellarr(index) = [];
% remove empty lines as well
index = strmatch('', cellarr, 'exact');
cellarr(index) = [];
disp(cellarr{1})

% set up the correspondance between config and log data
%   row_names = {'mode', 'Project_file_name', 'Input_data_file', 'title', ...
%                'Units', 'Portion_fit', 'Number_knots', ...
%                'constant_subtraction', 'Maximum_number_harmonics', ...
%                'Initial_file_shape', 'symmetry', 'Sphere_diameter', ...
%                'Packing_radius', 'Expected_particle_shape', ...
%                'Radius_1st_coordination_sphere', 'Looseness_penalty_weight', ...
%                'Disconnectivity_weight_penalty', ...
%                'Peripheral_penalty_weight', 'Fixing_thresholds_Los_and_Rf', ...
%                'Randomize_structure', 'Weight', 'Initial_scale_factor', ...
%                'Fix_scale_factor', 'Initial_annealing_temperature', ...
%                'Annealing_schedule_factor', 'number_atoms_to_modify', ...
%                'Maximum_iterations_at_each_T', ...
%                'Maximum_successes_at_each_T', ...
%                'Maximum_successes_to_continue', 'Maximum_annealing_steps' };
%   
row_names = {'mode', ... % 1
             'Project_file_name', ... % 2
             'Input_data_file', ... % 3
             'title', ... % 4
             'Units', ... % 5
             'Portion_fit', ... % 6
             'Number_knots', ... % 7
             'constant_subtraction', ... % 8
             'Maximum_number_harmonics', ... % 9
             'Initial_file_shape', ...  % 10
             'symmetry', ... % 11
             'Sphere_diameter', ... % 12
             'Packing_radius', ... % 13
             'Expected_particle_shape', ... % 14
             'Radius_1st_coordination_sphere', ... % 15
             'Looseness_penalty_weight', ... % 16
             'Disconnectivity_weight_penalty', ... % 17
             'Peripheral_penalty_weight', ... % 18
             'Fixing_thresholds_Los_and_Rf', ... % 19
             'Randomize_structure', ... % 20
             'Weight', ... % 21
             'Initial_scale_factor', ... % 22
             'Fix_scale_factor', ... % 23
             'Initial_annealing_temperature', ... % 24
             'Annealing_schedule_factor', ... % 25
             'number_atoms_to_modify', ... % 26
             'Maximum_iterations_at_each_T', ... % 27
             'Maximum_successes_at_each_T', ... % 28
             'Maximum_successes_to_continue', ... % 29 
             'Maximum_annealing_steps' }; % 30


%  2    'Computation mode ....................................... : Keep'
%  3    'Project identificator .................................. : a2_expert'
%  4    'Project decsription: test'
%  6    'GNOM file name ......................................... : a2.out'
%  15    'Number of knots in the curve to fit .................... : 35'
%  16    'A constant was subtracted .............................. : 4.138e-6'
%  17    'Maximum order of harmonics ............................. : 15'
%  18    'Point symmetry of the particle ......................... : P1'
%  19    'Sphere  diameter [Angstrom] ............................ : 160.0'
%  20    'Packing radius of dummy atoms .......................... : 4.100'
%  24    'Expected particle anisometry ........................... : Unknown'
%  26    'Radius of 1st coordination sphere ...................... : 11.56'
%  29    'Looseness penalty weight ............................... : 3.000e-3'
%  32    'Disconnectivity penalty weight ......................... : 3.000e-3'
%  36    'Peripheral penalty weight .............................. : 0.3000'
%  44    'Weight: 0=s^2, 1=Emphas.s->0, 2=Log .................... : 1'
%  45    'Initial scale factor ................................... : 3.571e-15'
%  46    'Scale factor fixed (Y=Yes, N=No) ....................... : N'
%  53    'Initial annealing temperature .......................... : 1.000e-3'
%  54    'Annealing schedule factor .............................. : 0.9000'
%  55    '# of independent atoms to modify ....................... : 1'
%  56    'Max # of iterations at each T .......................... : 27970'
%  57    'Max # of successes at each T ........................... : 27970'
%  58    'Min # of successes to continue ......................... : 1'
%  59    'Max # of annealing steps ............................... : 500'

indexcfg2log = ...
             [1,  2;
              2,  3;
              3,  6;
              4,  4;
              7,  15;
              8,  16;
              9,  17;
              11, 18;
              12, 19;
              13, 20;
              14, 24;
              15, 26;
              16, 29;
              17, 32;
              18, 36;
              21, 44;
              22, 45;
              23, 46;
              24, 53;
              25, 54;
              26, 55;
              27, 56;
              28, 57;
              29, 58;
              30, 59]; 


[num_rows, num_cols] = size(indexcfg2log);

% read in each row, only the value after ":" is used
for i=1:num_rows
   
   tokens = strtrim(strsplit(cellarr{indexcfg2log(i,2)}, ':', 'preserve_null'));
   if (length(tokens) < 2)
      showinfo('check out this line, maybe wrong:');
      disp(cellarr{i})
      continue
   end
   
   % check if it's a numeric value or string
   value = str2num(tokens{end});
   if ~isempty(value)
      damminlog.(row_names{indexcfg2log(i,1)}).type = 'N';
      damminlog.(row_names{indexcfg2log(i,1)}).value = value;
   else
      damminlog.(row_names{indexcfg2log(i,1)}).type = 'C';
      damminlog.(row_names{indexcfg2log(i,1)}).value = tokens{end};
   end

   damminlog.(row_names{indexcfg2log(i,1)}).note = strtrim(strrep(tokens{1}, '.', ''));
end
