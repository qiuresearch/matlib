function varargout = xsqfit(varargin)
%XSQFIT M-file for xsqfit.fig
%      XSQFIT, by itself, creates a new XSQFIT or raises the existing
%      singleton*.
%
%      H = XSQFIT returns the handle to a new XSQFIT or the handle to
%      the existing singleton*.
%
%      XSQFIT('Property','Value',...) creates a new XSQFIT using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to xsqfit_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      XSQFIT('CALLBACK') and XSQFIT('CALLBACK',hObject,...) call the
%      local function named CALLBACK in XSQFIT.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help xsqfit

% Last Modified by GUIDE v2.5 25-Oct-2004 10:13:47

% $Id: xsqfit.m,v 1.5 2013/08/17 12:27:32 xqiu Exp $

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @xsqfit_OpeningFcn, ...
                   'gui_OutputFcn',  @xsqfit_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

%  if nargout
%     [varargout{1:nargout}] = openfig(gui_State.gui_Name, 'reuse', 'auto');
%  else
%     openfig([gui_State.gui_Name '.fig'], 'reuse', 'auto')
%  end
%  

if nargout
   [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
   gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before xsqfit is made visible.
function xsqfit_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for xsqfit
handles.output = hObject;

% ------ added by xq
% Add all the GUI handles to the handles.GUI structure
% with the tag as the name

handles.GUI = handles;
handles.GUI.top = hObject;
% --- end of addition

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes xsqfit wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = xsqfit_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure
varargout{1} = handles.output;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Event handler of the DATA GUI section
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = dataevents_Callback(hObject, eventdata, handles)
%   hObject -- the handle to the object where the event originated
%   eventdata -- reserved by MATLAB for future used
%   handles -- a variable is passed around all events callback
%              routines. *** NEED to save it with guidata()

set(handles.GUI.top, 'Pointer', 'Watch')

sGUIjobs = {};

tagname = get(hObject, 'Tag');
switch tagname
   case 'readsetupbutton'    % select and read the setup file
      % another solution is to try: (unsetenv LANG; matlab)
      setappdata(0,'UseNativeSystemDialogs',0)
      setupfile = uigetfile('*.txt;*.hst', 'Pick the setup file -->', ...
                            'sqfit_setup.txt');
      setappdata(0,'UseNativeSystemDialogs',1)
      if ischar(setupfile)
         handles.setupfile = setupfile;
         disp(['Reading setup file: ' setupfile ' ...'])
         handles.sqfit = sqfit_readsetup(handles.setupfile);
         sGUIjobs = {sGUIjobs{:}, 'update_data', 1};
      end
   case 'datalistbox'   % change of selection
      index = get(hObject, 'Value');
      [handles.sqfit.select] = deal(0);
      [handles.sqfit(index).select] = deal(1);
      sGUIjobs = {sGUIjobs{:}, 'update_all', 1};
   case 'xaxispopupmenu'
      xaxisstr = get(handles.GUI.xaxispopupmenu, 'String');
      xaxisstr = xaxisstr{get(handles.GUI.xaxispopupmenu, 'Value')};
      if strmatch(xaxisstr, 'num', 'exact')
         x = num2cell([handles.sqfit.(xaxisstr)]);
      else
         x = num2cell(getfield_cellstru({handles.sqfit.msa},xaxisstr));
      end
      [handles.sqfit.x] = deal(x{:});
      sGUIjobs = {sGUIjobs{:}, 'update_data', 1};
   otherwise
      disp('Not supported yet!')
end
guidata(hObject, handles);
guievents_xsqfit(handles, sGUIjobs); % update all GUI fields
set(handles.GUI.top, 'Pointer', 'Arrow')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Event handler of the GETSQ GUI section
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = getsqevents_Callback(hObject, eventdata, ...
                                                   handles)
GUI = handles.GUI;
set(GUI.top, 'Pointer', 'Watch')
index = get(GUI.datalistbox, 'Value');
update_calc = 1; % whether need to recalcuate the S(Q)

tagname = get(hObject, 'Tag');
switch tagname
   case 'q_minedit'   % change the Qmin
      [handles.sqfit(index).q_min] = deal(str2num(get(hObject, 'String')));
   case 'q_maxedit'
      [handles.sqfit(index).q_max] = deal(str2num(get(hObject, 'String')));
   case 'ff_usepopupmenu'
      [handles.sqfit(index).ff_use] = deal(get(hObject, 'Value'));
   case 'hqratioedit'
      [handles.sqfit(index).hqratio] = deal(str2num(get(hObject, 'String')));
   case 'hqmethodpopupmenu'
      [handles.sqfit(index).hqmethod] = deal(get(hObject, 'Value'));
   case 'auto_rescalecheckbox'
      [handles.sqfit(index).auto_rescale] = deal(get(hObject, 'Value'));
      update_calc = 0;
   case 'getall_sqcheckbox'
      [handles.sqfit(index).getall_sq] = deal(get(hObject, 'Value'));
      update_calc = 0;
   otherwise
      update_calc = 0;
end

if (update_calc == 1) % update calculation anyway
   actionevents_Callback(GUI.getsqbutton, [], handles);
else
   guidata(hObject, handles);
end
set(GUI.top, 'Pointer', 'Arrow')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Event handler of the I(Q) correction GUI section
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = iqcorrevents_Callback(hObject, eventdata, handles)

GUI = handles.GUI;
set(GUI.top, 'Pointer', 'Watch')
index = get(GUI.datalistbox, 'Value');
update_calc = 0; % whether need to recalcuate the S(Q)

tagname = get(hObject, 'Tag');
switch tagname
   case 'smooth_widthedit'
      [handles.sqfit(index).smooth_width] = deal(str2num(get(hObject, 'String')));
      update_calc = 1;
   case 'smooth_degreeedit'
      [handles.sqfit(index).smooth_degree] = deal(str2num(get(hObject, 'String')));
      update_calc = 1;
   case 'offset_iqfitcheckbox'
      [handles.sqfit(index).offset_iq_fit] = deal(get(hObject, 'Value'));
   case 'offset_iqslider'
      offset_iq = get(hObject, 'Value');
      set(GUI.offset_iqedit, 'String', num2str(offset_iq));
      [handles.sqfit(index).offset_iq] = deal(offset_iq);
      update_calc = 1;
   case 'offset_iqedit'
      offset_iq = str2num(get(hObject, 'String'));
      set(GUI.offset_iqslider, 'Value', offset_iq)
      [handles.sqfit(index).offset_iq] = deal(offset_iq);
      update_calc = 1;      
   case 'offset_iqfitlimittoggle'
      [handles.sqfit(index).offset_iq_limit] = deal(get(hObject, 'Value'));
   case 'offset_iqlowerlimitedit'
      [handles.sqfit(index).offset_iq_ll] = deal(str2num(get(hObject, 'String')));
      set(GUI.offset_iqslider, 'Min', str2num(get(hObject, 'String')));
   case 'offset_iqupperlimitedit'
      [handles.sqfit(index).offset_iq_ul] = deal(str2num(get(hObject, 'String')));
      set(GUI.offset_iqslider, 'Max', str2num(get(hObject, 'String')));
   case 'scale_iqfitcheckbox'
      [handles.sqfit(index).scale_iq_fit] = deal(get(hObject, 'Value'));
   case 'scale_iqslider'
      scale_iq = get(hObject, 'Value');
      set(GUI.scale_iqedit, 'String', num2str(scale_iq));
      [handles.sqfit(index).scale_iq] = deal(scale_iq);
      update_calc = 1;
   case 'scale_iqedit'
      scale_iq = str2num(get(hObject, 'String'));
      set(GUI.scale_iqslider, 'Value', scale_iq)
      [handles.sqfit(index).scale_iq] = deal(scale_iq);
      update_calc = 1;      
   case 'scale_iqfitlimittoggle'
      [handles.sqfit(index).scale_iq_limit] = deal(get(hObject, 'Value'));
   case 'scale_iqlowerlimitedit'
      [handles.sqfit(index).scale_iq_ll] = deal(str2num(get(hObject, 'String')));
      set(GUI.scale_iqslider, 'Min', str2num(get(hObject, 'String')));
   case 'scale_iqupperlimitedit'
      [handles.sqfit(index).scale_iq_ul] = deal(str2num(get(hObject, 'String')));
      set(GUI.scale_iqslider, 'Max', str2num(get(hObject, 'String')));
   case 'radius_cylfitcheckbox'
      [handles.sqfit(index).radius_cyl_fit] = deal(get(hObject, 'Value'));
   case 'radius_cylslider'
      radius_cyl = get(hObject, 'Value');
      set(GUI.radius_cyledit, 'String', num2str(radius_cyl));
      [handles.sqfit(index).radius_cyl] = deal(radius_cyl);
      [handles.sqfit(index).calc_ff_cyl] = deal(1);
      update_calc = 1;
   case 'radius_cyledit'
      radius_cyl = str2num(get(hObject, 'String'));
      set(GUI.radius_cylslider, 'Value', radius_cyl)
      [handles.sqfit(index).radius_cyl] = deal(radius_cyl);
      [handles.sqfit(index).calc_ff_cyl] = deal(1);
      update_calc = 1;      
   case 'radius_cylfitlimittoggle'
      [handles.sqfit(index).radius_cyl_limit] = deal(get(hObject, 'Value'));
   case 'radius_cyllowerlimitedit'
      [handles.sqfit(index).radius_cyl_ll] = deal(str2num(get(hObject, 'String')));
      set(GUI.radius_cylslider, 'Min', str2num(get(hObject, 'String')));
   case 'radius_cylupperlimitedit'
      [handles.sqfit(index).radius_cyl_ul] = deal(str2num(get(hObject, 'String')));
      set(GUI.radius_iqslider, 'Max', str2num(get(hObject, 'String')));
   case 'height_cylfitcheckbox'
      [handles.sqfit(index).height_cyl_fit] = deal(get(hObject, 'Value'));
   case 'height_cylslider'
      height_cyl = get(hObject, 'Value');
      set(GUI.height_cyledit, 'String', num2str(height_cyl));
      [handles.sqfit(index).height_cyl] = deal(height_cyl);
      [handles.sqfit(index).calc_ff_cyl] = deal(1);
      update_calc = 1;
   case 'height_cyledit'
      height_cyl = str2num(get(hObject, 'String'));
      set(GUI.height_cylslider, 'Value', height_cyl);
      [handles.sqfit(index).height_cyl] = deal(height_cyl);
      [handles.sqfit(index).calc_ff_cyl] = deal(1);
      update_calc = 1;      
   case 'height_cylfitlimittoggle'
      [handles.sqfit(index).height_cyl_limit] = deal(get(hObject, 'Value'));
   case 'height_cyllowerlimitedit'
      [handles.sqfit(index).height_cyl_ll] = deal(str2num(get(hObject, 'String')));
      set(GUI.height_cylslider, 'Min', str2num(get(hObject, 'String')));
   case 'height_cylupperlimitedit'
      [handles.sqfit(index).height_cyl_ul] = deal(str2num(get(hObject, 'String')));
      set(GUI.height_cylslider, 'Max', str2num(get(hObject, 'String')));
   case 'use_diameter_equivcheckbox'
      [handles.sqfit(index).use_diameter_equiv] = deal(get(hObject, 'Value'));
   otherwise
      update_calc = 0;
end
if (update_calc == 1)
   actionevents_Callback(GUI.getsqbutton, [], handles);
else
   guidata(hObject, handles);
end
set(GUI.top, 'Pointer', 'Arrow')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Event handler of the VISUAL GUI section
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = visualevents_Callback(hObject, eventdata, handles)
% just to update the plot
actionevents_Callback(handles.GUI.plotdatabutton, eventdata, handles);
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Event handler of the MSA MODEL GUI section
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = msaevents_Callback(hObject, eventdata, handles)

GUI = handles.GUI;
index = get(GUI.datalistbox, 'Value');
if isempty(index)
   return
end
set(GUI.top, 'Pointer', 'Watch')

update_calc = 0;
tagname = get(hObject, 'Tag');
switch tagname
   case 'msamethodpopupmenu'
      msamethod = get(hObject, 'Value');
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.method = msamethod;
      end
   case 'z_mfitcheckbox'
      z_m_fit = get(hObject, 'Value');
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.z_m_fit = z_m_fit;
      end
   case 'z_mslider'
      z_m = get(hObject, 'Value');
      set(GUI.z_medit, 'String', num2str(z_m));
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.z_m = z_m;
      end
      update_calc = 1;
   case 'z_medit'
      z_m = str2num(get(hObject, 'String'));
      set(GUI.z_mslider, 'Value', z_m)
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.z_m = z_m;
      end
      update_calc = 1;      
   case 'z_mfitlimittoggle'
      z_m_limit = get(hObject, 'Value');
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.z_m_limit = z_m_limit;
      end
   case 'z_mlowerlimitedit'
      z_m_ll = str2num(get(hObject, 'String'));
      set(GUI.z_mslider, 'Min', z_m_ll);
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.z_m_ll = z_m_ll;
      end
   case 'z_mupperlimitedit'
      z_m_ul = str2num(get(hObject, 'String'));
      set(GUI.z_mslider, 'Max', z_m_ul);
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.z_m_ul = z_m_ul;
      end
   case 'Ifitcheckbox'
      I_fit = get(hObject, 'Value');
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.I_fit = I_fit;
      end
   case 'Islider'
      I = get(hObject, 'Value');
      set(GUI.Iedit, 'String', num2str(I));
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.I = I;
      end
      update_calc = 1;      
   case 'Iedit'
      I = str2num(get(hObject, 'String'));
      set(GUI.Islider, 'Value', I)
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.I = I;
      end
      update_calc = 1;      
   case 'Ifitlimittoggle'
      I_limit = get(hObject, 'Value');
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.I_limit = I_limit;
      end
   case 'Ilowerlimitedit'
      I_ll = str2num(get(hObject, 'String'));
      set(GUI.Islider, 'Min', I_ll);
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.I_ll = I_ll;
      end
   case 'Iupperlimitedit'
      I_ul = str2num(get(hObject, 'String'));
      set(GUI.Islider, 'Max', I_ul);
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.I_ul = I_ul;
      end
   case 'sigmafitcheckbox'
      sigma_fit = get(hObject, 'Value');
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.sigma_fit = sigma_fit;
      end
   case 'sigmaslider'
      sigma = get(hObject, 'Value');
      set(GUI.sigmaedit, 'String', num2str(sigma));
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.sigma = sigma;
      end
      update_calc = 1;      
   case 'sigmaedit'
      sigma = str2num(get(hObject, 'String'));
      set(GUI.sigmaslider, 'Value', sigma)
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.sigma = sigma;
      end
      update_calc = 1;      
   case 'sigmafitlimittoggle'
      sigma_limit = get(hObject, 'Value');
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.sigma_limit = sigma_limit;
      end
   case 'sigmalowerlimitedit'
      sigma_ll = str2num(get(hObject, 'String'));
      set(GUI.sigmaslider, 'Min', sigma_ll);
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.sigma_ll = sigma_ll;
      end
   case 'sigmaupperlimitedit'
      sigma_ul = str2num(get(hObject, 'String'));
      set(GUI.sigmaslider, 'Max', sigma_ul);
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.sigma_ul = sigma_ul;
      end
   case 'nfitcheckbox'
      n_fit = get(hObject, 'Value');
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.n_fit = n_fit;
      end
   case 'nslider'
      n = get(hObject, 'Value');
      set(GUI.nedit, 'String', num2str(n));
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.n = n;
      end
      update_calc = 1;      
   case 'nedit'
      n = str2num(get(hObject, 'String'));
      set(GUI.nslider, 'Value', n)
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.n = n;
      end
      update_calc = 1;      
   case 'nfitlimittoggle'
      n_limit = get(hObject, 'Value');
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.n_limit = n_limit;
      end
   case 'nlowerlimitedit'
      n_ll = str2num(get(hObject, 'String'));
      set(GUI.nslider, 'Min', n_ll);
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.n_ll = n_ll;
      end
   case 'nupperlimitedit'
      n_ul = str2num(get(hObject, 'String'));
      set(GUI.nslider, 'Max', n_ul);
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.n_ul = n_ul;
      end
   case 'scalefitcheckbox'
      scale_fit = get(hObject, 'Value');
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.scale_fit = scale_fit;
      end
   case 'scaleslider'
      scale = get(hObject, 'Value');
      set(GUI.scaleedit, 'String', num2str(scale));
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.scale = scale;
      end
      update_calc = 1;
   case 'scaleedit'
      scale = str2num(get(hObject, 'String'));
      set(GUI.scaleslider, 'Value', scale)
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.scale = scale;
      end
      update_calc = 1;      
   case 'scalefitlimittoggle'
      scale_limit = get(hObject, 'Value');
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.scale_limit = scale_limit;
      end
   case 'scalelowerlimitedit'
      scale_ll = str2num(get(hObject, 'String'));
      set(GUI.scaleslider, 'Min', scale_ll);
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.scale_ll = scale_ll;
      end
   case 'scaleupperlimitedit'
      scale_ul = str2num(get(hObject, 'String'));
      set(GUI.scaleslider, 'Max', scale_ul);
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.scale_ul = scale_ul;
      end
   case 'z_m2fitcheckbox'
      z_m2_fit = get(hObject, 'Value');
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.z_m2_fit = z_m2_fit;
      end
   case 'z_m2slider'
      z_m2 = get(hObject, 'Value');
      set(GUI.z_m2edit, 'String', num2str(z_m2));
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.z_m2 = z_m2;
      end
      update_calc = 1;
   case 'z_m2edit'
      z_m2 = str2num(get(hObject, 'String'));
      set(GUI.z_m2slider, 'Value', z_m2)
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.z_m2 = z_m2;
      end
      update_calc = 1;      
   case 'z_m2fitlimittoggle'
      z_m2_limit = get(hObject, 'Value');
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.z_m2_limit = z_m2_limit;
      end
   case 'z_m2lowerlimitedit'
      z_m2_ll = str2num(get(hObject, 'String'));
      set(GUI.z_m2slider, 'Min', z_m2_ll);
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.z_m2_ll = z_m2_ll;
      end
   case 'z_m2upperlimitedit'
      z_m2_ul = str2num(get(hObject, 'String'));
      set(GUI.z_m2slider, 'Max', z_m2_ul);
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.z_m2_ul = z_m2_ul;
      end
   case 'I2fitcheckbox'
      I2_fit = get(hObject, 'Value');
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.I2_fit = I2_fit;
      end
   case 'I2slider'
      I2 = get(hObject, 'Value');
      set(GUI.I2edit, 'String', num2str(I2));
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.I2 = I2;
      end
      update_calc = 1;
   case 'I2edit'
      I2 = str2num(get(hObject, 'String'));
      set(GUI.I2slider, 'Value', I2)
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.I2 = I2;
      end
      update_calc = 1;      
   case 'I2fitlimittoggle'
      I2_limit = get(hObject, 'Value');
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.I2_limit = I2_limit;
      end
   case 'I2lowerlimitedit'
      I2_ll = str2num(get(hObject, 'String'));
      set(GUI.I2slider, 'Min', I2_ll);
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.I2_ll = I2_ll;
      end
   case 'I2upperlimitedit'
      I2_ul = str2num(get(hObject, 'String'));
      set(GUI.I2slider, 'Max', I2_ul);
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.I2_ul = I2_ul;
      end
   case 'temperatureedit'
      T = str2num(get(hObject, 'String'));
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.T = T;
      end
      update_calc = 1;      
   case 'epsilonedit'
      epsilon = str2num(get(hObject, 'String'));
      for isel = 1:length(index)
         handles.sqfit(index(isel)).msa.epsilon = epsilon;
      end
      update_calc = 1;
   otherwise
      update_calc = 0;
      disp('Not supported yet!')
end
if (update_calc == 1)
   actionevents_Callback(GUI.calciqbutton, [], handles);
else
   guidata(hObject, handles);
end
set(GUI.top, 'Pointer', 'Arrow')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Event handler of the FITOPTS GUI section
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = fitoptevents_Callback(hObject, eventdata, handles)

GUI = handles.GUI;
set(GUI.top, 'Pointer', 'Watch')
index = get(GUI.datalistbox, 'Value');

tagname = get(hObject, 'Tag');
switch tagname
   case 'fitmethodpopupmenu'
      [handles.sqfit(index).fitmethod] = deal(get(hObject, 'Value'));
   case 'fitalgorithmpopupmenu'
      [handles.sqfit(index).fitalgorithm] = deal(get(hObject, 'Value'));
   case 'fitmaxiteredit'
      maxiter = str2num(get(hObject, 'String'));
      [handles.sqfit(index).fitmaxiter] = deal(maxiter);
   case 'fitmaxdiffedit'
      maxdiff = str2num(get(hObject, 'String'));
      [handles.sqfit(index).fitmaxdiff] = deal(maxdiff);
   case 'fitlm_lambdaedit'
      fitlm_lambda = str2num(get(hObject, 'String'));
      [handles.sqfit(index).fitlm_lambda] = deal(fitlm_lambda);
   otherwise
      disp('Not supported yet!');
end
guidata(hObject, handles);
set(GUI.top, 'Pointer', 'Arrow')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Event handler of the ACTION GUI section
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = actionevents_Callback(hObject, eventdata, handles)

GUI = handles.GUI;
set(GUI.top, 'Pointer', 'Watch')
update_axes = 0;  % this is only used when "fit msa", as the plot
                  % needs to be updated!

index = get(GUI.datalistbox, 'Value');

tagname = get(hObject, 'Tag');
switch tagname
   case 'plotdatabutton'
      plotoption = {};
      if get(GUI.plotiqrawcheckbox, 'Value')
         plotoption = {plotoption{:}, 'iq_raw'};
      end
      if get(GUI.plotiqcheckbox, 'Value')
         plotoption = {plotoption{:}, 'iq'};
      end
      if get(GUI.plotiqcalcheckbox, 'Value')
         plotoption = {plotoption{:}, 'iq_cal'};
      end
      if get(GUI.plotiqfitcheckbox, 'Value')
         plotoption = {plotoption{:}, 'iq_fit'};
      end
      if get(GUI.plotffcheckbox, 'Value')
         plotoption = {plotoption{:}, 'ff'};
      end
      if get(GUI.plotffallcheckbox, 'Value')
         plotoption = {plotoption{:}, 'ff_all'};
      end
      if get(GUI.plotsqcheckbox, 'Value')
         plotoption = {plotoption{:}, 'sq'};
      end
      if get(GUI.plotsqallcheckbox', 'Value')
         plotoption = {plotoption{:}, 'sq_all'};
      end
      if get(GUI.plotsqcalccheckbox, 'Value')
         plotoption = {plotoption{:}, 'sq_cal'};
      end
      if get(GUI.plotsqfitcheckbox, 'Value')
         plotoption = {plotoption{:}, 'sq_fit'};
      end
      if get(GUI.plotiqcorrcheckbox, 'Value')
         iiqcorr = get(GUI.plotiqcorrpopupmenu, 'Value');
         striqcorr = get(GUI.plotiqcorrpopupmenu, 'String');
         plotoption = {plotoption{:}, [striqcorr{iiqcorr}]};
      end
      if get(GUI.plotmsacheckbox, 'Value')
         imsa = get(GUI.plotmsapopupmenu, 'Value');
         strmsa = get(GUI.plotmsapopupmenu, 'String');
         plotoption = {plotoption{:}, ['msa-' strmsa{imsa}]};
      end
      
      axis(GUI.plotwinaxes);
      hold off
      sqfit_plot(handles.sqfit(index), plotoption, 'plot_legend', ...
                 get(GUI.plotlegendcheckbox, 'Value'), 'plot_text', ...
                 get(GUI.plottextcheckbox, 'Value'));
      ylabel('', 'rotation', 90.0);
      disp('Plot data ...')
   case 'dataprepbutton'
      disp(['Prepare data for data ' num2str(index) '...'])
      handles.sqfit(index) = sqfit_dataprep(handles.sqfit(index));
      update_axes =1;
   case 'getsqbutton'
      disp(['Get experimetal I(Q) & S(Q) for data ' num2str(index) '...'])
      handles.sqfit(index) = sqfit_getexpiqsq(handles.sqfit(index));
      guievents_xsqfit(handles, {'update_iqcorr', 1});
      update_axes = 1;
   case 'calciqbutton'
      disp(['Calculate MSA SQ & I(Q) for data ' num2str(index) '...'])
      handles.sqfit(index) = sqfit_calmsasqiq(handles.sqfit(index));
      update_axes = 1;
   case 'fitmsabutton'
      disp(['Fit MSA model for data ' num2str(index) '...'])
      handles.sqfit(index) = sqfit_msafit(handles.sqfit(index));
      guievents_xsqfit(handles, {'update_msa', 1, 'update_iqcorr', 1});
      update_axes = 1;
   case 'saveresultsbutton'
      sqfit_saveresults(handles.sqfit(index), 'sqfit_default', 'savefitpar',1);
      sqfit_2ndvirial(handles.sqfit(index));
   case 'saveplotbutton'  % save the current plot to an eps file
      setting_axes = get(GUI.plotwinaxes);
      % a) open a new figure with visible off
      hfigure = figure('visible', 'off');
      clf;
      % b) plot it again
      actionevents_Callback(GUI.plotdatabutton, [], handles);
      set(gca, 'xlim', setting_axes.XLim, 'ylim', setting_axes.YLim);
