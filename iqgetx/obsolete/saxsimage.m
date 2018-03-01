function varargout = saxsimage(varargin)

% Edit the above text to modify the response to help saxsimage

% Last Modified by GUIDE v2.5 25-May-2006 17:30:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @saxsimage_OpeningFcn, ...
                   'gui_OutputFcn',  @saxsimage_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before saxsimage is made visible.
function saxsimage_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to saxsimage (see VARARGIN)

% Choose default command line output for saxsimage
handles.output = hObject;

% ----- Added by Xiangyun Qiu

% initialize parameters
handles.action.mode=1;
handles.action.clickmode=1;
handles.action.dataxy=[];
handles.action.mousexy=[];
handles.action.MaskD_Old = [];
handles.action.hplot= []; % temporary line plots

handles.analysis.dspacing = 58.38;
handles.analysis.num_slices = 6;
handles.analysis.autoalign = 0;
handles.analysis.autoaligntoler = 0.001;

handles.analysis.circradius = 0.25;
handles.analysis.circwidth = 0.05;
handles.analysis.circpoints = 100;
handles.analysis.circthetawidth = 3/180*pi; % angle width for each point

% the axes to get xy coordinate (depending on one or two click mode)
handles.activeaxes = handles.mainaxes; 
handles.display.colormap='jet';
handles.display.min=0;
handles.display.max=inf;
handles.display.calibring=0;
handles.display.mask=0;
handles.display.zoom=0;
handles.display.zoom_size=64;

% the beam center calibrant ring
theta = linspace(0,2*pi, 300)';
handles.beamcenter.unit_ring = [cos(theta), sin(theta)];
delete(get(handles.mainaxes, 'children')); % remove any existing image

% initialize display if an image is passed
if (nargin > 3) && isnumeric(varargin{1})
   handles.im=varargin{1};
   handles.im_size=size(handles.im);

   global X_cen Y_cen Spec_to_Phos X_Lambda MaskD
   if isempty(X_Lambda); X_Lambda = 1.54; end
   if isempty(X_cen); X_cen = handles.im_size(1)/2; end
   if isempty(Y_cen); Y_cen = handles.im_size(2)/2; end
   if isempty(Spec_to_Phos); Spec_to_Phos = 1000; end;
   if isempty(MaskD); MaskD = ones(handles.im_size, 'uint8'); end
   
   handles.display.min = max([0,min(handles.im(:))]);
   handles.display.max = max([max(handles.im(:)), handles.display.min+1]);;
   set(handles.minedit, 'String', num2str(handles.display.min));
   set(handles.maxedit, 'String', num2str(handles.display.max));
   guidata(hObject, handles);
   displayevents_Callback(handles.colormappopupmenu, [], handles);
else
   % Update handles structure
   guidata(hObject, handles);
end
% ----- End

