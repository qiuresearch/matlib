function varargout = sasimg_gui(im, varargin)
%        varargout = sasbot_gui(im, varargin)
%        imgdata can only be empty, a file name, or an image now
   global sas
   
   flag_debug = 0;

   if exist('im', 'var')
      sas.imgdata = sasimg_init(im);
      sas.iplot = 1; % only store the plotted index
   else
      sas.imgdata = []; %sasimg_init();
      sas.iplot = [];
   end
   
   % GUI section
   fig_size = [1230,820];
   scr_size = get(0,'ScreenSize');
   leftpanel_width = 240;
   rightpanel_width = 200;
   edit_settings = {'Style', 'Edit', 'BackgroundColor', 'w', ...
                      'Position', [10, 10, 20, 10]};
   
   sas.hfig = figure('Position', [0, scr_size(4)-fig_size(2), ...
                       fig_size(1), fig_size(2)], 'Name', 'sasimg_gui', ...
                     'Resize', 'on', 'NumberTitle', 'off', 'Visible', ...
                     'off', 'WindowButtonDownFcn', @gui_events_mouseclick, ...
                     'WindowButtonMotionFcn', @gui_events_mousemotion);
   set(sas.hfig, 'DefaultAxesFontSize', 11, 'DefaultAxesFontWeight', ...
                'Normal', 'DefaultAxesFontName', 'Times', ...
                'DefaultAxesLineWidth', 1, 'DefaultAxesXMinorTick', ...
                'on', 'DefaultAxesYMinorTick', 'ON', 'DefaultAxesBox', ...
                'ON', 'DefaultAxesNextPlot', 'Add', ...
                'DefaultLineLineWidth', 1, 'DefaultLineMarkerSize', ...
                3, 'DefaultTextFontSize', 11, 'DefaultTextFontWeight', ...
                'Normal', 'DefaultAxesFontName', 'Times');

   uiextras.set(sas.hfig, 'DefaultHBoxBackgroundColor', [0.3,0.3,0,3]);
   uiextras.set(sas.hfig, 'DefaultTabPanelTitleColor', 'b');
   uiextras.set(sas.hfig, 'DefaultBoxFontSize', 10);
   uiextras.set(sas.hfig, 'DefaultPanelPadding', 3);
   uiextras.set(sas.hfig, 'DefaultHBoxPadding', 3);
   
   % divide the main panel into left and right
   hmainpanel = uiextras.HBox('Parent', sas.hfig, 'Spacing', 5);
   hleftpanel =  uiextras.VBox('Parent', hmainpanel);
   hmidpanel = uiextras.VBox('Parent', hmainpanel);
   hrightpanel = uiextras.VBox('Parent', hmainpanel);
   set(hmainpanel, 'Sizes', [-1,-3, rightpanel_width]);
   sas.hmainpanel = hmainpanel;
   
   sas.hdatapro = gui_create_datapro('parent', hleftpanel);
   sas.hplotact = gui_create_plotact('parent', hmidpanel);
   sas.himganal = gui_create_imganal('parent', hrightpanel);
   
   % initialize plotting axeses
   sas.imaxes = sas.hplotact.imaxes;
   sas.zoomaxes = sas.hdatapro.zoomaxes;
   sas.iqaxes = sas.hplotact.iqaxes;
   sas.activeaxes = sas.imaxes;
   sas.hmousetrack = []; % temporary line for mouse motion
   sas.mousetwoclick = 1;
   sas.hdatapro = rmfield(sas.hdatapro, 'zoomaxes');
   sas.hplotact = rmfield(sas.hplotact, 'imaxes');

   % save sas and update all
   guidata(sas.hfig, sas);
   gui_update(sas, 'update_all', 1);
   set(sas.hfig, 'Visible', 'on');
   
   function dirbrowser_loadfile(filenames)
      gui_events_datapro(sas.hdatapro.loadfile, filenames);
   end

   function dirbrowser_loadnewfile(hobject, event, watchdir)
      showinfo(['Loading new files from dir: ' watchdir]);
      sas = guidata(sas.hfig);
      sas.imgdata = [sas.imgdata, sasimg_loadnewfile(sas.imgdata, watchdir)];
      guidata(sas.hfig, sas);
      gui_update(sas, 'update_all');
   end

   function hdatapro = gui_create_datapro(varargin);
      parse_varargin(varargin);
      if ~exist('parent', 'var') || isempty(parent)
         parent =  uiextras.VBox('Parent', figure());
      end

      gui_settings = {'CallBack', @gui_events_datapro};

      % 1) data list
      hpanel = uiextras.TabPanel('Parent', parent);
      hdirpanel = uiextras.Panel('Parent', hpanel);
      himgpanel = uiextras.Panel('Parent', hpanel);
      hpanel.TabNames = {'File', 'Image'};
      hpanel.SelectedChild = 1;
      
      % Panel #1) dir browser
      hdir = dirbrowser_gui('Parent', hdirpanel, 'LoadFileFunc', ...
                            @dirbrowser_loadfile, 'LoadNewFileFunc', ...
                            @dirbrowser_loadnewfile);

      % Panel #2) data list
      himgbox = uiextras.VBox('Parent', himgpanel);
      hdatapro.datalist = uicontrol('Parent', himgbox, 'Style', ...
                                    'ListBox', 'Max', 100, 'Min', ...
                                    1, 'String', 'no data available', ...
                                    gui_settings{:});
      % Load remove data
      hbox = uiextras.HBox('Parent', himgbox);
      hdatapro.loadfile = uicontrol('Parent', hbox, 'String', ['Load ' ...
                          'File'], gui_settings{:});
      hdatapro.rmdata = uicontrol('Parent', hbox, 'String', ['Rm ' ...
                          'Data'], gui_settings{:});
      set(hbox, 'Sizes', [-1,-1]);
      set(himgbox, 'Sizes', [-1,30]);

      % 2) plot options box
      hpanel = uiextras.Panel('Parent', parent, 'Title', 'Image Processing');
      hdataprobox = uiextras.VBox('Parent', hpanel);
      hgrid = uiextras.Grid('Parent', hdataprobox);
      
      % image editting
      
      hdatapro.gui2newdata= uicontrol('Parent', hgrid, 'Style', 'checkbox', 'String', 'GUI2NewData', 'Tag', ...
                                   'gui2newdata', gui_settings{:});

      hdatapro.autogetiq = uicontrol('Parent', hgrid, 'Style', 'checkbox', ...
                                'String', 'AutoGet I(Q)', 'Tag', 'autogetiq', ...
                                   gui_settings{:});

      hdatapro.autosaveiq = uicontrol('Parent', hgrid, 'Style', 'checkbox', ...
                                'String', 'AutoSave I(Q)', 'Tag', 'autosaveiq', ...
                                   gui_settings{:});

      hdatapro.invertim= uicontrol('Parent', hgrid, 'Style', 'checkbox', 'String', 'Invert Im', 'Tag', ...
                                   'invertim', gui_settings{:});

      hbox_tmp = uiextras.HBox('Parent', hgrid);
      uicontrol('Parent', hbox_tmp, 'Style', 'text', 'String', 'As 0:');
      hdatapro.invertim_zero=uicontrol('Parent', hbox_tmp, 'Tag', 'invertim_zero', edit_settings{:}, gui_settings{:});
      set(hbox_tmp, 'Sizes', [-1,-2]);

      hdatapro.transposeim= uicontrol('Parent', hgrid, 'Style', 'checkbox', 'String', 'Transpose Im', 'Tag', ...
                                   'transposeim', gui_settings{:});
      