%      haxes = copyobj(GUI.plotwinaxes, hfigure);
%      set(haxes, 'OUTERPOSITION', [0.05,0.05,0.8,0.8], 'POSITION', ...
%                 [0.1,0.1,0.8,0.8]);
%      get(haxes)
   %   set(hfigure, 'Children', setting_axes);
      % c) save the plot
      savefile = get(GUI.saveplotfileedit, 'String');
      saveps(hfigure, savefile);
      % d) close the figure
      close(hfigure);
   otherwise
      disp('Not supported yet!')
end

if (update_axes == 1) &&  get(GUI.plotautoupdatecheckbox, 'Value')
   actionevents_Callback(GUI.plotdatabutton, [], handles);
else
   guidata(hObject, handles);
   set(GUI.top, 'Pointer', 'Arrow')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Interaction between the GUI and DATA
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = guievents_xsqfit(handles, options)

% 1) default is to do nothing

update_all = 0;     % to update the GUI with data (handles.sqfit)?
update_data = 0; 
update_getsq = 0;
update_iqcorr = 0;
update_axes = 0;
update_plot = 0; 
update_msa = 0;
update_fitopts = 0;

get_all = 0;        % to read the data information from GUI? (not
                    % used yet)!
get_data = 0;
get_getsq = 0;
get_axes =0;
get_plot = 0;
get_msa = 0;