% UIWAIT makes saxsimage wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = saxsimage_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in colormappopupmenu.
function actionevents_Callback(hObject, eventdata, handles)
% hObject    handle to colormappopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tagname = get(hObject, 'Tag');
switch tagname
   case 'beamcenterradiobutton'
      if (get(hObject, 'Value') == 1);
         handles.action.mode = 1;
      end
   case 'maskradiobutton'
      if (get(hObject, 'Value') == 1);
         handles.action.mode = 2;
      end
   case 'oneclickradiobutton'
      if (get(hObject, 'Value') == 1);
         handles.action.clickmode = 1;
         handles.activeaxes = handles.mainaxes;
         handles.display.zoom = get(handles.zoomcheckbox, 'Value');
      end
   case 'twoclickradiobutton'
      if (get(hObject, 'Value') == 1);
         handles.action.clickmode = 2;
      end
   case 'dataxylistbox'
   
   case 'maskundopushbutton'
      global MaskD
      if ~isempty(handles.action.MaskD_Old)
         MaskD = handles.action.MaskD_Old;
      end
      displayevents_Callback(handles.removepushbutton, [], handles);
   case 'removepushbutton'
      iselected = get(handles.dataxylistbox, 'Value');
      if ~isempty(iselected) && ~isempty(handles.action.dataxy)
         handles.action.dataxy(iselected, :) = [];
         set(handles.dataxylistbox, 'Value', ...
                           length(handles.action.dataxy(:,1)), ...
                           'String', num2str(handles.action.dataxy, ...
                                             ['(%7.2f, ' '%7.2fi)']));
         guidata(hObject, handles);
         displayevents_Callback(handles.removepushbutton, [], handles);
      end
   case 'calculatepushbutton'
      global X_cen Y_cen Spec_to_Phos X_Lambda
      [X_cen_new, Y_cen_new, radius]=circfit(handles.action.dataxy(:,1), ...
                                             handles.action.dataxy(:,2));

      Spec_to_Phos_new = radius/tan(2*asin(X_Lambda/2/handles.analysis.dspacing));

      disp(['NEW beam center: X_cen: ' num2str(X_cen_new) 'Y_cen: ' ...
            num2str(Y_cen_new) ', Spec_to_Phos: ' num2str(Spec_to_Phos_new)])
      disp('Global variables were not set, please set manually')
      
      handles.beamcenter.X_cen_new = X_cen_new;
      handles.beamcenter.Y_cen_new = Y_cen_new;
      handles.beamcenter.Spec_to_Phos_new = Spec_to_Phos_new;
      handles.beamcenter.radius = radius;
      set(handles.circradiusedit, 'String', num2str(handles.beamcenter.radius))
      guidata(hObject, handles);
      displayevents_Callback(handles.calculatepushbutton, [], handles);
   case 'setglobalvpushbutton'
      if ~isfield(handles.beamcenter, 'X_cen_new');
         disp(['Beam center, sample to detector distance have not ' ...
               'been calibrated!'])
         return;
      end
      global X_cen Y_cen Spec_to_Phos X_Lambda
      disp(['OLD beam center: X_cen: ' num2str(X_cen) 'Y_cen: ' ...
            num2str(Y_cen) ', Spec_to_Phos: ' num2str(Spec_to_Phos)])
      X_cen = handles.beamcenter.X_cen_new;
      Y_cen = handles.beamcenter.Y_cen_new;
      Spec_to_Phos = handles.beamcenter.Spec_to_Phos_new;
      disp(['NEW beam center: X_cen: ' num2str(X_cen) 'Y_cen: ' ...
            num2str(Y_cen) ', Spec_to_Phos: ' num2str(Spec_to_Phos)])
   otherwise
      disp('Not supported yet!')
end
guidata(hObject, handles);

% --- Executes on selection change in colormappopupmenu.
function analysisevents_Callback(hObject, eventdata, handles)
% hObject    handle to colormappopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

tagname = get(hObject, 'Tag');
switch tagname
   case 'dspacingedit'
      handles.analysis.dspacing = str2num(get(hObject, 'String'));
      guidata(hObject, handles);
      displayevents_Callback(handles.calibringcheckbox, [], handles);
   case 'slicenumedit'
      handles.analysis.num_slices = str2num(get(hObject, 'String'));
   case 'autoaligncheckbox'
      handles.analysis.autoalign = get(hObject, 'Value');
   case 'autoaligntoleredit'
      handles.analysis.autoaligntoler = str2num(get(hObject, 'String'));
   case 'circradiusedit'
      handles.analysis.circradius = str2num(get(hObject, 'String'));
   case 'circwidthedit'
      handles.analysis.circwidth = str2num(get(hObject, 'String'));
   case 'circpointsedit'
      handles.analysis.circpoints = str2num(get(hObject, 'String'));
   case 'circthetawidthedit'
      handles.analysis.circthetawidth = str2num(get(hObject, 'String'))/180*pi;
   case 'slicingpushbutton'
      global X_cen Y_cen Spec_to_Phos X_Lambda
      [data, thetagrid] = slice_integrate(handles.im, ...
                                          handles.analysis.num_slices, ...
                                          handles.analysis.dspacing, ...
                                          'autoalign', ...
                                          handles.analysis.autoalign, ...
                                          'tolerance', ...
                                          handles.analysis.autoaligntoler);

      % reset the beam center calibrant ring radius
      if (handles.analysis.autoalign == 1)
         displayevents_Callback(handles.calibringcheckbox, [], handles);
      end
      
      % plot the I(Q)s from the slices
      figure; hold all
      for i=1:handles.analysis.num_slices
         plot(data(:,1,i), data(:,2,i));
         lege{i} = num2str(thetagrid([i,i+1])*180/pi, ['Angle: [%6.2f, ' ...
                             '%6.2f]']);
      end
      legend(lege);legend boxoff
     
      % plot the borders of the slices
      axes(handles.mainaxes);
      for i=1:length(thetagrid)
         plot([X_cen, X_cen+ handles.im_size(1)*2*cos(thetagrid(i))], ...
              [Y_cen, Y_cen+ handles.im_size(1)*2*sin(thetagrid(i))], 'w--');
      end
   case 'circlingpushbutton'
      [data, circ_box] = circ_integrate(handles.im, ...
                                        handles.analysis.circradius, ...
                                        handles.analysis.circwidth, ...
                                        'num_points', ...
                                        handles.analysis.circpoints, ...
                                        'thetawidth', ...
                                        handles.analysis.circthetawidth );
      % plot the angular dependence
      figure; hold all
      plot(data(:,1)*180/pi, data(:,2));
      
      % plot the circ box
      axes(handles.mainaxes);
      plot(circ_box(:,1), circ_box(:,2), '.w');
      
   otherwise
      disp('Not supported yet!')
