function grasp(inst_in);

global last_saved
%inst_in declares the default instrument

%Declare functions that are only used by callbacks - Required for Runtime
%#function display_menu_callbacks
%#function file_menu
%#function file_export_image
%#function data_read
%#function main_callbacks
%#function maskedit_callbacks
%#function calibration_callbacks
%#function tool_menu
%#function centre_of_mass
%#function contour_options_window
%#function contour_options_callbacks
%#function grasp_movie
%#function radialav_window
%#function radial_average
%#function radialav_callbacks
%#function ancos2_window
%#function mask_edit_window
%#function mask_mod
%#function plotter_callbacks
%#function sub_figure_file_menu
%#function output_figure
%#function curve_fit_window
%#function curve_fit_window_2d
%#function ancos2
%#function ancos2_callbacks
%#function sector_window
%#function sectbox_window
%#function ellipse_window
%#function ellipsebox_window
%#function ellipsebox_callbacks
%#function strips_window
%#function box_window
%#function water_analysis_window
%#function misc_callbacks
%#function display_param_list
%#function multi_fox
%#function strip_analysis
%#function inst_menu
%#function data_menu
%#function data_map_window
%#function fft_image
%#function display_instrument_params
%#function curve_fit_window_2d
%#function transmission_calc
%#function projection_window
%#function projection
%#function background_shifter_window
%#function shifter
%#function erase_curve
%#function curve_regroup
%#function curve_regroup_v2
%#function curve_math
%#function live_coords
%#function add_worksheet

%***** Compiled User Modules *****
%#function fll_window
%#function fll_calc
%#function fll_angle_window
%#function fll_angle_calc
%#function fll_angle_mod
%#function spot_angle_average_window
%#function spot_angle_average_callbacks
%#function rapid_beam_centre_window
%#function rapid_beam_centre_callbacks
%#function wiggle_write
%#function beam_centre_window
%#function beam_centre_calc
%#function beam_centre_mod
%#function data_generator_window
%#function data_generator
%#function data_generator_mod
%#function anisotropy_calculate_window
%#function anisotropy_callbacks

%***** Compiled Fit Function *****
%#function fit_control
%#function fit_control_2d
%#function depth_fit_control_2d
%#function curve_fit_check_mod
%#function curve_fit_check_mod_2d
%#function mf_dfdp_grasp
%#function mf_lsqr_grasp
%#function gauss_2d_n
%#function gauss_2d_n_polar
%#function gauss_2d_n_polar_old
%#function cos_sqr
%#function gauss_n
%#function linear
%#function lorz_n
%#function lorz_qn
%#function trapezoidal
%#function linear_step
%#function q4
%#function qn
%#function gauss_qn
%#function lorz_qn
%#function guinier
%#function sphere_ff
%#function gauss_coil

%***** Compiled Colormaps *****
%#function spring
%#function harrier
%#function blush
%#function barbie
%#function grass
%#function pond
%#function wolves
%#function damson
%#function aubergine
%#function army1
%#function army2
%#function blueberry
%#function bathtime
%#function blues


%Load any user_configurable data from grasp.ini
grasp_ini

%***** Check to see if window is already open *****
h=findobj('Tag','grasp_main');
if not(isempty(h));
    disp('GRASP is already running');
    figure(h);
    
    %***** Draw the main Grasp interface *****   