% "options" should be a cell array of strings: {'update_all', 'update_axes'}
if (nargin > 1) 
   parse_varargin(options);
end

% 2) do the work

GUI = handles.GUI;
%  use the first selected only
index = get(GUI.datalistbox, 'Value');
if isempty(index) || (index(1) < 1) 
   index = 1;
else
   index = index(1);
end

if (update_all == 1) || (update_data == 1)  % update the DATA GUI
   set(GUI.setupfileedit, 'String', handles.setupfile);
   set(GUI.datalistbox, 'String', {handles.sqfit(:).legend});   
   set(GUI.datalistbox, 'Value', find([handles.sqfit(:).select]));
end


if (update_all == 1) || (update_getsq == 1) % update the GETSQ GUI
   set(GUI.q_minedit, 'String', num2str(handles.sqfit(index).q_min));
   set(GUI.q_maxedit, 'String', num2str(handles.sqfit(index).q_max));
   set(GUI.ff_usepopupmenu, 'Value', handles.sqfit(index).ff_use);
   set(GUI.hqratioedit, 'String', num2str(handles.sqfit(index).hqratio));
   set(GUI.hqmethodpopupmenu, 'Value', handles.sqfit(index).hqmethod);
   set(GUI.auto_rescalecheckbox, 'Value', handles.sqfit(index).auto_rescale);
   set(GUI.getall_sqcheckbox, 'Value', handles.sqfit(index).getall_sq);