end

guidata(hObject, handles);

function displayevents_Callback(hObject, eventdata, handles)
% hObject    handle to minedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

plot_main=1; % whether to plot in the main axis
plot_zoom=1; % whther to plot in the zoom axis (the small one)

tagname = get(hObject, 'Tag');
switch tagname
   case 'colormappopupmenu'
      colormaplist = get(hObject, 'String');
      handles.display.colormap=colormaplist{get(hObject, 'Value')};
      colormap(handles.mainaxes, handles.display.colormap);
      colormap(handles.zoomaxes, handles.display.colormap);
   case 'minedit'
      handles.display.min = str2num(get(hObject, 'String'));
   case 'maxedit'
      handles.display.max = str2num(get(hObject, 'String'));
   case 'calibringcheckbox'
      handles.display.calibring = get(hObject, 'Value');
   case 'maskcheckbox'
      handles.display.mask = get(hObject, 'Value');
   case 'zoomcheckbox'
      handles.display.zoom = get(hObject, 'Value');
      plot_main=0;
   case 'zoompopupmenu'
      handles.display.zoom_size = 8*2^(get(hObject, 'Value')-1);
      plot_main=0;
   case 'mainaxes' % axes click events
      
   case 'removepushbutton' % DO NOT DELETE: called from actionevents_callback()
   case 'calculatepushbutton'
      
   otherwise
      disp('Not supported yet!')
end

global X_cen Y_cen Spec_to_Phos X_Lambda MaskD;
if (plot_main == 1) % called only when main axes needs to be updated.
   axes(handles.mainaxes); hold all;
   if (handles.display.mask == 1)
      im = handles.im .* MaskD;
   else
      im = handles.im;
   end
   imagesc(im,[handles.display.min, handles.display.max]);

   % remove old objects
   children = get(gca, 'Children');
   if (numel(children) > 1); 
      delete(children(2:end));
   else
      axis tight; axis equal;
   end

   % plot beam center
   if ~isempty(handles.action.dataxy)
      if (handles.action.mode == 1) %  beam center mode
         plot(handles.action.dataxy(:,1), handles.action.dataxy(:,2), 'w+');
      end
      if (handles.action.mode == 2) %  mask  mode
         plot(handles.action.dataxy(:,1), handles.action.dataxy(:,2), ...
              'w+--');
      end
   end

   % plot calibration ring
   if (handles.display.calibring == 1)
      handles.beamcenter.calibradius = Spec_to_Phos*tan(2* ...
                                                        asin(X_Lambda/2/ ...
                                                        handles.analysis ...
                                                        .dspacing));
      plot(X_cen, Y_cen, 'w*');
      plot(X_cen+handles.beamcenter.calibradius* ...
           handles.beamcenter.unit_ring(:,1), Y_cen+ ...
           handles.beamcenter.calibradius* ...
           handles.beamcenter.unit_ring(:,2), 'w.');
   end
end

% need to update the zoom axes
if (plot_zoom == 1) && (handles.display.zoom == 1)
   cla(handles.zoomaxes);
   hplots = get(handles.mainaxes, 'Children');
   hplots = copyobj(hplots, handles.zoomaxes);
   if isempty(handles.action.mousexy)
      handles.action.mousexy=[X_cen, Y_cen];
   end
   % use current mousexy position, color limit as current setting
   set(handles.zoomaxes, 'xlim', [handles.action.mousexy(1)- ...
                       handles.display.zoom_size/2, ...
                       handles.action.mousexy(1)+ ...
                       handles.display.zoom_size/2], 'ylim', ...
                     [handles.action.mousexy(2)- ...
                      handles.display.zoom_size/2, ...
                      handles.action.mousexy(2)+ ...
                      handles.display.zoom_size/2], 'clim', ...
                     [handles.display.min, handles.display.max]);
end
guidata(hObject, handles);

function mouseevents_Callback(hObject, eventdata, handles)
% hObject    handle to minedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mousexy = get(handles.activeaxes, 'CurrentPoint');
mousexy = mousexy(1,1:2);
xlimit=get(handles.activeaxes, 'XLIM');
ylimit=get(handles.activeaxes, 'YLIM');