%      hdatapro.transposeim_type = uicontrol('Parent', hgrid, 'Style', 'popupmenu', 'String', sas.imgdata(1).transposeim_method, ...
%                                    'UserData', sas.imgdata(1).transposeim_method, 'Value', ...
%                                    1, 'Tag', 'transposeim_type', gui_settings{:});


      hbox_tmp = uiextras.HBox('Parent', hgrid);
      uicontrol('Parent', hbox_tmp, 'Style', 'text', 'String', 'Offset');
      hdatapro.offset=uicontrol('Parent', hbox_tmp, 'Tag', 'offset', edit_settings{:}, gui_settings{:});
      set(hbox_tmp, 'Sizes', [-1,-2]);

      hbox_tmp = uiextras.HBox('Parent', hgrid);
      uicontrol('Parent', hbox_tmp, 'Style', 'text', 'String', 'Scale');
      hdatapro.scale=uicontrol('Parent', hbox_tmp, 'Tag', 'scale', edit_settings{:}, gui_settings{:});
      set(hbox_tmp, 'Sizes', [-1,-2]);
      
      hdatapro.log10I= uicontrol('Parent', hgrid, 'Style', 'checkbox', 'String', 'Apply log10(I)', 'Tag', ...
                                   'log10I', gui_settings{:});
            
      hdatapro.maskim= uicontrol('Parent', hgrid, 'Style', 'checkbox', 'String', 'Apply Mask', 'Tag', ...
                                   'maskim', gui_settings{:});
      
      set(hgrid, 'ColumnSizes', [-1,-1]); % 'RowSizes', [-1,-1,-1,-1,-1,-1]);
      
      % zoom axis;
      hdatapro.zoomaxes = axes('Parent', hdataprobox); axis off; %imagesc(1);

      % [img_processing, zoom_axes]
      set(hdataprobox, 'Sizes', [-1,leftpanel_width-10]);
      % [browser, datapro+zoomaxes]
      set(parent, 'Sizes', [-1, 360]);
   end

   function gui_events_datapro(hObject, eventdata)
      sas = guidata(hObject);
      hdatapro = sas.hdatapro;
      
      iselect = [];
      if isempty(sas.imgdata)
         disp('Please load data first...')
      else
         iselect = find([sas.imgdata(:).select]);
      end
      
      set(sas.hfig, 'Pointer', 'Watch')
      switch hObject
         case hdatapro.loadfile
            if exist('eventdata', 'var') && ~isempty(eventdata)
               filenames = eventdata;
            else
               filenames = uigetfile('MultiSelect', 'on');
               if isnumeric(filenames); return; end
               if ischar(filenames); filenames = {filenames}; end
            end
            if ~isempty(filenames)
               %dataformat_list = get(hdatapro.dataformat, 'String');
               %dataformat = dataformat_list{get(hdatapro.dataformat, 'Value')};
               dataformat = '';
               if ~isempty(sas.imgdata) && (get(hdatapro.gui2newdata,'Value') == 1)
                  if ~isempty(iselect)
                     itempl = iselect(end);
                  else
                     itempl = length(sas.imgdata);
                  end
                  imgdata_new = sasimg_init(filenames, 'copystru', ...
                                            sas.imgdata(itempl));
               else
                  imgdata_new = sasimg_init(filenames, 'dataformat', dataformat);
               end
               [imgdata_new.select] = deal(1);
               sas.imgdata = [sas.imgdata, imgdata_new];
               guidata(hObject, sas);
               gui_update(sas, 'update_all');
            end
         case hdatapro.rmdata
            if ~isempty(iselect)
               sas.imgdata(iselect) = [];
               if ~isempty(sas.imgdata)
                  sas.imgdata(min([iselect(1),end])).select = 1;
               end
               guidata(hObject, sas);
               gui_update(sas, 'update_all');
            else
               disp('No data is selected for removal!');
            end
         case hdatapro.gui2newdata
         case hdatapro.autosaveiq
            if ~isempty(iselect)
               [sas.imgdata(iselect).autosaveiq] = deal(get(hObject, 'Value'));
               guidata(hObject, sas);
            end
         case hdatapro.datalist
            iselect_gui = get(hdatapro.datalist, 'Value');
            if (length(iselect_gui) == length(iselect)) && ...
                   (total(abs(iselect_gui-iselect)) == 0)
               disp('No changes in selection!')
            else
               [sas.imgdata.select] = deal(0);
               [sas.imgdata(iselect_gui).select] = deal(1);
               guidata(hObject, sas);
               disp(['Select data sets: ' num2str(iselect_gui)])
            end
            % if the first selected item didn't change, only update
            % plot, no need to update GUI
            if ~isempty(iselect) && (iselect_gui(1) == iselect(1))
               gui_update(sas, 'update_plot');
            else
               gui_update(sas, 'update_all');
            end
            
         otherwise
            wtype = upper(get(hObject, 'Style'));
            tagname = get(hObject, 'Tag');
            switch wtype
               case 'EDIT'
                  [sas.imgdata(iselect).(tagname)] = deal(str2num(get(hObject, 'String')));
                  disp(['set ' tagname ' to ' num2str(sas.imgdata(iselect(1)).(tagname))]);
               case 'CHECKBOX'
                  [sas.imgdata(iselect).(tagname)] = deal(get(hObject, 'Value'));
                  disp(['set ' tagname ' to ' num2str(sas.imgdata(iselect(1)).(tagname))]);
               case 'POPUPMENU'
                  listdata = get(hObject, 'UserData');
                  if iscell(listdata)
                     [sas.imgdata(iselect).(tagname)] = deal(listdata{get(hObject, 'Value')});
                  else
                     [sas.imgdata(iselect).(tagname)] = deal(listdata(get(hObject, 'Value')));
                  end
                  disp(['set ' tagname ' to ' num2str(sas.imgdata(iselect(1)).(tagname))]);
               otherwise
                  showinfo(['Events from this widget: ' get(hObject, 'Type') ...
                            ' are ignored!']);
            end
            % change the plotopt range if invertim is clicked
            if (hObject == hdatapro.invertim)
               for i=1:length(iselect)
                  min_tmp = sas.imgdata(iselect(i)).plotopt.min;
                  sas.imgdata(iselect(i)).plotopt.min = ...
                      sas.imgdata(iselect(i)).invertim_zero - ...
                      sas.imgdata(iselect(i)).plotopt.max;
                  sas.imgdata(iselect(i)).plotopt.max = ...
                      sas.imgdata(iselect(i)).invertim_zero - min_tmp;
               end
            end
            
            sas.imgdata(iselect) = sasimg_dataprep(sas.imgdata(iselect));
            guidata(sas.hfig, sas);
            gui_update(sas, 'update_plot', 1, 'update_plotopt', 1);
      end
      set(sas.hfig, 'Pointer', 'Arrow')
   end
   
   function hplotact = gui_create_plotact(varargin);
      parse_varargin(varargin);
      if ~exist('parent', 'var') || isempty(parent)
         parent =  uiextras.VBox('Parent', figure());
      end
      
      gui_settings = {'CallBack', @gui_events_plotact};
      
      % 1) visualization axis
      hplotact.plotpanel = uiextras.TabPanel('Parent', parent);
      himpanel = uiextras.Panel('Parent', hplotact.plotpanel, 'Padding', 3);
      hiqpanel = uiextras.Panel('Parent', hplotact.plotpanel, 'Padding', 3);
      hplotact.plotpanel.TabNames = {'Image', 'I(Q)'};
      hplotact.plotpanel.SelectedChild = 1;
      
      %      hpanel = uiextras.Panel('Parent', parent, 'Title','Image', 'Padding', 25);
      %      hplotact.imaxesbox = uiextras.HBox('Parent', hpanel);
      hvbox = uiextras.VBox('Parent', himpanel, 'Spacing', 1);
      hplotact.imaxes = axes('Parent', hvbox);  %imagesc(0);
      % mouse mode
      %hpanel = uiextras.Panel('Parent', parent, 'Title', 'Mouse');
      hbox = uiextras.HBox('Parent', hvbox);
      hplotact.surfplot = uicontrol('Parent', hbox, 'Style', 'PushButton', ...
                                    'String', 'Surface Plot', 'Tag', ...
                                    'surfplot', gui_settings{:});
      uicontrol('Parent', hbox, 'Style', 'Text', 'String', 'Click mode:');
      hplotact.mousetwoclick = uicontrol('Parent', hbox, 'Style', ...
                                         'CheckBox', 'Value', 1, ...
                                         'String', 'Two click', ...
                                         'Tag', 'mousetwoclick', ...
                                         gui_settings{:});
      hplotact.mouseinfo = uicontrol('Parent', hbox, 'Style', ...
                                      'Text', 'String', ['> X: ' ...
                          '0.; Y: 0.; I: 0.'], 'HorizontalAlignment', 'Left');
      
      set(hbox, 'Sizes', [100,100,100,-1]);
      set(hvbox, 'Sizes', [-1,25]);
      %      hplotact.colorbaraxes = colorbar('Parent', hplotact.imaxesbox, ...
      %                                       'EastOutside');
      hvbox = uiextras.VBox('Parent', hiqpanel, 'Spacing', 1);
      hplotact.iqaxes = axes('Parent', hvbox); %imagesc(0);
      hbox = uiextras.HBox('Parent', hvbox);
      hplotact.iq_logx = uicontrol('Parent', hbox, 'Style', 'CheckBox', ...
                                   'Value', 0, 'String', 'LogX', ...
                                   'Tag', 'iq_logx', gui_settings{:});
      hplotact.iq_logy = uicontrol('Parent', hbox, 'Style', 'CheckBox', ...
                                   'Value', 0, 'String', 'LogY', ...
                                   'Tag', 'iq_logy', gui_settings{:});
      hplotact.iq_qiq = uicontrol('Parent', hbox, 'Style', 'CheckBox', ...
                                   'Value', 0, 'String', 'I(Q)*Q^', ...
                                   'Tag', 'iq_qiq', gui_settings{:});
      hplotact.iq_qiqpower = uicontrol('Parent', hbox, 'String', ...
                                       '1', 'Tag', 'iq_qiqpower', ...
                                       edit_settings{:}, gui_settings{:});
      hplotact.iq_match = uicontrol('Parent', hbox, 'Style', ...
                                    'Checkbox', 'String', ['Match ' ...
                          'I(Q)'], 'Value', 0, 'Tag', 'iq_match', gui_settings{:});
      uicontrol('Parent', hbox, 'Style', 'Text', 'String', 'Range:');
      hplotact.iq_matchrange = uicontrol('Parent', hbox, 'String', ...
                                         '[0.5,0.8]', 'Tag', ...
                                         'iq_matchrange', edit_settings{:}, ...
                                         gui_settings{:});
      hplotact.iq_matchscale = uicontrol('Parent', hbox, 'Style', ...
                                         'CheckBox', 'Value', 1, ...
                                         'String', 'Scale', 'Tag', ...
                                         'iq_matchscale', gui_settings{:});
      hplotact.iq_matchoffset = uicontrol('Parent', hbox, 'Style', ...
                                         'CheckBox', 'Value', 0, ...
                                         'String', 'Offset', 'Tag', ...
                                         'iq_matchoffset', gui_settings{:});
      set(hvbox, 'Sizes', [-1,25]);

      % 3) plot options
      hpanel = uiextras.Panel('Parent', parent, 'Title', 'Plot Options', 'Padding', 1);
      hgrid = uiextras.Grid('Parent', hpanel);
      
      hbox_tmp = uiextras.HBox('Parent', hgrid);
      uicontrol('Parent', hbox_tmp, 'Style', 'text', 'String', 'Min:');
      hplotact.min=uicontrol('Parent', hbox_tmp, 'Tag', 'min', edit_settings{:}, gui_settings{:});
      set(hbox_tmp, 'Sizes', [-1,-2]);

      hbox_tmp = uiextras.HBox('Parent', hgrid);
      uicontrol('Parent', hbox_tmp, 'Style', 'text', 'String', 'Max:');
      hplotact.max=uicontrol('Parent', hbox_tmp, 'Tag', 'max', edit_settings{:}, gui_settings{:});
      set(hbox_tmp, 'Sizes', [-1,-2]);

      hplotact.logscale= uicontrol('Parent', hgrid, 'Style', 'checkbox', ...
                                'String', 'LogScale', 'Tag', 'logscale', ...
                                   gui_settings{:});
      
      hbox_tmp = uiextras.HBox('Parent', hgrid);
      uicontrol('Parent', hbox_tmp, 'Style', 'text', 'String', 'ColorMap:');
      cmaplist = {'Jet', 'HSV', 'Hot', 'Cool', 'Spring', 'Summer', ...
                  'Autumn', 'Winter', 'Gray', 'Bone', 'Copper', ...
                  'Pink', 'Lines'};
      hplotact.colormap = uicontrol('Parent', hbox_tmp, 'Style', ...
                                    'popupmenu', 'String', cmaplist, ...
                                    'UserData', cmaplist, 'Value', ...
                                    1, 'Tag', 'colormap', gui_settings{:});
      set(hbox_tmp, 'Sizes', [-1,-1]);

      hbox_tmp = uiextras.HBox('Parent', hgrid);
      hplotact.zoom= uicontrol('Parent', hbox_tmp, 'Style', 'checkbox', ...
                               'String', 'Zoom', 'Tag', 'zoom', gui_settings{:});
      hplotact.zoomsize = uicontrol('Parent', hbox_tmp, 'Style', ...
                                    'popupmenu', 'String', {'8x8', ...
                          '16x16', '32x32', '64x64', '128x128'}, ...
                                    'Value', 1, 'UserData', ...
                                    [8,16,32,64,128], 'Tag', ...
                                    'zoomsize', gui_settings{:});
      set(hbox_tmp, 'Sizes', [-1,-2]);

      hplotact.locklim= uicontrol('Parent', hgrid, 'Style', 'checkbox', ...
                                  'String', 'LockLim', 'Tag', ...
                                  'locklim', gui_settings{:});
      
      set(hgrid, 'ColumnSizes', [-1,-1,-1,-1,-1,-1]);
      
      %      hplotact.colorbar = uicontrol('Parent', hgrid, 'Style', 'checkbox', ...
      %                                 'String', 'Color Bar', 'Tag', ...
      %                                    'colorbar', gui_settings{:});
      
      % 3) data selection
      hpanel = uiextras.Panel('Parent', parent, 'Title', 'Data to Plot', 'Padding', 1);
      hgrid = uiextras.Grid('Parent', hpanel);


      hplotact.im = uicontrol('Parent', hgrid, 'Style', 'checkbox', ...
                              'String', 'Img', 'Tag', 'im', 'Value', 1, gui_settings{:});

      hplotact.iq = uicontrol('Parent', hgrid, 'Style', 'checkbox', ...
                              'String', 'I(q)', 'Tag', 'iq', 'Value', 1, gui_settings{:});
      
      hplotact.MaskI = uicontrol('Parent', hgrid, 'Style', 'checkbox', ...
                              'String', 'MaskI', 'Tag', 'MaskI', gui_settings{:});
      
      hbox = uiextras.HBox('Parent', hgrid);
      hplotact.calibring = uicontrol('Parent', hbox, 'Style', ...
                                     'checkbox', 'String', 'Calibrant', ...
                                     'Tag', 'calibring', gui_settings{:});

      hplotact.calibring_num = uicontrol('Parent', hbox, 'String', ...
                                         '3', 'Tag', 'calibring_num', ...
                                         edit_settings{:}, gui_settings{:});
      set(hbox, 'Sizes', [-2,-1]);
      
      hplotact.calib_ringxy = uicontrol('Parent', hgrid, 'Style', 'checkbox', ...
                                     'String', 'Calib XY', 'Tag', ...
                                     'calib_ringxy', gui_settings{:});

      hplotact.mask_polygonxy = uicontrol('Parent', hgrid, 'Style', 'checkbox', ...
                                     'String', 'Mask XY', 'Tag', ...
                                     'mask_polygonxy', gui_settings{:});

      set(hgrid, 'ColumnSizes', [-1,-1,-1,-1,-1, -1]);
      
      % 4) action
      hpanel = uiextras.Panel('Parent', parent, 'Title', 'Action', 'Padding', 1);
      hbox = uiextras.HBox('Parent', hpanel);
      hplotact.undo = uicontrol('Parent', hbox, 'String', 'undo', gui_settings{:});
      hplotact.redo = uicontrol('Parent', hbox, 'String', 'redo', gui_settings{:});
      hplotact.setglobalv = uicontrol('Parent', hbox, 'String', ...
                                      'set globalV', gui_settings{:});
      hplotact.getglobalv = uicontrol('Parent', hbox, 'String', ...
                                      'get globalV', gui_settings{:});
      hplotact.integrate = uicontrol('Parent', hbox, 'String', 'integrate', gui_settings{:});
      hplotact.plotiq = uicontrol('Parent', hbox, 'String', 'plot I(Q)', gui_settings{:});
      
      set(parent, 'Sizes', [-1, 42, 42, 48]);
   end
   
   function gui_events_plotact(hObject, eventdata)
      sas = guidata(hObject);
      hplotact = sas.hplotact;
      %set(sas.hfig, 'Pointer', 'Watch');
      
      if isempty(sas.imgdata)
         disp('Please load data first...')
         return;
      else
         iselect = find([sas.imgdata(:).select]);
         if isempty(iselect);
            iselect = length(sas.imgdata);
            showinfo('Last data set is used: no data is selected!');
         end
      end
      
      switch hObject
         case hplotact.surfplot
            showinfo('Surf plotting...');
            im = sas.imgdata(sas.iplot(1)).im;
            im(find(im >  sas.imgdata(sas.iplot(1)).plotopt.max)) = ...
                 sas.imgdata(sas.iplot(1)).plotopt.max;
            im(find(im <  sas.imgdata(sas.iplot(1)).plotopt.min)) = ...
                 sas.imgdata(sas.iplot(1)).plotopt.min;
            
            figure; surf(im, 'EdgeColor', 'none');
            view(-37.5, 30);
         case hplotact.mousetwoclick
            sas.mousetwoclick = get(hObject, 'Value');
            guidata(hObject, sas);
         case hplotact.undo
            sas.imgdata(iselect) = sasimg_history(sas.imgdata(iselect), 'undo');
            guidata(hObject, sas);
            gui_update(sas, 'update_all');
         case hplotact.redo
            sas.imgdata(iselect) = sasimg_history(sas.imgdata(iselect), 'redo');
            guidata(hObject, sas);
            gui_update(sas, 'update_all');
         case hplotact.setglobalv
            sasimg_globalvar(sas.imgdata(iselect(end)), 'set');
         case hplotact.getglobalv
            sas.imgdata(iselect) = sasimg_history(sas.imgdata(iselect), 'save');
            sas.imgdata(iselect) = sasimg_globalvar(sas.imgdata(iselect), 'get');
            guidata(hObject, sas);
            gui_update(sas, 'update_plot', 1, 'update_imganal', 1);
         case hplotact.integrate
            sas.imgdata(iselect) = sasimg_run(sas.imgdata(iselect), 'iq_get');
            guidata(hObject, sas);
            gui_update(sas, 'update_plot', 1, 'update_imganal', 1);
         otherwise
            wtype = upper(get(hObject, 'Style'));
            tagname = get(hObject, 'Tag');
            switch wtype
               case 'EDIT'
                  newvalue = str2num(get(hObject, 'String'));
                  for i=1:length(iselect)
                     sas.imgdata(iselect(i)).plotopt.(tagname) = newvalue;
                  end
                  disp(['set ' tagname ' to ' num2str(sas.imgdata(iselect(1)).plotopt.(tagname))]);
               case 'CHECKBOX'
                  newvalue = get(hObject, 'Value');
                  for i = 1:length(iselect)
                     sas.imgdata(iselect(i)).plotopt.(tagname) = newvalue;
                  end
                  disp(['set ' tagname ' to ' num2str(sas.imgdata(iselect(1)).plotopt.(tagname))]);
               case 'POPUPMENU'
                  listdata = get(hObject, 'UserData');
                  if iscell(listdata)
                     newvalue = listdata{get(hObject, 'Value')};
                  else
                     newvalue = listdata(get(hObject, 'Value'));
                  end
                  for i =1:length(iselect)
                     sas.imgdata(iselect(i)).plotopt.(tagname) = newvalue;
                  end
                  disp(['set ' tagname ' to ' num2str(sas.imgdata(iselect(1)).plotopt.(tagname))]);
               otherwise
                  showinfo(['Events from this widget: ' get(hObject, 'Type') ...
                            ' are ignored!']);
            end
            guidata(sas.hfig, sas);
            gui_update(sas, 'update_plot');
      end
      %set(sas.hfig, 'Pointer', 'Arrow');
   end
   
   function himganal = gui_create_imganal(varargin);
      parse_varargin(varargin);
      if ~exist('parent', 'var') || isempty(parent)
         parent =  uiextras.VBox('Parent', figure());
      end
      
      gui_settings = {'CallBack', @gui_events_imganal};
   
      himganal.modepanel = uiextras.TabPanel('Parent', parent);
      hxycenpanel = uiextras.Panel('Parent', himganal.modepanel);
      hmaskpanel = uiextras.Panel('Parent', himganal.modepanel);
      hazimpanel = uiextras.Panel('Parent', himganal.modepanel);
      hxfdpanel = uiextras.Panel('Parent', himganal.modepanel);
      himganal.modepanel.TabNames = {'calib', 'mask', 'azimu', 'xfd'};
      himganal.modepanel.SelectedChild = 1;

      % #1) xy center
      hcalibox = uiextras.VBox('Parent', hxycenpanel);
      hbox = uiextras.VBox('Parent', hcalibox);

      hbox_tmp = uiextras.HBox('Parent', hbox);
      uicontrol('Parent', hbox_tmp, 'Style', 'text', 'String', 'calibrant:');
      himganal.calibrant=uicontrol('Parent', hbox_tmp, edit_settings{:}, ...
                                   'Tag', 'calibrant', gui_settings{:});
      hbox_tmp = uiextras.HBox('Parent', hbox);
      uicontrol('Parent', hbox_tmp, 'Style', 'text', 'String', 'dspacing:');
      himganal.calib_dspacing=uicontrol('Parent', hbox_tmp, ...
                                        edit_settings{:}, 'Tag', ...
                                        'calib_dspacing', gui_settings{:});

      hbox_tmp = uiextras.HBox('Parent', hbox);
      uicontrol('Parent', hbox_tmp, 'Style', 'text', 'String', 'X_Lambda:');
      himganal.X_Lambda=uicontrol('Parent', hbox_tmp, 'Tag', ...
                                  'X_Lambda', edit_settings{:}, gui_settings{:});
      hbox_tmp = uiextras.HBox('Parent', hbox);
      uicontrol('Parent', hbox_tmp, 'Style', 'text', 'String', 'Spec_to_Phos:');
      himganal.Spec_to_Phos=uicontrol('Parent', hbox_tmp, ...
                                      edit_settings{:}, 'Tag', ...
                                      'Spec_to_Phos', gui_settings{:});

      hbox_tmp = uiextras.HBox('Parent', hbox);
      uicontrol('Parent', hbox_tmp, 'Style', 'text', 'String', 'X_cen:');
      himganal.X_cen=uicontrol('Parent', hbox_tmp, edit_settings{:}, ...
                               'Tag', 'X_cen', gui_settings{:});
      hbox_tmp = uiextras.HBox('Parent', hbox);
      uicontrol('Parent', hbox_tmp, 'Style', 'text', 'String', 'Y_cen:');
      himganal.Y_cen=uicontrol('Parent', hbox_tmp, edit_settings{:}, ...
                               'Tag', 'Y_cen', gui_settings{:});
      
      himganal.calib_ringxy = uicontrol('Parent', hcalibox, 'Style', ...
                                   'ListBox', 'Max', 100, 'Min', ...
                                   1, 'String', ['click to input ' ...
                          'data'], 'Tag', 'calib_ringxy', gui_settings{:});

      hbox = uiextras.VBox('Parent', hcalibox);
      himganal.calib_compute = uicontrol('Parent', hbox, 'String', ...
                                         'compute calib', gui_settings{:});
      himganal.calib_ringxy_remove = uicontrol('Parent', hbox, ...
                                               'String', 'delete point(s)', ...
                                               gui_settings{:});
      himganal.calib_ringxy_clear = uicontrol('Parent', hbox, 'String', ...
                                              'clear all points', gui_settings{:}); 
      set(hcalibox, 'Sizes', [200, -1, 100]);
      
      % #2) mask
      hmaskbox = uiextras.VBox('Parent', hmaskpanel);
      
      hbox = uiextras.Grid('Parent', hmaskbox);
      htext = uicontrol('Parent', hbox, 'Style', 'Text', 'String', 'DetRadius:');
      htext = uicontrol('Parent', hbox, 'Style', 'Text', 'String', 'BeamStop:');
      htext = uicontrol('Parent', hbox, 'Style', 'Text', 'String', 'RmCenter:');
      htext = uicontrol('Parent', hbox, 'Style', 'Text', 'String', 'RmEdge:');
      himganal.mask_detradius = uicontrol('Parent', hbox, ...
                                               'String', '1150', 'Tag', 'mask_detradius', ...
                                               gui_settings{:}, ...
                                               edit_settings{:});
      himganal.mask_bsradius = uicontrol('Parent', hbox, 'String', ...
                                              '25', 'Tag', 'mask_bsradius', gui_settings{:}, ...
                                              edit_settings{:});
      himganal.mask_deadcenradius = uicontrol('Parent', hbox, ...
                                               'String', '15', 'Tag', 'mask_deadcenradius',  ...
                                               gui_settings{:}, ...
                                               edit_settings{:});
      himganal.mask_edgewidth = uicontrol('Parent', hbox, 'String', ...
                                          '15', 'Tag', 'mask_edgewidth', ...
                                          gui_settings{:}, edit_settings{:});
      
      set(hbox, 'ColumnSizes', [-1,-1], 'RowSizes', [-1,-1,-1,-1]);
      
      himganal.mask_auto = uicontrol('Parent', hmaskbox, 'String', 'auto', gui_settings{:});

      % coordinates
      himganal.mask_polygonxy = uicontrol('Parent', hmaskbox, 'Style', ...
                                   'ListBox', 'Max', 100, 'Min', ...
                                   1, 'String', ['click to input ' ...
                          'data'], 'Tag', 'mask_polyonxy', gui_settings{:});

      hbox = uiextras.VBox('Parent', hmaskbox);
      himganal.mask_exclude = uicontrol('Parent', hbox, 'String', 'exclude polygon', ...
                                   gui_settings{:});
      himganal.mask_include = uicontrol('Parent', hbox, 'String', 'include polygon', ...
                                   gui_settings{:});
      himganal.mask_reset = uicontrol('Parent', hbox, 'String', ...
                                      'reset all mask', gui_settings{:});
      himganal.mask_save = uicontrol('Parent', hbox, 'String', ...
                                      'save mask', gui_settings{:});
      himganal.mask_savefile = uicontrol('Parent', hbox, 'String', ...
                                      ['MaskI_' datestr(now, 'yymmdd') '.mat'], edit_settings{:}, ...
                                         gui_settings{:});

      himganal.mask_polygonxy_remove = uicontrol('Parent', hbox, 'String', 'delete point(s)', ...
                                    gui_settings{:});
      himganal.mask_polygonxy_clear = uicontrol('Parent', hbox, 'String', ...
                                        'clear all points', gui_settings{:});
      set(hmaskbox, 'Sizes', [110, 38, -1,230]);
      
      % #3) azimuthal operation
      hazimbox = uiextras.VBox('Parent', hazimpanel);

      % Pizza slicing
      hpizzapanel = uiextras.Panel('Parent', hazimbox, 'Title', 'Pizza');
      hvbox = uiextras.VBox('Parent', hpizzapanel);

      hbox_tmp = uiextras.HBox('Parent', hvbox);
      htext = uicontrol('Parent', hbox_tmp, 'Style', 'Text', 'String', ...
                        'Num. Slices:');
      himganal.slice_num = uicontrol('Parent', hbox_tmp, 'String', ...
                                     '8', 'Tag', 'slice_num', ...
                                     gui_settings{:}, edit_settings{:});

      hbox_tmp = uiextras.HBox('Parent', hvbox);
      htext = uicontrol('Parent', hbox_tmp, 'Style', 'Text', 'String', ...
                        'd spacing (A):');
      himganal.slice_dspacing = uicontrol('Parent', hbox_tmp, 'String', ...
                                          '58.38', 'Tag', 'slice_dspacing', ...
                                          gui_settings{:}, edit_settings{:});

      hbox_tmp = uiextras.HBox('Parent', hvbox);
      htext = uicontrol('Parent', hbox_tmp, 'Style', 'Text', 'String', ...
                        'Tolerance:');
      himganal.slice_tolerance = uicontrol('Parent', hbox_tmp, 'String', ...
                                          '0.01', 'Tag', 'slice_tolerance', ...
                                          gui_settings{:}, edit_settings{:});

      hbox_tmp = uiextras.HBox('Parent', hvbox);
      himganal.slice_autoalign = uicontrol('Parent', hbox_tmp, ...
                                           'Style', 'CheckBox', ...
                                           'String', 'AutoAlign', ...
                                           'Tag', 'slice_autoalign', ...
                                           gui_settings{:});

      himganal.slice_doit = uicontrol('Parent', hbox_tmp, 'String', ...
                                      ['Slice ' 'Pizza'], 'Tag', ...
                                      'slice_doit', gui_settings{:});
      
      % donut rolling
      hdonutpanel = uiextras.Panel('Parent', hazimbox, 'Title', 'Donut');
      hvbox = uiextras.VBox('Parent', hdonutpanel);

      hbox_tmp = uiextras.HBox('Parent', hvbox);
      htext = uicontrol('Parent', hbox_tmp, 'Style', 'Text', 'String', ...
                        'Num. Points:');
      himganal.donut_numpoints = uicontrol('Parent', hbox_tmp, 'String', ...
                                     '100', 'Tag', 'donut_numpoints', ...
                                     gui_settings{:}, edit_settings{:});

      hbox_tmp = uiextras.HBox('Parent', hvbox);
      htext = uicontrol('Parent', hbox_tmp, 'Style', 'Text', 'String', ...
                        'Q_cen (/A):');
      himganal.donut_Qcenter = uicontrol('Parent', hbox_tmp, 'String', ...
                                         '0.25', 'Tag', 'donut_Qcenter', ...
                                         gui_settings{:}, edit_settings{:});

      hbox_tmp = uiextras.HBox('Parent', hvbox);
      htext = uicontrol('Parent', hbox_tmp, 'Style', 'Text', 'String', ...
                        'Q_width (/A):');
      himganal.donut_Qwidth = uicontrol('Parent', hbox_tmp, 'String', ...
                                        '0.02', 'Tag', 'donut_Qwidth', ...
                                        gui_settings{:}, edit_settings{:});

      hbox_tmp = uiextras.HBox('Parent', hvbox);
      himganal.donut_doit = uicontrol('Parent', hbox_tmp, 'String', ...
                                      ['Rotate Donut'], 'Tag', ...
                                      'donut_doit', gui_settings{:});
      
      % background remove
      hdonutpanel = uiextras.Panel('Parent', hazimbox, 'Title', ...
                                   ['SymBkg Removal']);
      hvbox = uiextras.VBox('Parent', hdonutpanel);

      hbox_tmp = uiextras.HBox('Parent', hvbox);
      htext = uicontrol('Parent', hbox_tmp, 'Style', 'Text', 'String', ...
                        'Num. Bins:');
      himganal.symbkg_numbins = uicontrol('Parent', hbox_tmp, 'String', ...
                                          '100', 'Tag', 'symbkg_numbins', ...
                                          gui_settings{:}, edit_settings{:});
      
      hbox_tmp = uiextras.HBox('Parent', hvbox);
      htext = uicontrol('Parent', hbox_tmp, 'Style', 'Text', 'String', ...
                        'Negative %:');
      himganal.symbkg_negfraction = uicontrol('Parent', hbox_tmp, 'String', ...
                                          '0.1', 'Tag', 'symbkg_negfraction', ...
                                          gui_settings{:}, edit_settings{:});
      hbox_tmp = uiextras.HBox('Parent', hvbox);
      himganal.symbkg_doit = uicontrol('Parent', hbox_tmp, 'String', ...
                                       ['Sub SymBkg'], 'Tag', ...
                                       'symbkg_doit', gui_settings{:});
      
      % reserved
      hdonutpanel = uiextras.Panel('Parent', hazimbox, 'Title', ['TBA']);
      hvbox = uiextras.VBox('Parent', hdonutpanel);

      set(hazimbox, 'Sizes', [-2,-2,-1,-1]);
   end
   
   function gui_events_imganal(hObject, eventdata)
      sas = guidata(hObject);
      himganal = sas.himganal;
      
      if isempty(sas.imgdata)
         disp('Please load data first...')
      else
         iselect = find([sas.imgdata(:).select]);
         if isempty(iselect);
            showinfo('No data is selected!');
            %            return
         end
      end
      
      set(sas.hfig, 'Pointer', 'Arrow')
      switch hObject
         case himganal.calib_ringxy
            showinfo('not yet implemented for clicking!');
         case himganal.calib_ringxy_remove
            ixyselect = get(himganal.calib_ringxy, 'Value');
            if ~isempty(sas.imgdata(iselect(1)).calib_ringxy)
               sas.imgdata(iselect(1)).calib_ringxy(ixyselect,:) = [];
               sas.imgdata(iselect(1)) = sasimg_history(sas.imgdata(iselect(1)), 'save');
               guidata(hObject, sas);
               gui_update(sas, 'update_plot', 1, 'update_imganal', 1);
            end
         case himganal.calib_ringxy_clear
            sas.imgdata(iselect(1)) = sasimg_history(sas.imgdata(iselect(1)), 'save');
            sas.imgdata(iselect(1)).calib_ringxy = [];
            guidata(hObject, sas);
            gui_update(sas, 'update_plot', 1, 'update_imganal', 1);
         case himganal.calib_compute
            sas.imgdata(iselect(1)) = sasimg_history(sas.imgdata(iselect(1)), 'save');
            sas.imgdata(iselect(1)) = sasimg_run(sas.imgdata(iselect(1)), 'calib');
            guidata(hObject, sas);
            gui_update(sas, 'update_plot', 1, 'update_imganal', 1);
         case himganal.mask_auto
            sas.imgdata(iselect(1)) = sasimg_history(sas.imgdata(iselect(1)), 'save');
            sas.imgdata(iselect(1)) = sasimg_run(sas.imgdata(iselect(1)), 'mask_auto');
            guidata(hObject, sas);
            gui_update(sas, 'update_plot', 1);
         case himganal.mask_polygonxy
         case himganal.mask_polygonxy_remove
            ixyselect = get(himganal.mask_polygonxy, 'Value');
            if ~isempty(sas.imgdata(iselect(1)).mask_polygonxy)
               sas.imgdata(iselect(1)) = sasimg_history(sas.imgdata(iselect(1)), 'save');
               sas.imgdata(iselect(1)).mask_polygonxy(ixyselect,:) = [];
               guidata(hObject, sas);
               gui_update(sas, 'update_plot', 1, 'update_imganal', 1);
            end
         case himganal.mask_polygonxy_clear
            sas.imgdata(iselect(1)) = sasimg_history(sas.imgdata(iselect(1)), 'save');
            sas.imgdata(iselect(1)).mask_polygonxy = [];
            guidata(hObject, sas);
            gui_update(sas, 'update_plot', 1, 'update_imganal', 1);
         case himganal.mask_exclude
            sas.imgdata(iselect(1)) = sasimg_history(sas.imgdata(iselect(1)), 'save');
            sas.imgdata(iselect(1)) = sasimg_run(sas.imgdata(iselect(1)), 'mask_exclude');
            guidata(hObject, sas);
            gui_update(sas, 'update_plot', 1);
         case himganal.mask_include
            sas.imgdata(iselect(1)) = sasimg_history(sas.imgdata(iselect(1)), 'save');
            sas.imgdata(iselect(1)) = sasimg_run(sas.imgdata(iselect(1)), 'mask_include');
            guidata(hObject, sas);
            gui_update(sas, 'update_plot', 1);
         case himganal.mask_reset
            sas.imgdata(iselect(1)) = sasimg_history(sas.imgdata(iselect(1)), 'save');
            sas.imgdata(iselect(1)) = sasimg_run(sas.imgdata(iselect(1)), 'mask_reset');
            guidata(hObject, sas);
            gui_update(sas, 'update_plot', 1);
         case himganal.mask_save
            sas.imgdata(iselect(1)).MaskIfile = get(himganal.mask_savefile, 'String');
            sasimg_run(sas.imgdata(iselect(1)), 'mask_save');
            guidata(hObject, sas);
         case himganal.slice_doit
            axes(sas.imaxes);
            sas.imgdata(iselect(1)) = sasimg_run(sas.imgdata(iselect(1)), 'slice_pizza');
            guidata(hObject, sas);
            if (sas.imgdata(iselect(1)).slice_autoalign); gui_update(sas, 'update_imganal', 1); end
         case himganal.donut_doit
            axes(sas.imaxes);
            sas.imgdata(iselect(1)) = sasimg_run(sas.imgdata(iselect(1)), 'roll_donut');
            guidata(hObject, sas);
         case himganal.symbkg_doit
            sas.imgdata(iselect(1)) = sasimg_run(sas.imgdata(iselect(1)), 'sub_symbkg');
            guidata(hObject, sas);
            gui_update(sas, 'update_plot', 1);
         otherwise
            wtype = upper(get(hObject, 'Style'));
            tagname = get(hObject, 'Tag');
            switch wtype
               case 'EDIT'
                  [sas.imgdata(iselect).(tagname)] = deal(str2num(get(hObject, 'String')));
                  disp(['set ' tagname ' to ' num2str(sas.imgdata(iselect(1)).(tagname))]);
               case 'CHECKBOX'
                  [sas.imgdata(iselect).(tagname)] = deal(get(hObject, 'Value'));
                  disp(['set ' tagname ' to ' num2str(sas.imgdata(iselect(1)).(tagname))]);
               case 'POPUPMENU'
                  listdata = get(hObject, 'UserData');
                  if iscell(listdata)
                     [sas.imgdata(iselect).(tagname)] = deal(listdata{get(hObject, 'Value')});
                  else
                     [sas.imgdata(iselect).(tagname)] = deal(listdata(get(hObject, 'Value')));
                  end
                  disp(['set ' tagname ' to ' num2str(sas.imgdata(iselect(1)).(tagname))]);
               otherwise
                  showinfo(['Events from this widget: ' get(hObject, 'Type') ...
                            ' are ignored!']);
            end
            guidata(sas.hfig, sas);
            gui_update(sas, 'update_plot');
      end
   end
            
   function gui_update(sas, varargin)
   % default is to do nothing
      update_all = 0;
      update_plot = 0;
      update_datapro = 0; 
      update_plotopt = 0;
      update_imganal = 0;
      parse_varargin(varargin);
      
      % update the datalist
      if isempty(sas.imgdata);
         set(sas.hdatapro.datalist, 'Value', [], 'String', 'no data loaded!');
         return; 
      else
         imgdata = sas.imgdata;
         iselect = find([imgdata(:).select]);
         set(sas.hdatapro.datalist, 'Value', iselect, 'String', {imgdata(:).title});
      end
      
      if (update_all+update_datapro+update_plot+update_imganal) == 0
         if flag_debug; showinfo('No GUI update is requested!'); end
         return
      end
      
      % update the rest from selected data
      if isempty(iselect) || (iselect(1) == 0)
         showinfo('No data is selected, no update!');
         return
      end
      imgdata = imgdata(iselect(end));       % only the first data is used for updating

      % plot
      if (update_all ==1) || (update_plot ==1);
         %         axes(sas.imaxes); cla; hold all;
         sasimg_plot(sas.imgdata(iselect), [], imgdata.plotopt, ...
                     'imaxes', sas.imaxes, 'zoomaxes', sas.zoomaxes, ...
                     'iqaxes', sas.iqaxes);
         sas.iplot = iselect(end);
         guidata(sas.imaxes, sas);
      end
      
      if (update_all == 1) || (update_datapro == 1)
         uinames = fieldnames(sas.hdatapro);
         for i=1:length(uinames)
            if ~isfield(imgdata, uinames{i});
               if flag_debug
                  showinfo(['No fieldname <' uinames{i} '> in sasimg structure!']);
               end
               continue;
            end
            switch upper(get(sas.hdatapro.(uinames{i}), 'Style'))
               case 'EDIT'
                  set(sas.hdatapro.(uinames{i}), 'String', imgdata.(uinames{i}));
               case 'CHECKBOX'
                  set(sas.hdatapro.(uinames{i}), 'Value',  imgdata.(uinames{i}));
               case 'POPUPMENU'
                  listdata = get(sas.hdatapro.(uinames{i}), 'UserData');
                  if isstr(imgdata.(uinames{i}))
                     set(sas.hdatapro.(uinames{i}), 'Value', ...
                                       strmatch(imgdata.(uinames{i}), listdata));
                  else
                     set(sas.hdatapro.(uinames{i}), 'Value', ...
                                       find(listdata == imgdata.(uinames{i})));
                  end                     
               otherwise
                  showinfo(['UI not updated: ' uinames{i}]);
            end
         end
      end

      if (update_all == 1) || (update_plotopt == 1)
         uinames = fieldnames(sas.hplotact);
         for i=1:length(uinames)
            if ~isfield(imgdata.plotopt, uinames{i});
               if flag_debug
                  showinfo(['No fieldname <' uinames{i} '> in sasimg.plotopt structure!']);
               end
               continue;
            end
            switch upper(get(sas.hplotact.(uinames{i}), 'Style'))
               case 'EDIT'
                  if length(imgdata.plotopt.(uinames{i})) > 1
                     set(sas.hplotact.(uinames{i}), 'String', ...
                                       value2commandstr(imgdata.plotopt.(uinames{i})));
                  else
                     set(sas.hplotact.(uinames{i}), 'String', ...
                                       imgdata.plotopt.(uinames{i}));
                  end
                  
               case 'CHECKBOX'
                  set(sas.hplotact.(uinames{i}), 'Value',  imgdata.plotopt.(uinames{i}));
               case 'POPUPMENU'
                  listdata = get(sas.hplotact.(uinames{i}), 'UserData');
                  if isstr(imgdata.plotopt.(uinames{i}))
                     set(sas.hplotact.(uinames{i}), 'Value', ...
                                       strmatch(imgdata.plotopt.(uinames{i}), listdata));
                  else
                     set(sas.hplotact.(uinames{i}), 'Value', ...
                                       find(listdata == imgdata.plotopt.(uinames{i})));
                  end                     
               otherwise
                  showinfo(['UI not updated: ' uinames{i}]);
            end
         end
      end
      
      if (update_all ==1) || (update_imganal == 1)
         uinames = fieldnames(sas.himganal);
         onoff = {'on', 'off'};
         for i=1:length(uinames)
            if ~isfield(imgdata, uinames{i}); 
               if flag_debug
                  showinfo(['No fieldname <' uinames{i} '> in sasimg structure!']);
               end 
               continue; 
            end
            switch upper(get(sas.himganal.(uinames{i}), 'Style'))
               case 'EDIT'
                  set(sas.himganal.(uinames{i}), 'String', ...
                                    imgdata.(uinames{i}));
               case 'CHECKBOX'
                  set(sas.himganal.(uinames{i}), 'Value', ...
                                    imgdata.(uinames{i}));
               case 'POPUPMENU'
                  listdata = get(sas.himganal.(uinames{i}), 'UserData');
                  if isstr(imgdata.(uinames{i}))
                     set(sas.himganal.(uinames{i}), 'Value', ...
                                       strmatch(imgdata.(uinames{i}), listdata));
                  else
                     set(sas.himganal.(uinames{i}), 'Value', ...
                                       find(listdata == imgdata.(uinames{i})));
                  end                     
               case 'LISTBOX'
                  if ~isempty(imgdata.calib_ringxy)
                     set(sas.himganal.calib_ringxy, 'Value', ...
                                       length(imgdata.calib_ringxy(:,1)), ...
                                       'String', num2str(imgdata.calib_ringxy, ...
                                                         ['(%7.2f, %7.2f)']));
                  else
                     set(sas.himganal.calib_ringxy, 'Value', 1, ...
                                       'String', ['click ' 'to input data']);
                  end
                  if ~isempty(imgdata.mask_polygonxy)
                     set(sas.himganal.mask_polygonxy, 'Value', ...
                                       length(imgdata.mask_polygonxy(:,1)), ...
                                       'String', num2str(imgdata.mask_polygonxy, ...
                                                         ['(%7.2f, %7.2f)']));
                  else
                     set(sas.himganal.mask_polygonxy, 'Value', 1, ...
                                       'String', 'click to input data');
                  end
                  
                  
               otherwise
                  showinfo(['UI not updated: ' uinames{i}]);
            end
         end
      end
   end
   
   function gui_events_mousemotion(hObject, eventdata)
   % hObject    handle to minedit (see GCBO)
   % eventdata  reserved - to be defined in a future version of MATLAB
      
      sas = guidata(hObject);
      if isempty(sas.iplot) || (sas.iplot(1) == 0);
         return;
      end
      mousexy = get(sas.activeaxes, 'CurrentPoint');
      mousexy = mousexy(1,1:2);
      xlimit=get(sas.activeaxes, 'XLIM');
      ylimit=get(sas.activeaxes, 'YLIM');
     
      % remove old plot of mouse trace
      if ishandle(sas.hmousetrack)
         delete(sas.hmousetrack);
      end
     
      % check whether mouse is in the AXES (necessary for events
      % when mouse outside the 
      if (mousexy(1) >= xlimit(1)) && (mousexy(1) <= xlimit(2)) && ...
             (mousexy(2) >= ylimit(1)) && (mousexy(2) <= ylimit(2))
      else
         % showinfo('Mouse outside axis...');
        return;
      end
      
      % check whether the mouse is on data region
      if (mousexy(1) >= 1) && (mousexy(1) <= sas.imgdata(sas.iplot(1)).im_size(2)) && ...
             (mousexy(2) >= 1) && (mousexy(2) <= sas.imgdata(sas.iplot(1)).im_size(1))
         value =  sas.imgdata(sas.iplot(1)).im(fix(mousexy(2)), fix(mousexy(1)));
      else
         value = NaN;
      end
      
      % show the coordinate
      q = 4*pi*sin(atan(norm(mousexy-[sas.imgdata(sas.iplot(1)).X_cen, ...
                          sas.imgdata(sas.iplot(1)).Y_cen])/ ...
                        sas.imgdata(sas.iplot(1)).Spec_to_Phos)/2)/ ...
          sas.imgdata(sas.iplot(1)).X_Lambda;
      d = 2*pi/q;
      set(sas.hplotact.mouseinfo, 'String', sprintf(['> X:%7.2f; ' ...
                          'Y:%7.2f; I:%+9.2f; Q:%7.4f; d:%9.2f'], ...
                        mousexy(1), mousexy(2), value, q, d));
      
      % mask mode
      if (get(sas.himganal.modepanel, 'SelectedChild') == 2) ...
             && ~isempty(sas.imgdata(sas.iplot(1)).mask_polygonxy)
         axes(sas.activeaxes);
         sas.hmousetrack(1) = plot([sas.imgdata(sas.iplot(1)).mask_polygonxy(end,1), mousexy(1), ...
                             sas.imgdata(sas.iplot(1)).mask_polygonxy(1,1)], ...
                                [sas.imgdata(sas.iplot(1)).mask_polygonxy(end,2), mousexy(2), ...
                             sas.imgdata(sas.iplot(1)).mask_polygonxy(1,2)], ...
                                   'w+--', 'MarkerSize', 10);
      end
      
      % update the zoomaxes
      if (sas.imgdata(sas.iplot(1)).plotopt.zoom == 1) && (sas.activeaxes == sas.imaxes)
         set(sas.zoomaxes, 'xlim', mousexy(1)+[-0.5*sas.imgdata(sas.iplot(1)).plotopt.zoomsize, ...
                             0.5*sas.imgdata(sas.iplot(1)).plotopt.zoomsize], 'ylim', ...
                           mousexy(2)+[-0.5*sas.imgdata(sas.iplot(1)).plotopt.zoomsize, ...
                             0.5*sas.imgdata(sas.iplot(1)).plotopt.zoomsize]);
         % axis equal
      end
      if (sas.activeaxes == sas.imaxes);
         sas.mousexy=mousexy;
      end
      
      guidata(hObject, sas);
   end
   
   function gui_events_mouseclick(hObject, eventdata)
   % hObject    handle to minedit (see GCBO)
   % eventdata  reserved - to be defined in a future version of MATLAB
      sas = guidata(hObject);
      if isempty(sas.iplot) || (sas.iplot(1) == 0);
         return;
      end
      
      mousexy = get(sas.activeaxes, 'CurrentPoint');
      mousexy = mousexy(1,1:2);
      xlimit=get(sas.activeaxes, 'XLIM');
      ylimit=get(sas.activeaxes, 'YLIM');
      
      % check whether the click is on the active AXES
      if (mousexy(1) >= xlimit(1)) && (mousexy(1) <= xlimit(2)) && ...
             (mousexy(2) >= ylimit(1)) && (mousexy(2) <= ylimit(2))
      elseif (sas.activeaxes == sas.zoomaxes)
         sas.activeaxes = sas.imaxes; % change to the main axis
         sas.imgdata(sas.iplot(1)).plotopt.zoom=1;
         guidata(hObject, sas);
         return;
      else 
         return;
      end
      set(sas.hfig, 'Pointer', 'Watch');
      
      % handles left click
      if strcmpi(get(sas.hfig, 'SelectionType'), 'normal')
         % single click mode or in zoomaxes: get the point!
         if (sas.mousetwoclick == 0) || (sas.activeaxes == sas.zoomaxes)
            switch get(sas.himganal.modepanel, 'SelectedChild')
               case 1 % calibrant ringxy
                  sas.imgdata(sas.iplot(1)).calib_ringxy = [sas.imgdata(sas.iplot(1)).calib_ringxy; mousexy];
                  set(sas.himganal.calib_ringxy, 'Value', ...
                                    length(sas.imgdata(sas.iplot(1)).calib_ringxy(:,1)), ...
                                    'String', num2str(sas.imgdata(sas.iplot(1)).calib_ringxy, ...
                                                      ['(%7.2f, %7.2f)']));
                  plot(sas.imaxes, mousexy(1), mousexy(2), 'w+', ...
                       'MarkerSize', 10);
                  plot(sas.zoomaxes, mousexy(1), mousexy(2), 'w+', ...
                       'MarkerSize', 10);

               case 2 % mask polygon
                  sas.imgdata(sas.iplot(1)).mask_polygonxy = [sas.imgdata(sas.iplot(1)).mask_polygonxy; mousexy];
                  set(sas.himganal.mask_polygonxy, 'Value', ...
                                    length(sas.imgdata(sas.iplot(1)).mask_polygonxy(:,1)), ...
                                    'String', num2str(sas.imgdata(sas.iplot(1)).mask_polygonxy, ...
                                                      ['(%7.2f, %7.2f)']));
                  
                  sasimg_plot(sas.imgdata(sas.iplot(1)), [], ...
                              struct_assign(struct('im', 0, 'iq', 0, 'MaskI', 1), sas.imgdata(sas.iplot(1)).plotopt), ...
                              'imaxes', sas.imaxes, 'zoomaxes', ...
                              sas.zoomaxes, 'iqaxes', sas.iqaxes);
               otherwise
                  showinfo(['Mouse clicking not yet supported in this mode']);
            end
         end
         % two click mode: toggle the activeaxes and zoom
         if (sas.mousetwoclick == 1)
            if (sas.activeaxes == sas.imaxes)
               % set active axes
               sas.imgdata(sas.iplot(1)).plotopt.mousexy = mousexy;
               %               sas.imgdata(sas.iplot(1)).plotopt.zoom=0;
               sas.activeaxes = sas.zoomaxes;
            else
               % reset the active axes
               %               sas.imgdata(sas.iplot(1)).plotopt.zoom=1;
               sas.activeaxes = sas.imaxes;
            end
         end
         guidata(hObject, sas);
      end
      
      % handles double click button
      if strcmpi(get(sas.hfig, 'SelectionType'), 'Open')
         switch get(sas.himganal.modepanel, 'SelectedChild')
            case 1 % calibrant ring
                   % nothing to do in the calibrant ring mode
            case 2 % mask mode (end of selection)
            otherwise
               showinfo(['Double clicking not yet supported in ' ...
                         'this mode']);
         end
      end
      set(sas.hfig, 'Pointer', 'Arrow');
   end
end