end

if (update_all == 1) || (update_iqcorr == 1) % update the I(Q)
                                             % correction
   set(GUI.smooth_widthedit, 'String', handles.sqfit(index).smooth_width);
   set(GUI.smooth_degreeedit, 'String', handles.sqfit(index).smooth_degree);
   set(GUI.offset_iqfitcheckbox, 'Value', handles.sqfit(index).offset_iq_fit);
   set(GUI.offset_iqslider, 'Min', handles.sqfit(index).offset_iq_ll, 'Max', ...
                     handles.sqfit(index).offset_iq_ul, 'Value', ...
                     get_inrange(handles.sqfit(index).offset_iq, ...
                                 handles.sqfit(index).offset_iq_ll, ...
                                 handles.sqfit(index).offset_iq_ul));
   
   set(GUI.offset_iqedit, 'String', num2str(handles.sqfit(index).offset_iq));
   set(GUI.offset_iqfitlimittoggle, 'Value', handles.sqfit(index).offset_iq_limit);
   set(GUI.offset_iqlowerlimitedit, 'String', handles.sqfit(index).offset_iq_ll);
   set(GUI.offset_iqupperlimitedit, 'String', handles.sqfit(index).offset_iq_ul);

   
   set(GUI.scale_iqfitcheckbox, 'Value', handles.sqfit(index).scale_iq_fit);
   set(GUI.scale_iqslider, 'Min', handles.sqfit(index).scale_iq_ll, 'Max', ...
                     handles.sqfit(index).scale_iq_ul, 'Value', ...
                     get_inrange(handles.sqfit(index).scale_iq, ...
                                 handles.sqfit(index).scale_iq_ll, ...
                                 handles.sqfit(index).scale_iq_ul));
   
   set(GUI.scale_iqedit, 'String', num2str(handles.sqfit(index).scale_iq));
   set(GUI.scale_iqfitlimittoggle, 'Value', handles.sqfit(index).scale_iq_limit);
   set(GUI.scale_iqlowerlimitedit, 'String', handles.sqfit(index).scale_iq_ll);
   set(GUI.scale_iqupperlimitedit, 'String', handles.sqfit(index).scale_iq_ul);

      
   set(GUI.radius_cylfitcheckbox, 'Value', handles.sqfit(index).radius_cyl_fit);
   set(GUI.radius_cylslider, 'Min', handles.sqfit(index).radius_cyl_ll, 'Max', ...
                     handles.sqfit(index).radius_cyl_ul, 'Value', ...
                     get_inrange(handles.sqfit(index).radius_cyl, ...
                                 handles.sqfit(index).radius_cyl_ll, ...
                                 handles.sqfit(index).radius_cyl_ul));
   
   set(GUI.radius_cyledit, 'String', num2str(handles.sqfit(index).radius_cyl));
   set(GUI.radius_cylfitlimittoggle, 'Value', handles.sqfit(index).radius_cyl_limit);
   set(GUI.radius_cyllowerlimitedit, 'String', handles.sqfit(index).radius_cyl_ll);
   set(GUI.radius_cylupperlimitedit, 'String', handles.sqfit(index).radius_cyl_ul);

      
   set(GUI.height_cylfitcheckbox, 'Value', handles.sqfit(index).height_cyl_fit);
   set(GUI.height_cylslider, 'Min', handles.sqfit(index).height_cyl_ll, 'Max', ...
                     handles.sqfit(index).height_cyl_ul, 'Value', ...
                     get_inrange(handles.sqfit(index).height_cyl, ...
                                 handles.sqfit(index).height_cyl_ll, ...
                                 handles.sqfit(index).height_cyl_ul));
   
   set(GUI.height_cyledit, 'String', num2str(handles.sqfit(index).height_cyl));
   set(GUI.height_cylfitlimittoggle, 'Value', handles.sqfit(index).height_cyl_limit);
   set(GUI.height_cyllowerlimitedit, 'String', handles.sqfit(index).height_cyl_ll);
   set(GUI.height_cylupperlimitedit, 'String', handles.sqfit(index).height_cyl_ul);

   set(GUI.use_diameter_equivcheckbox, 'Value', handles.sqfit(index).use_diameter_equiv);
   set(GUI.diameter_equivtext, 'String', num2str(handles.sqfit(index).diameter_equiv));