% check whether mouse is in the AXES
if (mousexy(1) >= xlimit(1)) && (mousexy(1) <= xlimit(2)) && ...
   (mousexy(2) >= ylimit(1)) && (mousexy(2) <= ylimit(2))


   % check whether the mouse is on data region
   if (mousexy(1) >= 1) && (mousexy(1) <= handles.im_size(1)) && ...
          (mousexy(2) >= 1) && (mousexy(2) <= handles.im_size(2))
      value =  handles.im(fix(mousexy(2)), fix(mousexy(1)));
   else
      value = -1;
   end
   
   % show the coordinate
   global X_cen Y_cen X_Lambda Spec_to_Phos
   q = 4*pi*sin(atan(norm(mousexy-[X_cen, Y_cen])/Spec_to_Phos)/2)/ X_Lambda;
   d = 2*pi/q;
   set(handles.messagetext, 'String', sprintf(['> X:%9.4f; Y:%9.4f; I:' ...
   '%+9.2f; Q:%7.4f; d:%9.2f'], mousexy(1), mousexy(2), value, q, d));

   % mask mode
   if (handles.action.mode == 2) && length(handles.action.dataxy) 
      if ishandle(handles.action.hplot)
         delete(handles.action.hplot);
      end
      handles.action.hplot = plot([handles.action.dataxy(end,1), ...
                          mousexy(1), handles.action.dataxy(1,1)], ...
                                  [handles.action.dataxy(end,2), ...
                          mousexy(2), handles.action.dataxy(1,2)], 'w+--');
   end
   
   % update the zoomaxes
   if (handles.display.zoom == 1) && (handles.activeaxes == handles.mainaxes)
      set(handles.zoomaxes, 'xlim', [mousexy(1)- ...
                          handles.display.zoom_size/2, mousexy(1)+ ...
                          handles.display.zoom_size/2], 'ylim', ...
                        [mousexy(2)- handles.display.zoom_size/2, ...
                         mousexy(2)+ handles.display.zoom_size/2]);
   end
end
handles.action.mousexy=mousexy;
guidata(hObject, handles);

function mouseclickevents_Callback(hObject, eventdata, handles)
% hObject    handle to minedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


mousexy = get(handles.activeaxes, 'CurrentPoint');
mousexy = mousexy(1,1:2);
xlimit=get(handles.activeaxes, 'XLIM');
ylimit=get(handles.activeaxes, 'YLIM');

% check whether the click is on the active AXES
if (mousexy(1) >= xlimit(1)) && (mousexy(1) <= xlimit(2)) && ...
   (mousexy(2) >= ylimit(1)) && (mousexy(2) <= ylimit(2))

   % handles left click
   if strcmpi(get(handles.saxsimage, 'SelectionType'), 'normal')
      
      % single click mode: get the point!
      if (handles.action.clickmode == 1)
         handles.action.dataxy = [handles.action.dataxy; mousexy];
         set(handles.dataxylistbox, 'String', num2str(handles.action.dataxy, ...
                                                      '(%0.2f, %0.2f)'));
         guidata(hObject, handles);
         displayevents_Callback(handles.mainaxes, [], handles);
      end
      
      % two click mode: 
      if (handles.action.clickmode == 2)

         if (handles.activeaxes == handles.mainaxes)
            % disable zooming 
            handles.display.zoom=0;
            % set active axes
            handles.activeaxes = handles.zoomaxes;
            guidata(hObject, handles);
         else
            % reset the active axes
            handles.activeaxes = handles.mainaxes;
            % enable zooming
            handles.display.zoom=1;
            
            % add the point
            handles.action.dataxy = [handles.action.dataxy; mousexy];
            set(handles.dataxylistbox, 'Value', ...
                              length(handles.action.dataxy(:,1)), ...
                              'String', num2str(handles.action.dataxy, ...
                                                '(%7.2f, %7.2f)'));
            guidata(hObject, handles);
            displayevents_Callback(handles.mainaxes, [], handles);
         end
      end
   end
   
   % handles double click button
   if strcmpi(get(handles.saxsimage, 'SelectionType'), 'Open')
      % nothing to do in the mask mode
      
      % if mask mode (end of selection)
      if (handles.action.mode == 2)
         newmask = roipoly(handles.im, handles.action.dataxy(:,1), ...
                           handles.action.dataxy(:,2));
         global MaskD
         handles.action.MaskD_Old = MaskD;
         MaskD = MaskD.*(1-uint8(newmask));
         % remove all point
         handles.action.dataxy = [];
         set(handles.dataxylistbox, 'Value', 1, 'String','');
         guidata(hObject, handles);
         displayevents_Callback(handles.mainaxes, [], handles);
      end
   end
end
