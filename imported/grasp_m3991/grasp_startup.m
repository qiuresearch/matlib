%***** Grasp Startup Parameters Required for Matlab Script Version *****
disp(['Running Grasp_Startup']);
    
%Directory Path to the root of "Grasp"
global grasp_root;
grasp_root = '/home/xqiu/matlib/imported/grasp_m3991/'; %For example on a PC
%grasp_root = '/home/lss/dewhurst/grasp_m/';

%Grasp Program Paths
addpath([grasp_root]);
addpath(fullfile(grasp_root,'display'));
addpath(fullfile(grasp_root,'data'));
addpath(fullfile(grasp_root,'user_modules'));
addpath(fullfile(grasp_root,'user_modules','fll_math'));
addpath(fullfile(grasp_root,'icons'));
addpath(fullfile(grasp_root,'instrument'));
addpath(fullfile(grasp_root,'sans_math'));
addpath(fullfile(grasp_root,'menu_ops'));
addpath(fullfile(grasp_root,'develop'));
addpath(fullfile(grasp_root,'fit_functions'));
addpath(fullfile(grasp_root,'fit_functions', 'functions'));
addpath(fullfile(grasp_root,'fit_functions', 'functions2d'));
addpath(fullfile(grasp_root,'analysis_tools'));
addpath(fullfile(grasp_root,'callbacks'));
addpath(fullfile(grasp_root,'grasp_script'));
addpath(fullfile(grasp_root,'colormaps'));
addpath(fullfile(grasp_root,'neutron_tools'));
addpath(fullfile(grasp_root,'neutron_tools', 'd22_detector_calibration'));
addpath(fullfile(grasp_root,'neutron_tools', 'data_stats'));
addpath(fullfile(grasp_root,'neutron_tools', 'magnetism'));


%Font Style and Sizes. These should be tuned depending on the system
global font fontsize 
font = 'Arial'; fontsize = 9; %Windows NT/98 (1280x1024 - Small Fonts)
%font = 'Arial'; fontsize = 7; %Windows NT/98 (1280x1024 - Large Fonts)
%font = 'Helvetica'; fontsize = 11; %Linux with x-windows sent from Biceps.   
%font = 'Helvetica'; fontsize = 10; %PC X-win emulator with x-windows sent from Bicpes
%font = 'Helvetica'; fontsize = 10; %SGI with x-windows sent from Bicpes
%font = 'Arial'; fontsize = 7; %Windows NT/98 (1024 - Small Fonts)

%Default Data Dir
global data_dir working_data_dir project_dir project_title
data_dir = 'z:\'; %PC path to network drive 'z' attached to SERDON/DATA/
%data_dir = '/usr/illdata/data/'; %For Unix

global wks_nmbr_max
wks_nmbr_max = 4; %Number of Worksheets per Worksheet Group
global wks_dpth_max
wks_dpth_max = 100; %Max number of depths allowed
%Note: The total number of data arrays alocated per Worksheet Group is wks_nmbr * wks_dpth.
%For example, wks_number = 3, wks_depth = 40 allocates 120 arrays of 128x128 (D22) or 64x64 (D11) etc. per Worksheet group.
%The main DATA matrix can therefore become very large = slower operation = larger saved project sizes.

%Default Instrument
global inst inst_params
inst = 'd22';

%***** Low Level Default Display Variables *****
global background_color sub_figure_background_color
background_color = [0.2 0.22 0.21]; %- Dark Grey /Green
sub_figure_background_color = [0.4 0.05 0]; %- Burgundy

%Other global variables availiable at the Matlab command prompt
global data %Contains all data arrays in a big structure containing: 'name', 'nmbr', 'dpth', 'data', 'dsum', 'params', 'parsub', 'lm'
            %Typical data sheets:  'fore', 'back', 'trans', water', 'water_bck', 'direct', 'cadmium', 'empty', 'mask'            
global det_efficiency %Structure containing .data .error .scale
global displayimage %A structure containing 'data', 'params', 'parsubm', 'lm' of the currently displayed image
global standard_monitor standard_time %Standard Monitor
global fit_parameters
global status_flags %all the settings of menus etc.
global chuck_version