end

if (update_all == 1) || (update_axes ==1) % update the PLOT
   actionevents_Callback(GUI.plotdatabutton, [], handles);
end

if (update_all == 1) || (update_msa == 1) % update the MSA model
   set(GUI.msamethodpopupmenu, 'Value', handles.sqfit(index).msa.method);
   set(GUI.temperatureedit, 'String', num2str(handles.sqfit(index).msa.T));
   set(GUI.epsilonedit, 'String', num2str(handles.sqfit(index).msa.epsilon));
   
   set(GUI.z_mfitcheckbox, 'Value', handles.sqfit(index).msa.z_m_fit);
   set(GUI.z_mslider, 'Min', handles.sqfit(index).msa.z_m_ll, 'Max', ...
                     handles.sqfit(index).msa.z_m_ul, 'Value', ...
                     get_inrange(handles.sqfit(index).msa.z_m, ...
                                 handles.sqfit(index).msa.z_m_ll, ...
                                 handles.sqfit(index).msa.z_m_ul));
   
   set(GUI.z_medit, 'String', num2str(handles.sqfit(index).msa.z_m));
   set(GUI.z_mfitlimittoggle, 'Value', handles.sqfit(index).msa.z_m_limit);
   set(GUI.z_mlowerlimitedit, 'String', handles.sqfit(index).msa.z_m_ll);
   set(GUI.z_mupperlimitedit, 'String', handles.sqfit(index).msa.z_m_ul);
   
   set(GUI.Ifitcheckbox, 'Value', handles.sqfit(index).msa.I_fit);
   set(GUI.Islider, 'Min', handles.sqfit(index).msa.I_ll, 'Max', ...
                     handles.sqfit(index).msa.I_ul, 'Value', ...
                     get_inrange(handles.sqfit(index).msa.I, ...
                                 handles.sqfit(index).msa.I_ll, ...
                                 handles.sqfit(index).msa.I_ul));

   set(GUI.Iedit, 'String', num2str(handles.sqfit(index).msa.I));
   set(GUI.Ifitlimittoggle, 'Value', handles.sqfit(index).msa.I_limit);
   set(GUI.Ilowerlimitedit, 'String', handles.sqfit(index).msa.I_ll);
   set(GUI.Iupperlimitedit, 'String', handles.sqfit(index).msa.I_ul);

   
   set(GUI.sigmafitcheckbox, 'Value', handles.sqfit(index).msa.sigma_fit);
   set(GUI.sigmaslider, 'Min', handles.sqfit(index).msa.sigma_ll, ...
                     'Max', handles.sqfit(index).msa.sigma_ul,'Value', ...
                     get_inrange(handles.sqfit(index).msa.sigma, ...
                                 handles.sqfit(index).msa.sigma_ll, ...
                                 handles.sqfit(index).msa.sigma_ul));
   
   set(GUI.sigmaedit, 'String', num2str(handles.sqfit(index).msa.sigma));
   set(GUI.sigmafitlimittoggle, 'Value', handles.sqfit(index).msa.sigma_limit);
   set(GUI.sigmalowerlimitedit, 'String', handles.sqfit(index).msa.sigma_ll);
   set(GUI.sigmaupperlimitedit, 'String', handles.sqfit(index).msa.sigma_ul);

   
   set(GUI.nfitcheckbox, 'Value', handles.sqfit(index).msa.n_fit);
   set(GUI.nslider, 'Min', handles.sqfit(index).msa.n_ll, 'Max', ...
                    handles.sqfit(index).msa.n_ul, 'Value', ...
                    get_inrange(handles.sqfit(index).msa.n, ...
                                handles.sqfit(index).msa.n_ll, ...
                                handles.sqfit(index).msa.n_ul));
   
      
   set(GUI.nedit, 'String', num2str(handles.sqfit(index).msa.n));
   set(GUI.nfitlimittoggle, 'Value', handles.sqfit(index).msa.n_limit);
   set(GUI.nlowerlimitedit, 'String', handles.sqfit(index).msa.n_ll);
   set(GUI.nupperlimitedit, 'String', handles.sqfit(index).msa.n_ul);

   set(GUI.scalefitcheckbox, 'Value', handles.sqfit(index).msa.scale_fit);
   set(GUI.scaleslider, 'Min', handles.sqfit(index).msa.scale_ll, 'Max', ...
                    handles.sqfit(index).msa.scale_ul, 'Value', ...
                    get_inrange(handles.sqfit(index).msa.scale, ...
                                handles.sqfit(index).msa.scale_ll, ...
                                handles.sqfit(index).msa.scale_ul));
   
      
   set(GUI.scaleedit, 'String', num2str(handles.sqfit(index).msa.scale));
   set(GUI.scalefitlimittoggle, 'Value', handles.sqfit(index).msa.scale_limit);
   set(GUI.scalelowerlimitedit, 'String', handles.sqfit(index).msa.scale_ll);
   set(GUI.scaleupperlimitedit, 'String', handles.sqfit(index).msa.scale_ul);

   set(GUI.z_m2fitcheckbox, 'Value', handles.sqfit(index).msa.z_m2_fit);
   set(GUI.z_m2slider, 'Min', handles.sqfit(index).msa.z_m2_ll, 'Max', ...
                    handles.sqfit(index).msa.z_m2_ul, 'Value', ...
                    get_inrange(handles.sqfit(index).msa.z_m2, ...
                                handles.sqfit(index).msa.z_m2_ll, ...
                                handles.sqfit(index).msa.z_m2_ul));
   
      
   set(GUI.z_m2edit, 'String', num2str(handles.sqfit(index).msa.z_m2));
   set(GUI.z_m2fitlimittoggle, 'Value', handles.sqfit(index).msa.z_m2_limit);
   set(GUI.z_m2lowerlimitedit, 'String', handles.sqfit(index).msa.z_m2_ll);
   set(GUI.z_m2upperlimitedit, 'String', handles.sqfit(index).msa.z_m2_ul);

   set(GUI.I2fitcheckbox, 'Value', handles.sqfit(index).msa.I2_fit);
   set(GUI.I2slider, 'Min', handles.sqfit(index).msa.I2_ll, 'Max', ...
                    handles.sqfit(index).msa.I2_ul, 'Value', ...
                    get_inrange(handles.sqfit(index).msa.I2, ...
                                handles.sqfit(index).msa.I2_ll, ...
                                handles.sqfit(index).msa.I2_ul));
   
      
   set(GUI.I2edit, 'String', num2str(handles.sqfit(index).msa.I2));
   set(GUI.I2fitlimittoggle, 'Value', handles.sqfit(index).msa.I2_limit);
   set(GUI.I2lowerlimitedit, 'String', handles.sqfit(index).msa.I2_ll);
   set(GUI.I2upperlimitedit, 'String', handles.sqfit(index).msa.I2_ul);

end

if (update_all == 1) || (update_fitopts ==1) % update the fit options
   set(GUI.fitmethodpopupmenu, 'Value', handles.sqfit(index).fitmethod);
   set(GUI.fitalgorithmpopupmenu, 'Value', handles.sqfit(index).fitalgorithm);
   set(GUI.fitmaxiteredit, 'String', handles.sqfit(index).fitmaxiter);
   set(GUI.fitlm_lambdaedit, 'String', handles.sqfit(index).fitlm_lambda);
end