else
    
    %***** Initialise Grasp Startup Parameters and Global Variables *****
    
    %***** Grasp Global Variables *****
    global chuck_version; chuck_version = '3.991'; %Last Mods - June 2004.
    global chuck_program_name; chuck_program_name = 'GRASP';
    
    set(0,'defaultfigurepapertype','a4');
    colordef black; %Window bacground
    
    global grasp_root
    global status_flags; status_flags.axes.change = 'p';
    
    global data_dir working_data_dir project_title project_dir
    if isempty(data_dir); data_dir = [pwd filesep]; end %Required for PC Runtime
    if isempty(working_data_dir); working_data_dir = data_dir; end %Required for runtime
    if isempty(project_dir); project_dir = data_dir; end %Required for runtime
    
    global font fontsize
    if isempty(font); font = 'Arial'; end %Required for runtime
    if isempty(fontsize); fontsize = 9; end %Required for runtime
    screen_res = get(0,'ScreenSize'); fontsize = fontsize*screen_res(3)/1280; %Check for system screen size problems
    
    %***** Calculate Screen Scale Factor - Due to Different Aspect Ratio Screens, e.g. Mac wide screens
    global screen
    screen_res = get(0,'screensize');
    reference_res = [1280,1024]; %Reference Screen Resolution and Aspect Ratio that Grasp was written for.
    ref_ratio = reference_res(1)/reference_res(2);
    screen_ratio = screen_res(3)/screen_res(4);
    screen = sqrt(screen_ratio / ref_ratio);
    
    global background_color sub_figure_background_color
    if isempty(background_color); background_color = [0.2 0.22 0.21]; end %Required for runtime - Dark Grey /Green
    if isempty(sub_figure_background_color); sub_figure_background_color = [0.4 0.05 0]; end  %Required for runtime - Burgundy
    
    global inst
    if nargin == 1; inst = inst_in; end %incase inst is declared on the command line
    if isempty(inst); inst = 'd22'; end %Required for runtime
    global inst_params
    
    global data
    
    global wks_dpth_max wks_nmbr_max
    if isempty(wks_nmbr_max); wks_nmbr_max = 3; end
    if isempty(wks_dpth_max); wks_dpth_max = 100; end
    
    %***** Initialise Insturment Patameters and Array Space *****
    initialise_instrument_params;
    initialise_data_arrays;
    
    %***** Start: Main User Interface *****
    figure_handle = figure('units','normalized','Position',[0.0578  0.1396  0.5203/screen  0.7500*screen],'Name',[chuck_program_name ' V' chuck_version ' - ' project_title],...
        'Tag','grasp_main','NumberTitle','off','color',background_color,'inverthardcopy','on','papertype','A4','menubar','none', 'PaperPosition',[0.65625 1.84375 6.9375 8],'PaperPositionMode','auto',...
        'closerequestfcn','file_menu(''exit'');');
    set(figure_handle,'resize','off'); %Windows XP quick fix
    
    %***** Modify Default Menu and Tool Items *****
    modify_main_menu_items(gcf);
    modify_main_tool_items(gcf);
    pause(0.1); %Let the figure window finnish displaying
    
    
    %***** Worksheet Display and Load selector *****
    %This adds a border around the worksheet selector - not sure if I like it.
    %shade_factor = [0.95 0.95 0.9];
    %background_color = background_color .* shade_factor;
    %uicontrol('units','normalized','Position',[0.005,0.17,0.50,0.21],'HorizontalAlignment','right','Style','frame','BackgroundColor', background_color,'ForegroundColor', background_color,'tag','worksheet_frame');

    uicontrol('units','normalized','Position',[0.01,0.286,0.49,0.074],'HorizontalAlignment','right','Style','frame','BackgroundColor', background_color,'ForegroundColor', [1 1 1]);
    uicontrol('units','normalized','Position',[0.02,0.32,0.11,0.02],'FontName',font,'FontSize',fontsize,'HorizontalAlignment','right','Style','text','String','Foreground:','BackgroundColor', background_color, 'ForegroundColor', [1 1 1]);
    uicontrol('units','normalized','Position',[0.02,0.3,0.11,0.02],'FontName',font,'FontSize',fontsize,'HorizontalAlignment','right','Style','text','String','& Data Load:','BackgroundColor', background_color, 'ForegroundColor', [1 1 1]);
    %***** Worksheet Grouping *****
    %Group Worksheets Check Box
    uicontrol('units','normalized','Position',[0.225,0.28,0.065,0.020],'FontName',font,'FontSize',fontsize,'HorizontalAlignment','right','Style','text','String','Group:','BackgroundColor', background_color, 'ForegroundColor', [1 1 1]);
    uicontrol('units','normalized','Position',[0.36,0.277,0.03,0.025],'tooltip','Group Worksheet Numbers','FontName',font,'FontSize',fontsize,'Style','checkbox','Tag','group_worksheets_check','BackgroundColor', background_color, 'ForegroundColor', [1,1,1],'callback','main_callbacks(''wks_group'');');
    uicontrol('units','normalized','Position',[0.45,0.277,0.03,0.025],'tooltip','Group Worksheet Depths','FontName',font,'FontSize',fontsize,'Style','checkbox','Tag','group_depth_check','BackgroundColor', background_color, 'ForegroundColor', [1,1,1],'callback','main_callbacks(''dpth_group'');');
    
    %Worksheet Selector
    uicontrol('units','normalized','Position',[0.16,0.31,0.13,0.03],'FontName',font,'FontSize',fontsize,'tooltip',['Select Worksheet Type' char(13) char(10) 'e.g. Foreground, Background or Cadmium Scattering Data'],'Style','Popup','Tag','worksheet','String','fore','Value',1,'CallBack','selector_build;selector_build_values;main_callbacks(''refresh_q_axes'');update_display'); %Callback also sets flag to refresh axes
    uicontrol('units','normalized','Position',[0.17,0.35,0.10,0.020],'FontName',font,'FontSize',fontsize,'HorizontalAlignment','right','Style','text','String','Worksheet:','BackgroundColor', background_color, 'ForegroundColor', [1 1 1]);
    %Number Selector
    uicontrol('units','normalized','Position',[0.30,0.31,0.08,0.03],'FontName',font,'FontSize',fontsize,'tooltip',['Select Worksheet Number'],'Style','Popup','Tag','number','String','1','CallBack','update_grouped_selectors;selector_build_values;main_callbacks(''refresh_q_axes'');update_display','Value',1); %Callback also sets flag to refresh axes
    uicontrol('units','normalized','Position',[0.295,0.35,0.08,0.020],'FontName',font,'FontSize',fontsize,'HorizontalAlignment','right','Style','text','String','Number:','BackgroundColor', background_color, 'ForegroundColor', [1 1 1]);
    %Depth Selector
    uicontrol('units','normalized','Position',[0.39,0.31,0.08,0.03],'FontName',font,'FontSize',fontsize,'tooltip',['Worksheet Depth :' char(13) char(10) 'Many Files Stored Individually Making Up a Single Measurement'],'Style','Popup','Tag','depth','String','1','CallBack','update_grouped_selectors;main_callbacks(''refresh_q_axes'');update_display','Value',1); %Callback also sets flag to refresh axes
    uicontrol('units','normalized','Position',[0.39,0.35,0.06,0.020],'FontName',font,'FontSize',fontsize,'HorizontalAlignment','right','Style','text','String','Depth:','BackgroundColor', background_color, 'ForegroundColor', [1 1 1]);
    
    %***** Worksheet Subtract Selector *****
    gx = 0.03; gy = 0.24; %Group Postions (normalized);
    %Worksheet Subtraction selector
    uicontrol('units','normalized','Position',[gx-0.01,gy,0.11,0.025],'FontName',font,'FontSize',fontsize,'HorizontalAlignment','right','Style','text','String','Background:','BackgroundColor', background_color, 'ForegroundColor', [1 1 1]);
    %Subtract CheckBox
    uicontrol('units','normalized','Position',[gx+0.105,gy,0.03,0.025],'tooltip','Subtract Sample Background','FontName',font,'FontSize',fontsize,'Style','checkbox','Tag','subtract_check','BackgroundColor', background_color, 'ForegroundColor', [1,1,1],'value',0,'CallBack','update_display');
    %Worksheet Selector
    uicontrol('units','normalized','Position',[gx+0.13,gy,0.13,0.03],'FontName',font,'FontSize',fontsize,'Style','Popup','Tag','worksheet_subtract','String','xxxx','CallBack','selector_build_values;main_callbacks(''wks_sub'');');
    %Number Selector
    uicontrol('units','normalized','Position',[gx+0.27,gy,0.08,0.03],'FontName',font,'FontSize',fontsize,'Style','Popup','Tag','number_subtract','String','1','CallBack','selector_build_values;update_grouped_selectors;main_callbacks(''refresh_q_axes'');update_display','Value',1);
    %Depth Selector
    uicontrol('units','normalized','Position',[gx+0.36,gy,0.08,0.03],'FontName',font,'FontSize',fontsize,'Style','Popup','Tag','depth_subtract','String','1','CallBack','update_grouped_selectors;main_callbacks(''refresh_q_axes'');update_display','Value',1);
    
    %***** Worksheet Cadmium Selector *****
    gx = 0.03; gy = 0.19; %Group Postions (normalized);
    %Worksheet Cadmium selector
    uicontrol('units','normalized','Position',[gx-0.01,gy,0.11,0.025],'FontName',font,'FontSize',fontsize,'HorizontalAlignment','right','Style','text','String','Cadmium:','BackgroundColor', background_color, 'ForegroundColor', [1 1 1]);
    %Subtract CheckBox
    uicontrol('units','normalized','Position',[gx+0.105,gy,0.03,0.025],'tooltip','Subtract Cadmium Background','FontName',font,'FontSize',fontsize,'Style','checkbox','Tag','cadmium_check','BackgroundColor', background_color, 'ForegroundColor', [1,1,1],'value',0,'CallBack','update_display');
    %Worksheet Selector
    uicontrol('units','normalized','Position',[gx+0.13,gy,0.13,0.03],'FontName',font,'FontSize',fontsize,'Style','Popup','Tag','worksheet_cadmium','String','xxxx','CallBack','selector_build_values;main_callbacks(''wks_cad'');');
    %Number Selector
    uicontrol('units','normalized','Position',[gx+0.27,gy,0.08,0.03],'FontName',font,'FontSize',fontsize,'Style','Popup','Tag','number_cadmium','String','1','CallBack','selector_build_values;update_grouped_selectors;main_callbacks(''refresh_q_axes'');update_display','Value',1);
    %Depth Selector
    uicontrol('units','normalized','Position',[gx+0.36,gy,0.08,0.03],'FontName',font,'FontSize',fontsize,'Style','Popup','Tag','depth_cadmium','String','1','CallBack','update_grouped_selectors;main_callbacks(''refresh_q_axes'');update_display','Value',1);
    
    %background_color = background_color ./ shade_factor;

    
    %***** Data Load *****
    tooltip_string = ['Enter Data Numor(s):' char(13) char(10) 'Options:' char(13) char(10) '''>''   - Sum  Numors Into Single Depth' char(13) char(10) ''':''    - Store Numors Incrementaly in Depth' char(13) char(10) '''+''   - Sum Individual Numors' char(13) char(10) ''',''    - Store Invdividual Numors Incrementaly in Depth' char(13) char(10) '''(n;s)'' - Used after Numor [eg. 12345(5;2)].  Sum ''n'' Numors ' char(13) char(10) '           Skipping Every ''s''. Can be combined with '',''' char(13) char(10) '''{n;s}'' - Used after Numor [eg. 12345{5;2}].  Store ''n'' Numors in Depth ' char(13) char(10) '           Skipping Every ''s''. Can be combined with '','''];
 
    %for florian to try to stop crashing with NT: Removed the callback from the numor entry edit box
    uicontrol('units','normalized','Position',[0.135,0.1,0.34,0.03],'tooltip',tooltip_string,'FontName',font,'FontSize',fontsize,'Style','edit','String','<Numors>','HorizontalAlignment','left','Tag','data_load','Visible','on');%,'CallBack','data_read;update_display');
    %uicontrol('units','normalized','Position',[0.15,0.07,0.31,0.03],'tooltip',tooltip_string,'FontName',font,'FontSize',fontsize,'Style','edit','String','<Numors>','HorizontalAlignment','left','Tag','data_load','Visible','on','CallBack','data_read;update_display');

    %Extra Extension window for HMI & NIST
    tooltip_string = 'Enter file extension: e.g. ''001'' or ''ASC'' for HMI or NIST data';
    if strcmp(inst,'V4_HMI_64') | strcmp(inst,'V4_HMI_128') | strcmp(inst,'NIST_ng7') | strcmp(inst,'d22_rawdata'); visible = 'on'; else visible = 'off'; end
    uicontrol('units','normalized','Position',[0.48,0.1,0.06,0.03],'tooltip',tooltip_string,'FontName',font,'FontSize',fontsize,'Style','edit','String','.001','HorizontalAlignment','right','Tag','data_load_extension','Visible',visible,'callback','main_callbacks(''fname_extension'')');

    %Extra SortName for NIST
    tooltip_string = 'Enter file short name, e.g. ''ABC'', for NIST ASCII data';
    if strcmp(inst,'NIST_ng7'); visible = 'on'; else visible = 'off'; end
    uicontrol('units','normalized','Position',[0.02,0.14,0.11,0.02],'FontName',font,'FontSize',fontsize,'HorizontalAlignment','right','Style','text','String','Title:','BackgroundColor', background_color, 'tag', 'data_load_shortname_text','ForegroundColor', [1 1 1],'visible',visible);
    uicontrol('units','normalized','Position',[0.135,0.14,0.07,0.03],'tooltip',tooltip_string,'FontName',font,'FontSize',fontsize,'Style','edit','String','ABC','HorizontalAlignment','right','Tag','data_load_shortname','Visible',visible,'callback','main_callbacks(''fname_shortname'')');
    
    
    uicontrol('units','normalized','Position',[0.02,0.1,0.11,0.02],'FontName',font,'FontSize',fontsize,'HorizontalAlignment','right','Style','text','String','Numor(s):','BackgroundColor', background_color, 'ForegroundColor', [1 1 1]);
    %Increment and Getit
    uicontrol('units','normalized','Position',[0.165,0.072,0.02,0.02],'tooltip','Increment Numor and Get It','FontName',font,'FontSize',fontsize,'Style','pushbutton','String','+','HorizontalAlignment','center','Tag','increment_get_it','Visible','on','CallBack','main_callbacks(''numor_plus'');');
    %Decrement and Getit
    uicontrol('units','normalized','Position',[0.135,0.072,0.02,0.02],'tooltip','Decrement Numor and Get It','FontName',font,'FontSize',fontsize,'Style','pushbutton','String','-','HorizontalAlignment','center','Tag','decrement_get_it','Visible','on','CallBack','main_callbacks(''numor_minus'');');
    %Data Get-it button
    uicontrol('units','normalized','Position',[0.395,0.07,0.08,0.025],'tooltip','Load Data into Selected Worksheet','FontName',font,'FontSize',fontsize,'Style','pushbutton','String','Get It!','HorizontalAlignment','center','Tag','numor_get_it','Visible','on','CallBack','data_read;update_display','userdata','0');%,'busyaction','cancel','userdata',0);
    
    %***** Displayed Processing Check Boxes *****
    gx = 0.82; gy = 0.70; %Group Postions (normalized);
    %Log
    uicontrol('units','normalized','Position',[gx,gy,0.03,0.025],'ToolTip','Log Display z-Data','FontName',font,'FontSize',fontsize,'Style','checkbox','Tag','image_log','BackgroundColor', background_color, 'ForegroundColor', [1,1,1],'value',0,'callback','main_callbacks(''log'');');
    uicontrol('units','normalized','Position',[gx+0.035,gy,0.14,0.025],'style','text','string',' : Log Z','HorizontalAlignment','left','BackgroundColor', background_color, 'ForegroundColor', [1,1,1],'FontName',font,'FontSize',fontsize);
    %ZMin Zmax Range
    gy = gy-0.03;
    uicontrol('units','normalized','Position',[gx,gy,0.03,0.025],'tooltip','Manual z-Scale : Enter z-min and z-max Display Range','FontName',font,'FontSize',fontsize,'Style','checkbox','Tag','manual_z_check','BackgroundColor', background_color, 'value',status_flags.display.manualz.check,...
        'foregroundcolor',[1 1 1],'callback','main_callbacks(''zmaxmin'');');
    uicontrol('units','normalized','Position',[gx+0.035,gy,0.14,0.025],'style','text','string',' : Manual Z Scale','HorizontalAlignment','left','BackgroundColor', background_color, 'ForegroundColor', [1,1,1],'FontName',font,'FontSize',fontsize);
    uicontrol('units','normalized','position',[gx,gy-0.03,0.08,0.025],'FontName',font,'FontSize',fontsize,'Style','edit','string',num2str(status_flags.display.manualz.min),'Tag','manual_zmin', 'callback','main_callbacks(''zmin'');','horizontalalignment','right','visible','off');
    uicontrol('units','normalized','position',[gx+0.09,gy-0.03,0.08,0.025],'FontName',font,'FontSize',fontsize,'Style','edit','string',num2str(status_flags.display.manualz.max),'Tag','manual_zmax', 'callback','main_callbacks(''zmax'');','horizontalalignment','right','visible','off');
    %Image Plot Type
    gy = gy-0.06;
    uicontrol('units','normalized','Position',[gx,gy,0.03,0.025],'tooltip','Colour Display Image','FontName',font,'FontSize',fontsize,'Style','checkbox','Tag','image_display_check','BackgroundColor', background_color, 'ForegroundColor', [1,1,1],'value',status_flags.display.image,'CallBack','main_callbacks(''image'');');
    uicontrol('units','normalized','Position',[gx+0.035,gy,0.14,0.025],'style','text','string',' : Image','HorizontalAlignment','left','BackgroundColor', background_color, 'ForegroundColor', [1,1,1],'FontName',font,'FontSize',fontsize);
    %Contour Plot Type
    gy = gy-0.03;
    uicontrol('units','normalized','Position',[gx,gy,0.03,0.025],'tooltip','Contour Display Image','FontName',font,'FontSize',fontsize,'Style','checkbox','Tag','contour_display_check','BackgroundColor', background_color, 'ForegroundColor', [1,1,1],'value',status_flags.display.contour,'CallBack','main_callbacks(''contour'');');
    uicontrol('units','normalized','Position',[gx+0.035,gy,0.14,0.025],'style','text','string',' : Contour','HorizontalAlignment','left','BackgroundColor', background_color, 'ForegroundColor', [1,1,1],'FontName',font,'FontSize',fontsize);
    %Apply Smoothing to Display
    gy = gy-0.03;
    uicontrol('units','normalized','Position',[gx,gy,0.03,0.025],'tooltip','Smooth Image (Display Only)','FontName',font,'FontSize',fontsize,'Style','checkbox','Tag','smooth_display_check','BackgroundColor', background_color, 'ForegroundColor', [1,1,1],'value',status_flags.display.smooth,'CallBack','main_callbacks(''smooth'');');
    uicontrol('units','normalized','Position',[gx+0.035,gy,0.14,0.025],'style','text','string',' : Smooth','HorizontalAlignment','left','BackgroundColor', background_color, 'ForegroundColor', [1,1,1],'FontName',font,'FontSize',fontsize);
    %Display Rotate
    gy = gy-0.03;
    uicontrol('units','normalized','Position',[gx,gy,0.03,0.025],'tooltip','Rotate Image (Display Only)','FontName',font,'FontSize',fontsize,'Style','checkbox','Tag','rotate_display_check','BackgroundColor', background_color, 'ForegroundColor', [1,1,1],'value',status_flags.display.rotate.check,'CallBack','main_callbacks(''rotate'');');
    uicontrol('units','normalized','Position',[gx+0.035,gy,0.14,0.025],'style','text','string',' : Rotate','HorizontalAlignment','left','BackgroundColor', background_color, 'ForegroundColor', [1,1,1],'FontName',font,'FontSize',fontsize);
    uicontrol('units','normalized','position',[gx+0.12,gy,0.05,0.025],'FontName',font,'FontSize',fontsize,'Style','edit','string',num2str(status_flags.display.rotate.angle),'Tag','rotate_display_angle', 'callback','main_callbacks(''rotate_angle'');','horizontalalignment','right','visible','off');
    %Composite Mask Button
    gy = gy-0.06;
    uicontrol('units','normalized','Position',[gx,gy,0.03,0.025],'tooltip','Mask Data','FontName',font,'FontSize',fontsize,'Style','checkbox','Tag','mask_composite_check','BackgroundColor', background_color, 'ForegroundColor', [1,1,1],'value',status_flags.display.mask.check,'CallBack','main_callbacks(''mask_check'');');
    uicontrol('units','normalized','Position',[gx+0.035,gy,0.14,0.025],'style','text','string',' : Mask','HorizontalAlignment','left','BackgroundColor', background_color, 'ForegroundColor', [1,1,1],'FontName',font,'FontSize',fontsize);
    index = data_index('masks'); mask_string = '1'; number_of_masks = data(index).nmbr;
    for n = 2:number_of_masks; mask_string = [mask_string '|' num2str(n)]; end
    uicontrol('units','normalized','Position',[gx+0.12,gy,0.05,0.025],'FontName',font,'FontSize',fontsize,'Style','popup','String',mask_string,'HorizontalAlignment','center','Tag','disp_mask_number','value',status_flags.display.mask.number,'CallBack','main_callbacks(''mask_number'');','visible','off');
    %Calibrate On/Off
    gy = gy-0.03;
    uicontrol('units','normalized','Position',[gx,gy,0.03,0.025],'tooltip','Calibrate Data : See Calibration Settings','FontName',font,'FontSize',fontsize,'Style','checkbox','Tag','calibrate_check','BackgroundColor', background_color, 'ForegroundColor', [1,1,1],'value',status_flags.calibration.calibrate.check,'CallBack','main_callbacks(''calibrate_check'');');
    uicontrol('units','normalized','Position',[gx+0.035,gy,0.14,0.025],'style','text','style','text','string',' : Calibrate','HorizontalAlignment','left','BackgroundColor', background_color, 'ForegroundColor', [1,1,1],'FontName',font,'FontSize',fontsize);
    %D22 Tube Calibration On/Off
    gy = gy-0.03;
    if strcmp(inst,'d22_rawdata'); status = 'on'; else status = 'off'; end
    uicontrol('units','normalized','Position',[gx,gy,0.03,0.025],'tooltip','D22 Detector Tube Calibration','FontName',font,'FontSize',fontsize,'Style','checkbox','Tag','d22_soft_det_cal_check','BackgroundColor', background_color, 'ForegroundColor', [1,1,1],'value',status_flags.calibration.d22_soft_det_cal,'CallBack','main_callbacks(''d22_soft_det_cal_check'');','visible',status);
    uicontrol('units','normalized','Position',[gx+0.035,gy,0.14,0.025],'style','text','style','text','string',' : D22 Tube Cal','HorizontalAlignment','left','Tag','d22_soft_det_cal_text','BackgroundColor', background_color, 'ForegroundColor', [1,1,1],'FontName',font,'FontSize',fontsize,'visible',status);

    
    
    %***** Displayed Color Control *****
    gx = 0.82; gy = 0.89; %Group Postions (normalized);
    %Color Top slider
    uicontrol('units','normalized','Position',[gx,gy+0.03,0.15,0.025],'FontName',font,'FontSize',fontsize,'Style','text','String','Stretch Top:','BackgroundColor', background_color, 'ForegroundColor', [1 1 1],'HorizontalAlignment','center');
    uicontrol('units','normalized','Position',[gx,gy,0.15,0.025],'ToolTip','Stretch Colour Top','FontName',font,'FontSize',fontsize,'Style','slider','Tag','colortop_slider', 'CallBack','main_callbacks(''stretch_top'');','Value',status_flags.color.top);
    %Color Bottom slider
    uicontrol('units','normalized','Position',[gx,gy+0.03-0.06,0.15,0.025],'FontName',font,'FontSize',fontsize,'Style','text','String','Stretch Bottom:','BackgroundColor', background_color, 'ForegroundColor', [1 1 1],'HorizontalAlignment','center');
    uicontrol('units','normalized','Position',[gx,gy-0.06,0.15,0.025],'ToolTip','Stretch Colour Bottom','FontName',font,'FontSize',fontsize,'Style','slider','Tag','colorbottom_slider','CallBack','main_callbacks(''stretch_bottom'');','Value',status_flags.color.bottom);
    %Color Gamma slider
    uicontrol('units','normalized','Position',[gx,gy+0.03-0.12,0.15,0.025],'FontName',font,'FontSize',fontsize,'Style','text','String','Gamma:','BackgroundColor', background_color, 'ForegroundColor', [1 1 1],'HorizontalAlignment','center');
    uicontrol('units','normalized','Position',[gx,gy-0.12,0.15,0.025],'ToolTip','Stretch Colour Gamma','FontName',font,'FontSize',fontsize,'Style','slider','Tag','colorgamma_slider','CallBack','main_callbacks(''slide_gamma'');','Value',status_flags.color.gamma);
    %Color Reset
    uicontrol('units','normalized','Position',[gx,gy-0.15,0.15,0.025],'ToolTip','Reset Colour Palette','FontName',font,'FontSize',fontsize,'Style','pushbutton','String','Reset Colour','HorizontalAlignment','center','Tag','color_reset','Visible','on','CallBack','palette_mod(''reset'');');
    
    %***** Display Beam Centre *****
    gx = 0.57; gy = 0.16; %Group Postions (normalized);
    uicontrol('units','normalized','Position',[gx+0.07,gy,0.2,0.02],'FontName',font,'FontSize',fontsize,'HorizontalAlignment','left','Style','text','String','Beam Centre:','BackgroundColor', background_color, 'ForegroundColor', [1 1 1]);
    beam_centre_string = '1'; number_of_beam_centres = data(1).nmbr; %i.e. number of worksheets in the foreground
    for n = 2:number_of_beam_centres; beam_centre_string = [beam_centre_string '|' num2str(n)]; end
    %Beam Centre Number Selector
    uicontrol('units','normalized','Position',[gx,gy-0.06,0.06,0.03],'FontName',font,'FontSize',fontsize,'Style','popup','String',beam_centre_string,'HorizontalAlignment','left','Tag','beam_centre_number','Visible','off','CallBack','main_callbacks(''cm_number'')');
    %Bx
    uicontrol('units','normalized','Position',[gx+0.07,gy-0.03,0.08,0.03],'FontName',font,'FontSize',fontsize,'HorizontalAlignment','center','Style','text','String','c_x:','BackgroundColor', background_color, 'ForegroundColor', [1 1 1]);
    uicontrol('units','normalized','Position',[gx+0.07,gy-0.06,0.08,0.03],'tooltip','Beam Centre x-Value','FontName',font,'FontSize',fontsize,'Style','edit','String','x','HorizontalAlignment','right','Tag','beam_centrex','Visible','on','CallBack','main_callbacks(''cm_x'');');
    %By
    uicontrol('units','normalized','Position',[gx+0.155,gy-0.03,0.08,0.03],'FontName',font,'FontSize',fontsize,'HorizontalAlignment','center','Style','text','String','c_y:','BackgroundColor', background_color, 'ForegroundColor', [1 1 1]);
    uicontrol('units','normalized','Position',[gx+0.155,gy-0.06,0.08,0.03],'tooltip','Beam Centre y-Value','FontName',font,'FontSize',fontsize,'Style','edit','String','x','HorizontalAlignment','right','Tag','beam_centrey','Visible','on','CallBack','main_callbacks(''cm_y'');');
    %B_theta or gamma as Giovanna call it
    if strcmp(inst,'d16') | strcmp(inst,'d16_128'); status = 'on'; else status = 'off'; end
    uicontrol('units','normalized','Position',[gx+0.24,gy-0.03,0.08,0.03],'FontName',font,'FontSize',fontsize,'HorizontalAlignment','center','Style','text','String','c_Ø:','BackgroundColor', background_color, 'ForegroundColor', [1 1 1],'tag','beam_centre_angle_text','visible',status);
    uicontrol('units','normalized','Position',[gx+0.24,gy-0.06,0.08,0.03],'tooltip','Beam Centre Ø-Value','FontName',font,'FontSize',fontsize,'Style','edit','String','x','HorizontalAlignment','right','Tag','beam_centre_angle','Visible','on','CallBack','main_callbacks(''cm_theta'');','visible',status);
    %Centre of Mass Lock Value
    uicontrol('units','normalized','Position',[gx+0.33,gy-0.02,0.045,0.02],'FontName',font,'FontSize',fontsize,'HorizontalAlignment','right','Style','text','String','Lock:','tag','cm_lock_text','BackgroundColor', background_color, 'ForegroundColor', [1 1 1]);
    uicontrol('units','normalized','Position',[gx+0.34,gy-0.055,0.03,0.025],'FontName',font,'FontSize',fontsize,'tooltip','Lock Beam Centre at Current Value for all Worksheets','Style','checkbox','Tag','cm_lock','BackgroundColor', background_color, 'ForegroundColor', [1,1,1],'value',status_flags.beamcentre.cm_lock,'callback','main_callbacks(''cm_lock'');');
    %Centre of Mass Button
    uicontrol('units','normalized','Position',[gx+0.07,gy-0.09,0.12,0.025],'ToolTip',['Find Centre of Mass of Displayed Area'],'FontName',font,'FontSize',fontsize,'Style','pushbutton','String','Centre Calc','HorizontalAlignment','center','Tag','centremassbutton','Visible','on','CallBack','centre_of_mass;update_display');
    
    %***** Transmission Value *****
    gx = 0.57; gy = 0.35; %Group Postions (normalized);
    transmission_string = '1'; number_of_transmissions = data(1).nmbr; %i.e. number of worksheets in the foreground
    for n = 2:number_of_transmissions; transmission_string = [transmission_string '|' num2str(n)]; end
    %Ts
    uicontrol('units','normalized','Position',[gx+0.07,gy,0.06,0.02],'FontName',font,'FontSize',fontsize,'HorizontalAlignment','center','Style','text','String','T_s:','BackgroundColor', background_color, 'ForegroundColor', [1 1 1]);
    uicontrol('units','normalized','Position',[gx,gy-0.04,0.06,0.03],'FontName',font,'FontSize',fontsize,'Style','popup','String',transmission_string,'HorizontalAlignment','left','Tag','ts_number','Visible','off','CallBack','main_callbacks(''ts_number'')');
    uicontrol('units','normalized','Position',[gx+0.07,gy-0.04,0.08,0.03],'tooltip',['Sample-only Transmission Value, Ts:' char(13) char(10) 'i.e. Compare Through Beam for Sample+Holder vs. Holder'],'FontName',font,'FontSize',fontsize,'Style','edit','String','x','HorizontalAlignment','right','Tag','ts_indicator','Visible','on','callback','main_callbacks(''ts'');');
    %Te
    uicontrol('units','normalized','Position',[gx+0.07,gy-0.07,0.06,0.02],'FontName',font,'FontSize',fontsize,'HorizontalAlignment','center','Style','text','String','T_e:','BackgroundColor', background_color, 'ForegroundColor', [1 1 1]);
    uicontrol('units','normalized','Position',[gx,gy-0.11,0.06,0.03],'FontName',font,'FontSize',fontsize,'Style','popup','String',transmission_string,'HorizontalAlignment','left','Tag','te_number','Visible','off','CallBack','main_callbacks(''te_number'')');
    uicontrol('units','normalized','Position',[gx+0.07,gy-0.11,0.08,0.03],'tooltip',['Sample Holder Transmission Value, Te:' char(13) char(10) 'i.e. Compare Through Beam for Sample Holder vs. Direct Beam'],'FontName',font,'FontSize',fontsize,'Style','edit','String','x','HorizontalAlignment','right','Tag','te_indicator','Visible','on','callback','main_callbacks(''te'');');
    %Ts - Single Value
    uicontrol('units','normalized','Position',[gx+0.155,gy,0.06,0.02],'FontName',font,'FontSize',fontsize,'HorizontalAlignment','right','tag','ts_lock_text','Style','text','String','Lock:','BackgroundColor', background_color, 'ForegroundColor', [1 1 1]);
    uicontrol('units','normalized','Position',[gx+0.17,gy-0.035,0.03,0.025],'FontName',font,'FontSize',fontsize,'Style','checkbox','Tag','ts_lock','BackgroundColor', background_color, 'ForegroundColor', [1,1,1],'value',0,'ToolTipString','Lock Transmission (Ts) at Current Value for all Worksheets','callback','main_callbacks(''ts_single'');');
    uicontrol('units','normalized','Position',[gx+0.155,gy-0.07,0.06,0.02],'FontName',font,'FontSize',fontsize,'HorizontalAlignment','right','tag','te_lock_text','Style','text','String','Lock:','BackgroundColor', background_color, 'ForegroundColor', [1 1 1]);
    uicontrol('units','normalized','Position',[gx+0.17,gy-0.105,0.03,0.025],'FontName',font,'FontSize',fontsize,'Style','checkbox','Tag','te_lock','BackgroundColor', background_color, 'ForegroundColor', [1,1,1],'value',0,'ToolTipString','Lock Transmission (Te) at Current Value for all Worksheets','callback','main_callbacks(''te_single'');');
    
    %Calculate Transmission Ts Button
    uicontrol('units','normalized','Position',[gx+0.21,gy-0.04,0.085,0.025],'ToolTip',['Calculate Transmission Ts' char(13) 'of Displayed Area'],'FontName',font,'FontSize',fontsize,'Style','pushbutton','String','Ts Calc','HorizontalAlignment','center','Tag','ts_calc_button','Visible','off','CallBack','transmission_calc(''ts'')');
    %Calculate Transmission Ts Button
    uicontrol('units','normalized','Position',[gx+0.21,gy-0.105,0.085,0.025],'ToolTip',['Calculate Transmission Ts' char(13) 'of Displayed Area'],'FontName',font,'FontSize',fontsize,'Style','pushbutton','String','Te Calc','HorizontalAlignment','center','Tag','te_calc_button','Visible','off','CallBack','transmission_calc(''te'')');
    
    %***** Norm Indicator *****
    color = [1 1 1]; backcolor = [0.8 0 0];
    uicontrol('units','normalized','Position',[0.75 0.96 0.25 0.02],'FontName',font,'FontSize',fontsize,'FontWeight','bold','Style','text','HorizontalAlignment','center',...
        'String','xxxxxxx','BackgroundColor',backcolor,'ForegroundColor', color,'tag','norm_indicator');
    
    %***** Display Instrument ******
    uicontrol('units','normalized','Position',[0.75,0.98,0.25,0.02],'FontName',font,'FontSize',fontsize,'FontWeight','bold','HorizontalAlignment','center','Style','text',...
        'String',inst,'tag','inst_string','BackgroundColor', [0.1 0.5 0.3] ,'ForegroundColor', [1 1 1]);
    
    %***** Live Coords and Pixel Value Indicator *****
    uicontrol('units','normalized','Position',[0,0.98,0.2,0.02],'FontName',font,'FontSize',fontsize*0.9,'Style','text','HorizontalAlignment','center',...
        'String','','BackgroundColor',[0.1 0.4 0.4],'ForegroundColor',[1 1 1],'tag','live_coords');
  
    %***** Credits ******
    temp = clock;
    uicontrol('units','normalized','Position',[0.5,0.01,0.5,0.02],'FontName',font,'FontSize',fontsize,'HorizontalAlignment','right','Style','text',...
        'String',[chuck_program_name ' V' chuck_version ' (c)' num2str(temp(1)) '.  e-mail: dewhurst@ill.fr  '],'BackgroundColor', background_color, 'ForegroundColor', [1 1 1]);
    
    %***** Build Data Selector Menus Properly ******
    selector_build;
    selector_build_values;

    %***** Build the default startup main display *****
    %Create New Axis
    plot_handle = pcolor(zeros(inst_params.det_size)); %Create new plot with pixel mapping
    %plot_handle = imagesc(zeros(inst_params.det_size)); %Create new plot with pixel mapping

    set(plot_handle,'tag','pcolor_object'); %Need access to the low level Pcolor later for scaling q-axes
    set(gca,'Tag','main_graph', 'DataAspectRatioMode','auto', 'PlotBoxAspectRatio',[inst_params.det_size(2), (inst_params.det_size(1)/inst_params.pixel_anisotropy), 1],'FontName',font,'FontSize',fontsize,'Layer','Top','TickDir','out');
    
    %***** Position axis and place color_bar *****
    update_colorbar('main');
    
    %***** Update Pallette *****
    palette_mod;
    
    %***** Update image render *****
    update_image_render;
   
    %***** Mac Dependent Stuff *****
    %Mac's have the menu bar across the top.  Adjust figure position to compensate for this.
    if strcmpi(computer,'mac');
    set(figure_handle,'position',[0.0578  0.075  0.5203/screen  0.7500*screen]); %Mac OSX quick fix
    end
end

%Create an empty 'last saved' so it is not empty the first time though.
last_saved = struct('inst',inst,'inst_params',inst_params,'status_flags',status_flags,'data',data,'data_dir',data_dir,'working_data_dir',working_data_dir,'project_dir',project_dir);


%Set the live_coords callback
set(figure_handle,'windowbuttonmotionfcn','live_coords');