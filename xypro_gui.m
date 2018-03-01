function varargout = xypro_gui(xydata, varargin)
%        varargout = xypro_gui(xydata, varargin)
%             xydata can be empty, a file name, a cell array of file
%             names or a xypro structure

   % initialize xydata
   global xc
   xc.xydata = []; %xypro_init({'GT20CNTNa150_osmoforce.dat', ...
                   %    'GT20CNTNa1000_osmoforce.dat'});
   if exist('xydata', 'var') && ~isempty(xydata)
      if isstruct(xydata)
         xc.xydata = xydata;
      elseif ischar(xydata) || iscellstr(xydata)
         xc.xydata = xypro_init(xydata);
      else
         showinfo('parameter needs to be file name(s) or xybot structure');
      end
   end

   % GUI section
   fig_size = [1200,700];
   scr_size = get(0,'ScreenSize');
   leftpanel_width = 260;
   rightpanel_width = 200;
   edit_properties = {'Style', 'Edit', 'BackgroundColor', 'w', ...
                      'Position', [10, 10, 20, 10]};
   
   xc.hfig = figure('Position', [scr_size(3)-fig_size(1)-50, ...
                       scr_size(4)-fig_size(2)-150, fig_size(1), ...
                       fig_size(2)], 'Name', 'xypro_gui', 'Resize', ...
                    'on', 'NumberTitle', 'off', 'Visible', 'off');
   set(xc.hfig, 'DefaultAxesFontSize', 11, 'DefaultAxesFontWeight', ...
                'Normal', 'DefaultAxesFontName', 'Times', ...
                'DefaultAxesLineWidth', 1, 'DefaultAxesXMinorTick', ...
                'on', 'DefaultAxesYMinorTick', 'ON', 'DefaultAxesBox', ...
                'ON', 'DefaultAxesNextPlot', 'Add', ...
                'DefaultLineLineWidth', 1, 'DefaultLineMarkerSize', ...
                5, 'DefaultTextFontSize', 11, 'DefaultTextFontWeight', ...
                'Normal', 'DefaultAxesFontName', 'Times');

   uiextras.set(xc.hfig, 'DefaultHBoxBackgroundColor', [0.3,0.3,0,3]);
   uiextras.set(xc.hfig, 'DefaultTabPanelTitleColor', 'b');
   uiextras.set(xc.hfig, 'DefaultBoxFontSize', 10);
   uiextras.set(xc.hfig, 'DefaultHBoxPadding', 3);
   
   % divide the main panel into left and right
   hMainPanel = uiextras.HBoxFlex('Parent', xc.hfig);
   hLeftPanel =  uiextras.VBox('Parent', hMainPanel);
   hMidPanel =  uiextras.VBox('Parent', hMainPanel);
   hRightPanel = uiextras.TabPanel('Parent', hMainPanel);
   set(hMainPanel, 'Sizes', [-1,-3, rightpanel_width], 'Spacing', 4);
   
   % create each panel
   xc.hdatapro = gui_create_datapro('parent', hLeftPanel);
   xc.hplotrun = gui_create_plotrun('parent', hMidPanel);

   hcurvefitpanel = uiextras.Panel('Parent', hRightPanel);
   hsasapanel = uiextras.Panel('Parent', hRightPanel);
   xc.hfitpar = gui_create_fitpar([], 'parent', uiextras.VBox('Parent', hcurvefitpanel));
   hRightPanel.TabNames = {'xyfit', 'sasa'};
   hRightPanel.SelectedChild = 1;
   
   set(xc.hfig, 'Visible', 'on');

   % save data and update GUIs
   guidata(xc.hfig, xc);
   gui_update(xc, 'update_all');
   
   function hdatapro = gui_create_datapro(varargin)
      parse_varargin(varargin);
      if ~exist('parent', 'var') || isempty(parent)
         parent =  uiextras.VBox('Parent', figure());
      end

      gui_settings = {'CallBack', @gui_events_datapro};

      % 1) data list
      hpanel = uiextras.TabPanel('Parent', parent);
      hdirpanel = uiextras.Panel('Parent', hpanel);
      hdatapanel = uiextras.Panel('Parent', hpanel);
      hpanel.TabNames = {'FileSys', 'XYdata'};
      hpanel.SelectedChild = 1;
      
      % Panel #1) dir browser
      hdir = dirbrowser_gui('Parent', hdirpanel, 'LoadFileFunc', ...
                            @dirbrowser_loadfile);
      
      % Panel #2) data list with some controls
      hdatabox = uiextras.VBox('Parent', hdatapanel);
            
      % data list
      hdatapro.datalist = uicontrol('Parent', hdatabox, 'Style', ...
                                    'ListBox', 'Max', 100, 'Min', ...
                                    1, 'String', 'no data available', ...
                                    'BackgroundColor', 'w', ...
                                    'ForegroundColor', [0,0.5,0], ...
                                    'FontWeight', 'Normal', gui_settings{:});
      
      
      % data loading
      hbox = uiextras.Grid('Parent', hdatabox);
      htext = uicontrol('Parent', hbox, 'Style', 'Text', 'String', 'Data format:');
      hdatapro.dataformat = uicontrol('Parent', hbox, 'Style', ...
                                      'PopUpMenu', 'String', {'SPEC', ...
                          'XY', 'NanoVUE'}, 'Tag', 'dataformat', ...
                                      gui_settings{:}, 'Enable', 'off');
      
      hdatapro.loadfile = uicontrol('Parent', hbox, 'String', ['Load ' ...
                          'File'], gui_settings{:});
      hdatapro.loadsetup = uicontrol('Parent', hbox, 'String', ...
                                     ['Load Setup'], gui_settings{:});
      hdatapro.savematfile = uicontrol('Parent', hbox, 'String', 'Save .mat', gui_settings{:});
      hdatapro.loadmatfile = uicontrol('Parent', hbox, 'String', 'Load .mat', gui_settings{:});

      set(hbox, 'ColumnSizes', [-1,-1,-1], 'RowSizes', [-1,-1]);

      % datalist manipulation
      hbox = uiextras.Grid('Parent', hdatabox);
      %htext = uicontrol('Parent', hpanel, 'Style', 'Text', 'String', 'x col:');
      hdatapro.rmdata = uicontrol('Parent', hbox, 'String', ['Rm ' ...
                          'Data'], gui_settings{:});
      hdatapro.gui2selectdata = uicontrol('Parent', hbox, 'String', ...
                                          'GUI->Select', gui_settings{:});
      hdatapro.gui2alldata = uicontrol('Parent', hbox, 'String', ...
                                          'GUI->All', gui_settings{:});
      set(hdatabox, 'Sizes', [-1,50,24]);

      % 3) data correction
      hpanel = uiextras.Panel('Parent', parent, 'Title', ['data processing']);
      hpanel = uiextras.TabPanel('Parent', hpanel);
      hsetupbox = uiextras.VBox('Parent', hpanel);
      hmathbox = uiextras.VBox('Parent', hpanel);
      hsasbox = uiextras.VBox('Parent', hpanel);
      hosmobox = uiextras.VBox('Parent', hpanel);
      hpanel.TabNames = {'setup', 'math', 'sas', 'osmo'};
      hpanel.SelectedChild = 1;

      % Tab Panel #1: set up data
      % column setup      
      hdatapro.gui2newdata = uicontrol('Parent', hsetupbox, 'Style', ...
                                       'CheckBox', 'String', 'GUI->New loaded file(s)', ...
                                       'Value', 0, 'Tag', 'gui2newdata', ...
                                       gui_settings{:});

      hpanel = uiextras.HBox('Parent', hsetupbox);
      htext = uicontrol('Parent', hpanel, 'Style', 'Text', 'String', 'x col:');
      hdatapro.xcol = uicontrol('Parent', hpanel, 'Style', 'PopUpMenu', ...
                                'String', num2lege(1:4), 'Tag', ...
                                'xcol', gui_settings{:});
      htext = uicontrol('Parent', hpanel, 'Style', 'Text', 'String', 'y col:');
      hdatapro.ycol = uicontrol('Parent', hpanel, 'Style', 'PopUpMenu', ...
                                'String', num2lege(1:4), 'Tag', ...
                                'ycol', gui_settings{:});
      htext = uicontrol('Parent', hpanel, 'Style', 'Text', 'String', 'e col:');
      hdatapro.ecol = uicontrol('Parent', hpanel, 'Style', 'PopUpMenu', ...
                                'String', num2lege(1:4), 'Tag', ...
                                'ecol', gui_settings{:});

      hpanel = uiextras.HBox('Parent', hsetupbox);
      hdatapro.sortx = uicontrol('Parent', hpanel, 'String', ['sort ' ...
                          'xcol'], 'Style', 'CheckBox', 'Value', 0, ...
                                'Tag', 'sortx', gui_settings{:});
      htext = uicontrol('Parent', hpanel, 'Style', 'Text', 'String', 'id:');
      hdatapro.id = uicontrol('Parent', hpanel, 'String', 1, 'Tag', ...
                             'id', edit_properties{:}, gui_settings{:});

      % min range
      hpanel = uiextras.HBox('Parent', hsetupbox);
      htext = uicontrol('Parent', hpanel, 'Style', 'Text', 'String', 'imin:');
      hdatapro.imin = uicontrol('Parent', hpanel, 'String', 1, 'Tag', 'imin', ...
                                edit_properties{:}, gui_settings{:}, ...
                                'Enable', 'off');
      htext = uicontrol('Parent', hpanel, 'Style', 'Text', 'String', 'imax:');
      hdatapro.imax = uicontrol('Parent', hpanel, 'String', 1, 'Tag', 'imax', ...
                                edit_properties{:}, gui_settings{:}, ...
                                'Enable', 'off');
      % max range
      hpanel = uiextras.HBox('Parent', hsetupbox);
      htext = uicontrol('Parent', hpanel, 'Style', 'Text', 'String', 'xmin:');
      hdatapro.xmin = uicontrol('Parent', hpanel, 'String', 1, 'Tag', 'xmin', ...
                                edit_properties{:}, gui_settings{:});
      htext = uicontrol('Parent', hpanel, 'Style', 'Text', 'String', 'xmax:');
      hdatapro.xmax = uicontrol('Parent', hpanel, 'String', 1, 'Tag', 'xmax', ...
                                edit_properties{:}, gui_settings{:});
      
      % offset and scale
      hpanel = uiextras.HBox('Parent', hsetupbox);
      htext = uicontrol('Parent', hpanel, 'Style', 'Text', 'String', 'offset:');
      hdatapro.offset = uicontrol('Parent', hpanel, 'Style', 'Edit', ...
                                  'String', 0, 'Tag', 'offset', ...
                                  edit_properties{:}, gui_settings{:});
      htext = uicontrol('Parent', hpanel, 'Style', 'Text', 'String', 'scale:');
      hdatapro.scale = uicontrol('Parent', hpanel, 'Style', 'Edit', ...
                                 'String', 1, 'Tag', 'scale', ...
                                 edit_properties{:}, gui_settings{:});

      % Tab Panel #2: math operations
      % smooth and method
      hpanel = uiextras.HBox('Parent', hmathbox);
      hdatapro.smooth = uicontrol('Parent', hpanel, 'Style', ...
                                  'CheckBox', 'String', 'smooth', ...
                                  'Tag', 'smooth');
      hdatapro.smooth_span = uicontrol('Parent', hpanel, 'String', ...
                                       '5', 'Tag', 'smooth_span', ...
                                       edit_properties{:}, gui_settings{:});
      hdatapro.smooth_type = uicontrol('Parent', hpanel, 'Style', 'PopUpMenu', ...
                                'String', {'moving', 'lowess', 'loess', 'sgolay', ...
                    'rlowess', 'rloess'}, 'Tag', 'smooth_type', gui_settings{:});
      hdatapro.smooth_degree = uicontrol('Parent', hpanel, 'String', ...
                                         3, 'Tag', 'smooth_degree', ...
                                         edit_properties{:}, gui_settings{:});

      hpanel = uiextras.HBox('Parent', hmathbox);
      htext = uicontrol('Parent', hpanel, 'Style', 'Text', 'String', ...
                        'smooth range:');
      hdatapro.smooth_range = uicontrol('Parent', hpanel, 'String', ...
                                       '[0,1]', 'Tag', 'smooth_range', ...
                                       edit_properties{:}, gui_settings{:});
      % match and range
      hpanel = uiextras.HBox('Parent', hmathbox);
      hdatapro.match = uicontrol('Parent', hpanel, 'Style', 'CheckBox', ...
                                 'String', 'match data:', 'Tag', 'match', ...
                                 gui_settings{:});
      hdatapro.match_scale = uicontrol('Parent', hpanel, 'Style', ...
                                       'CheckBox', 'String', 'scale', ...
                                       'Tag', 'match_scale', gui_settings{:});
      hdatapro.match_offset = uicontrol('Parent', hpanel, 'Style', ...
                                        'CheckBox', 'String', 'offset', ...
                                        'Tag', 'match_offset', gui_settings{:});
      set(hpanel, 'Sizes', [-2,-1,-1]);
      hpanel = uiextras.HBox('Parent', hmathbox);
      uicontrol('Parent', hpanel, 'Style', 'Text', 'String', ...
                'reference data:');
      hdatapro.match_data = uicontrol('Parent', hpanel, 'Style', ...
                                      'PopUpMenu', 'String', {'[1,1]', ...
                          '[0,0]'}, 'Tag', 'match_data', gui_settings{:});

      hpanel = uiextras.HBox('Parent', hmathbox);
      htext = uicontrol('Parent', hpanel, 'Style', 'Text', 'String', ...
                        'match range:');
      hdatapro.match_range = uicontrol('Parent', hpanel, 'String', ...
                                      '[0,1]', 'Tag', 'match_range', ...
                                      edit_properties{:}, gui_settings{:});
      % data command str
      hpanel = uiextras.HBox('Parent', hmathbox);
      htext = uicontrol('Parent', hpanel, 'Style', 'Text', 'String', ...
                        'math string:');
      hdatapro.mathstring = uicontrol('Parent', hpanel, 'Style', ...
                                      'Edit', 'String', ['x=x; y=y; ' ...
                          'e=e;'], 'Tag', 'mathstring', edit_properties{:}, ...
                                      gui_settings{:});

      % Tab Panel #3: sas setup box
      hbox = uiextras.HBox('Parent', hsasbox);
      htext = uicontrol('Parent', hbox, 'Style', 'Text', 'String', 'molweight');
      htext = uicontrol('Parent', hbox, 'Style', 'Text', 'String', 'concen.');
      htext = uicontrol('Parent', hbox, 'Style', 'Text', 'String', 'ionconcen');
      
      hbox = uiextras.HBox('Parent', hsasbox);
      hdatapro.molweight = uicontrol('Parent', hbox, 'String', ...
                                       100, 'Tag', 'molweight', ...
                                       edit_properties{:}, gui_settings{:});
      hdatapro.concentration = uicontrol('Parent', hbox, 'String', ...
                                         '0.1', 'Tag', 'concentration', ...
                                         edit_properties{:}, gui_settings{:});
      hdatapro.ionstrength = uicontrol('Parent', hbox, 'String', ...
                                       10, 'Tag', 'ionstrength', ...
                                       edit_properties{:}, gui_settings{:});

%      htext = uicontrol('Parent', hbox, 'Style', 'Text', 'String', 'dmax:');
%      hdatapro.dmax = uicontrol('Parent', hbox, 'String', 100, 'Tag', ...
%                                'dmax', edit_properties{:}, gui_settings{:});

      hpanel = uiextras.Panel('Parent', hsasbox, 'Title','Transform', 'Padding',0);      
      hbox = uiextras.HBox('Parent', hpanel);
      hdatapro.guinier = uicontrol('Parent', hbox, 'Style', 'CheckBox', ...
                                   'String', 'Guinier', ...
                                   'Tag', 'guinier', gui_settings{:});

      hdatapro.kratky = uicontrol('Parent', hbox, 'Style', 'CheckBox', ...
                                  'String', 'Kratky', 'Tag', ...
                                  'kratky', gui_settings{:});
      hdatapro.porod = uicontrol('Parent', hbox, 'Style', 'CheckBox', ...
                                 'String', 'Porod', 'Tag', ...
                                 'porod', gui_settings{:});

      hpanel = uiextras.Panel('Parent', hsasbox, 'Title','Guinier check', 'Padding',0);      
      hbox = uiextras.HBox('Parent', hpanel);
      htext = uicontrol('Parent', hbox, 'Style', 'Text', 'String', 'Q range:');
      hdatapro.guinier_range = uicontrol('Parent', hbox, 'String', ...
                                         '[0.003, 0.06]', 'Tag', 'guinier_range', ...
                                         edit_properties{:}, gui_settings{:});
      hdatapro.guinier_check = uicontrol('Parent', hbox, 'String', ...
                                         'Check It', gui_settings{:});
      set(hbox, 'Sizes', [-1,-2,-1]);
      
      hbox = uiextras.HBox('Parent', hsasbox);
      hbox = uiextras.HBox('Parent', hsasbox);

      set(hsasbox, 'Sizes', [-1,-1,-2,-2,-1,-1]);
      
      % Tab Panel #4: osmotic setup box
      hbox = uiextras.HBox('Parent', hosmobox);
      hdatapro.pzero_spacing = uicontrol('Parent', hbox, 'Style', 'Checkbox', 'String', ...
                        'P=0 spacing:', gui_settings{:}, 'Value', 0);

      hdatapro.equilibrium_spacing = uicontrol('Parent', hbox, 'String', ...
                                        0.01, 'Tag', 'molweight', ...
                                        edit_properties{:}, gui_settings{:});

      hbox = uiextras.HBox('Parent', hosmobox);
      hdatapro.osmomodel_calc = uicontrol('Parent', hbox, 'String', ...
                                          'calc osmo', gui_settings{:});
      hdatapro.osmomodel_fit = uicontrol('Parent', hbox, 'String', ...
                                         'fit osmo', gui_settings{:});

      hbox = uiextras.HBox('Parent', hosmobox);
      hbox = uiextras.HBox('Parent', hosmobox);
      %      hbox = uiextras.HBox('Parent', hosmobox);
%      hdatapro.osmo_autoadjust = uicontrol('Parent', hbox, 'Style', 'Checkbox', 'String', ...
%                        'auto adjust:', gui_settings{:}, 'Value', 1);
%      
%      htext = uicontrol('Parent', hbox, 'Style', 'Text', 'String', ...
%                        'errorbar');
%      hdatapro.osmo_errorstring = uicontrol('Parent', hbox, ...
%                                            edit_properties{:}, ...
%                                            gui_setttings{:});
     
      set(parent, 'Sizes', [-1,210]);
   
   end

   function dirbrowser_loadfile(filenames)
      gui_events_datapro(xc.hdatapro.loadfile, filenames);
   end
   
   function gui_events_datapro(hObject, eventdata, varargin)
      xc = guidata(hObject);
      %set(xc.hfig, 'Pointer', 'Watch')

      if isempty(xc.xydata)
         disp('Please load data first...')
         iselect=0;
      else
         iselect = find([xc.xydata(:).select]);
         if isempty(iselect); iselect=0; end
      end
      hdatapro = xc.hdatapro;
      
      switch hObject
         case hdatapro.loadfile
            % a list file names can be passed as eventdata
            if exist('eventdata', 'var') && ~isempty(eventdata)
               filenames = eventdata;
            else
               filenames = uigetfile();
            end
            
            if ~isempty(filenames)
               %dataformat_list = get(hdatapro.dataformat, 'String');
               %dataformat = dataformat_list{get(hdatapro.dataformat, 'Value')};
               dataformat = '';
               % add the data
               if ~isempty(xc.xydata) && (get(hdatapro.gui2newdata,'Value') == 1)
                  % copy the settings from currently selected
                  if (iselect ~=0) 
                     itempl = iselect(1);
                  else
                     itempl = 1;
                  end
                  xydata_new = repmat(xc.xydata(itempl), 1, length(filenames));
                  [xydata_new.filename] = deal(filenames{:});
                  [xydata_new.dataformat] = deal(dataformat);
                  xydata_new = xypro_init(xydata_new);
               else
                  xydata_new = xypro_init(filenames, 'dataformat', dataformat);
               end
               xc.xydata = [xc.xydata, xypro_dataprep(xydata_new)];
               guidata(hObject, xc);
               gui_update(xc, 'update_all');
            end
         case hdatapro.datalist
            iselect_gui = get(hdatapro.datalist, 'Value');
            if (length(iselect_gui) == length(iselect)) && ...
                   (total(abs(iselect_gui-iselect)) == 0)
               disp('No changes in selection!')
            else
               [xc.xydata.select] = deal(0);
               [xc.xydata(iselect_gui).select] = deal(1);
               guidata(hObject, xc);
               disp(['Select data sets: ' num2str(iselect_gui)])
            end
            % if the first selected item didn't change, only update
            % plot, no need to update GUI
            if iselect_gui(1) == iselect(1)
               gui_update(xc, 'update_all');
            else
               gui_update(xc, 'update_all');
            end
         case hdatapro.loadsetup
            % needs improvement!!!!!!
            xydata.filename = uigetfile();
            if (xydata.filename ~= 0)
               specdata = specdata_readfile(xydata.filename);
               xydata = struct_assign(specdata, xydata, 'append');
               xc.xydata = xydata;
               guidata(hObject, xc);
            end
         case hdatapro.dataformat
            
         case hdatapro.gui2newdata

         case hdatapro.savematfile
            filename = uiputfile();
            if (filename == 0)
               showinfo('No file name given!');
               return
            else
               showinfo(['Saving xc.xydata to ' filename]);
            end
            xydata = xc.xydata;
            save(filename, 'xydata');
            
         case hdatapro.loadmatfile
            filename = uigetfile();
            if (filename == 0)
               showinfo('No file name given!');
               return
            else
               showinfo(['Loading xydata from ' filename]);
            end

            matdata = load(filename, '-mat', 'xydata');
            xc.xydata = matdata.xydata;
            guidata(hObject, xc);
            gui_update(xc, 'update_all');
            
         case hdatapro.rmdata
            if (iselect(1) ~=0)
               xc.xydata(iselect) = [];
               guidata(hObject, xc);
               gui_update(xc, 'update_all');
            else
               disp('No data is selected for removal!');
            end
         case hdatapro.gui2selectdata
            if (iselect(1) ~=0)
               gui_fields = intersect(fieldnames(hdatapro), ...
                                     fieldnames(xc ...
                                                .xydata(iselect(1))));
               gui_stru = cell2struct(num2cell(ones(numel(gui_fields),1)), ...
                                      gui_fields,1);
               gui_stru = struct_assign(xc.xydata(iselect(1)), ...
                                        gui_stru, 'append', 0);
               for i=1:length(iselect);
                  xc.xydata(iselect(i)) = struct_assign(gui_stru, ...
                                          xc.xydata(iselect(i)), 'append', 0);
               end
               xc.xydata(iselect) = xypro_dataprep(xc.xydata(iselect));
               guidata(hObject, xc);
               gui_update(xc, 'update_plot');
            else
               disp('No data is selected for GUI -> Selected data!');
            end
         case hdatapro.gui2alldata
            if (iselect(1) ~=0)
               gui_fields = intersect(fieldnames(hdatapro), ...
                                     fieldnames(xc ...
                                                .xydata(iselect(1))));
               gui_stru = cell2struct(num2cell(ones(numel(gui_fields),1)), ...
                                      gui_fields,1);
               gui_stru = struct_assign(xc.xydata(iselect(1)), ...
                                        gui_stru, 'append', 0);
               iselect = 1:length(xc.xydata);
               for i=1:length(iselect);
                  xc.xydata(iselect(i)) = struct_assign(gui_stru, ...
                                          xc.xydata(iselect(i)), 'append', 0);
               end
               xc.xydata(iselect) = xypro_dataprep(xc.xydata(iselect));
               guidata(hObject, xc);
               gui_update(xc, 'update_plot');
            else
               disp('Sorry! At least one data needs to be selected for GUI -> all data!');
            end
            
         case hdatapro.guinier_check
            if (iselect(1) ~= 0)
               rgfit_auto(xc.xydata(iselect(1)).data, 'qmin', ...
                          xc.xydata(iselect(1)).guinier_range(1));
            end
         otherwise
            wtype = upper(get(hObject, 'Style'));
            tagname = get(hObject, 'Tag');
            switch wtype
               case 'EDIT'
                  if (hObject == hdatapro.mathstring)
                     [xc.xydata(iselect).mathstring] = deal(get(hObject,'String'));
                  else
                     [xc.xydata(iselect).(tagname)] = deal(str2num(get(hObject, 'String')));
                  end
                  disp(['set ' tagname ' to ' get(hObject, 'String')])
               case 'CHECKBOX'
                  [xc.xydata(iselect).(tagname)] = deal(get(hObject, 'Value'));
                  disp(['set ' tagname ' to ' num2str(get(hObject, 'Value'))])
               case 'POPUPMENU'
                  newvalue = get(hObject, 'Value');
                  [xc.xydata(iselect).(tagname)] = deal(newvalue);
                  menustr = get(hObject, 'String');
                  disp(['set ' tagname ' to ' menustr{newvalue}]);
                  if (hObject == hdatapro.match_data);
                     switch newvalue
                        case 1
                           [xc.xydata(iselect).match_data] = deal([1,1]);
                        case 2
                           [xc.xydata(iselect).match_data] = deal([0,0]);
                        otherwise
                           [xc.xydata(iselect).match_data] = ...
                               deal(xc.xydata(newvalue-2).data);
                     end
                  end
               otherwise
                  showinfo(['Events from this widget: ' get(hObject, 'Type') ...
                            'are ignored!']);
            end
            xc.xydata(iselect) = xypro_dataprep(xc.xydata(iselect));
            guidata(hObject, xc);
            gui_update(xc, 'update_plot');
      end
      % set(xc.hfig, 'Pointer', 'Arrow')
   end
   
   function hplotrun = gui_create_plotrun(varargin);
      parse_varargin(varargin);
      if ~exist('parent', 'var') || isempty(parent)
         parent =  uiextras.VBox('Parent', figure());
      end
       
      gui_settings = {'CallBack', @gui_events_plotrun};
      
      % 1) visualization axis
      hpanel = uiextras.Panel('Parent', parent, 'Title','PLOT', 'Padding',0);
      hbox = uiextras.Grid('Parent', hpanel, 'Spacing', 40, 'Padding', 4);
      hplotrun.autoylim = uicontrol('Parent', hbox, 'String', ...
                                      'Y', gui_settings{:});
      hplotrun.autoxylim = uicontrol('Parent', hbox, 'String', ...
                                      'XY', gui_settings{:});
      hplotrun.axes = axes('Parent', hbox); % xlabel('x'); ylabel('y');
      hplotrun.autoxlim = uicontrol('Parent', hbox, 'String', ...
                                      'X', gui_settings{:});
      set(hbox, 'ColumnSizes', [20,-1], 'RowSizes', [-1,20]);
      
      % 2) plot options box
      hpanel = uiextras.Panel('Parent', parent, 'Title', ['Options']);
      hpanel = uiextras.Grid('Parent', hpanel);
      hplotrun.liveupdate = uicontrol('Parent', hpanel, 'Style', ...
                                      'CheckBox', 'String', ...
                                      'LiveUpdate', 'Value', 1, ...
                                      'Tag', 'liveupdate', gui_settings{:});

      hplotrun.plotopt.grid = uicontrol('Parent', hpanel, 'Style', ...
                                          'CheckBox', 'String', ...
                                          'Grid', 'Value', 1, gui_settings{:});
      hbox = uiextras.HBox('Parent', hpanel, 'Padding', 0);
      hplotrun.plotopt.legend = uicontrol('Parent', hbox, 'Style', ...
                                          'CheckBox', 'String', ...
                                          'Legend', 'Value', 1, gui_settings{:});
      hplotrun.plotopt.legendfontsize = uicontrol('Parent', hbox, 'Style', ...
                                              'PopUpMenu', 'String', ...
                                              num2lege(1:23), 'Value', 10, gui_settings{:});
      set(hbox, 'Sizes', [-2,-1]);
      hplotrun.plotopt.errorbar = uicontrol('Parent', hpanel, 'Style', ...
                                            'CheckBox', 'String', ...
                                            'ErrorBar', gui_settings{:});
      hbox = uiextras.HBox('Parent', hpanel, 'Padding', 0);
      hplotrun.plotopt.marker = uicontrol('Parent', hbox, 'Style', ...
                                          'CheckBox', 'String', ...
                                          'Marker', 'Value', 0, gui_settings{:});
      hplotrun.plotopt.markersize = uicontrol('Parent', hbox, 'Style', ...
                                              'PopUpMenu', 'String', ...
                                              num2lege(1:16), 'Value', 5, gui_settings{:});
      set(hbox, 'Sizes', [-2,-1]);
      hbox = uiextras.HBox('Parent', hpanel, 'Padding', 0);
      hplotrun.plotopt.line = uicontrol('Parent', hbox, 'Style', ...
                                        'CheckBox', 'String', 'Line', ...
                                        'Value', 1, gui_settings{:});
      hplotrun.plotopt.linewidth = uicontrol('Parent', hbox, 'Style', ...
                                             'PopUpMenu', 'String', ...
                                             num2lege(1:16), 'Value', 2, gui_settings{:});
      set(hbox, 'Sizes', [-2,-1]);
      hplotrun.plotopt.logx = uicontrol('Parent', hpanel, 'Style', ...
                                        'CheckBox', 'String', 'Log(x)', ...
                                        'Value', 0, gui_settings{:});
      hplotrun.plotopt.logy = uicontrol('Parent', hpanel, 'Style', ...
                                        'CheckBox', 'String', 'Log(y)', ...
                                        'Value', 0, gui_settings{:});
      set(hpanel, 'ColumnSizes', [-1,-1,-1,-1], 'RowSizes', [-1,-1]);

      % 3) plot data box
      hpanel = uiextras.Panel('Parent', parent, 'Title', ['Data']);
      hpanel = uiextras.Grid('Parent', hpanel);
      hplotrun.dataselect.rawdata = uicontrol('Parent', hpanel, 'Style', ...
                                      'CheckBox', 'String', 'rawdata', gui_settings{:});
      hplotrun.dataselect.data = uicontrol('Parent', hpanel, 'Style', ...
                                      'CheckBox', 'String', 'data', ...
                                           'Value', 1, gui_settings{:});
      hplotrun.dataselect.calcdata = uicontrol('Parent', hpanel, 'Style', ...
                                        'CheckBox', 'String', 'calcdata', gui_settings{:});
      hplotrun.dataselect.fitdata = uicontrol('Parent', hpanel, 'Style', ...
                                       'CheckBox', 'String', 'fitdata', gui_settings{:});

      hplotrun.dataselect.difdata = uicontrol('Parent', hpanel, 'Style', ...
                                       'CheckBox', 'String', 'difdata', gui_settings{:});

      hbox = uiextras.Empty('Parent', hpanel);
      
      hbox = uiextras.HBox('Parent', hpanel, 'Padding', 0);
      hplotrun.dataselect.dataprep = uicontrol('Parent', hbox, 'Style', ...
                                       'CheckBox', 'String', 'dataprep', gui_settings{:});
      hplotrun.dataselect.datapreplist = uicontrol('Parent', hbox, 'Style', ...
                                            'PopUpMenu', 'String', ...
                                            {'par1', 'par2'}, gui_settings{:});

      hbox = uiextras.HBox('Parent', hpanel, 'Padding', 0);
      hplotrun.dataselect.fitpar = uicontrol('Parent', hbox, 'Style', ...
                                       'CheckBox', 'String', 'fitpar', gui_settings{:});
      hplotrun.dataselect.fitparlist = uicontrol('Parent', hbox, 'Style', ...
                                          'PopUpMenu', 'String', ...
                                          {'par1', 'par2'}, gui_settings{:});

      
      set(hpanel, 'ColumnSizes', [-1,-1,-1,-1], 'RowSizes', [-1, -1]);

      % 4) action box
      hbox = uiextras.HBox('Parent', parent);
      %hplotrun.undo = uicontrol('Parent', hbox, 'String', 'Undo', gui_settings{:});
      hplotrun.plot = uicontrol('Parent', hbox, 'String', 'Plot', gui_settings{:});
      %hplotrun.prepare = uicontrol('Parent', hbox, 'String', 'Prepare', gui_settings{:});
      hplotrun.save = uicontrol('Parent', hbox, 'String', 'Save', gui_settings{:});
      htmp = uiextras.HBox('Parent', hbox);
      htext = uicontrol('Parent', htmp, 'Style', 'text', 'String', 'xlabel:');
      hplotrun.xlabel = uicontrol('Parent', htmp, 'String', 'x', edit_properties{:});
      htext = uicontrol('Parent', htmp, 'Style', 'text', 'String', 'ylabel:');
      hplotrun.ylabel = uicontrol('Parent', htmp, 'String', 'y', edit_properties{:});
      htext = uicontrol('Parent', htmp, 'Style', 'text', 'String', 'File:');
      hplotrun.saveprefix = uicontrol('Parent', htmp, 'String', ...
                                      [datestr(now, 'yymmdd') 'xypro'], edit_properties{:});
      set(htmp, 'Sizes', [-1,-2,-1,-2,-1,-2]);
      set(hbox, 'Sizes', [-1,-1,-4]);
      set(parent, 'Sizes', [-1, 60,60,33]);
   end
   
   function gui_events_plotrun(hObject, eventdata, varargin)
      xc = guidata(hObject);
      set(xc.hfig, 'Pointer', 'Watch')
      iselect = find([xc.xydata(:).select]);
      hplotrun = xc.hplotrun;
      
      switch hObject
         %case hplotrun.undo
            %guidata(hObject, xc);
         case hplotrun.autoxlim
            axes(hplotrun.axes); xlim auto; legend show; legend boxoff;
         case hplotrun.autoylim
            axes(hplotrun.axes); ylim auto; legend show; legend boxoff;
         case hplotrun.autoxylim
            axes(hplotrun.axes); axis auto; legend show; legend boxoff;
         case hplotrun.plot
            % get settings: dataselect and plotopt
            dataselect = {};
            datanames = fieldnames(hplotrun.dataselect);
            for i=1:length(datanames)
               if (get(hplotrun.dataselect.(datanames{i}), 'Value') == 1)
                  dataselect = {dataselect{:} datanames{i}};
               end
            end
            plotopt = [];
            optnames = fieldnames(hplotrun.plotopt);
            for i=1:length(optnames)
               plotopt.(optnames{i})=get(hplotrun.plotopt.(optnames{i}), 'Value');
            end
            axes(hplotrun.axes); cla;
            xypro_plot(xc.xydata(iselect), 'dataselect', dataselect, ...
                       'plotopt', plotopt);
         case hplotrun.save
            saveprefix = get(hplotrun.saveprefix, 'String');
            assignin('base', ['xypro_' saveprefix], xc.xydata);
            showinfo(['save current data to workspace as: xypro_' saveprefix] );
            axes(hplotrun.axes); 
            xlabel(get(hplotrun.xlabel, 'String'));
            ylabel(get(hplotrun.ylabel, 'String'));
            saveps(hplotrun.axes, [saveprefix '.eps']);
            savepng(hplotrun.axes, [saveprefix '.png']);
            %            axes(hplotrun.axes);
            %            xlabel([]); ylabel([]);
         otherwise
            wtype = upper(get(hObject, 'Style'));
            tagname = get(hObject, 'Tag');
            switch wtype
               case 'EDIT'
               case {'CHECKBOX', 'POPUPMENU'}
               otherwise
                  showinfo(['Events from this widget: ' get(hObject, 'Type') ...
                            'are ignored!']);
            end
            if get(hplotrun.liveupdate, 'Value');
               showinfo('updating plot ...');
               gui_update(xc, 'update_plot');
            end
      end
      set(xc.hfig, 'Pointer', 'Arrow')
   end
   
   function hfitpar = gui_create_fitpar(fitpar_names, varargin)
      parse_varargin(varargin);
      if ~exist('parent', 'var') || isempty(parent)
         parent =  uiextras.VBox('Parent', figure());
      end

      gui_settings = {'CallBack', @gui_events_fitpar};
      hfitpar.top = parent;
      
      hbox = uiextras.HBox('Parent', parent);
      hfitpar.auto_calc = uicontrol('Parent', hbox, 'Style', ...
                                    'CheckBox', gui_settings{:}, ...
                                    'String', 'Auto_Calc', 'Tag', ...
                                    'auto_calc', 'Value', 1);
      hfitpar.auto_fit = uicontrol('Parent', hbox, 'Style', ...
                                    'CheckBox', gui_settings{:}, ...
                                    'String', 'Auto_Fit', 'Tag', ...
                                    'auto_fit', 'Value', 1);

      hbox = uiextras.HBox('Parent', parent);
      hfitpar.undo = uicontrol('Parent', hbox, 'String', 'undo', gui_settings{:});
      hfitpar.calculate = uicontrol('Parent', hbox, 'String', 'Calculate', gui_settings{:});
      hfitpar.xyfit = uicontrol('Parent', hbox, 'String', 'Fit', gui_settings{:});
      
      hbox = uiextras.HBox('Parent', parent);
      htext = uicontrol('Parent', hbox, 'Style', 'Text', 'String', ...
                        'Function:');
      hfitpar.func = uicontrol('Parent', hbox, 'Style', 'PopUpMenu', ...
                               'String', 'none', gui_settings{:});

      hbox = uiextras.HBox('Parent', parent);
      hfitpar.addfunc = uicontrol('Parent', hbox, 'String', 'Add Func:', ...
                               gui_settings{:});
      hfitpar.newfuncname = uicontrol('Parent', hbox, edit_properties{:});

      hbox = uiextras.HBox('Parent', parent);
      htext = uicontrol('Parent', hbox, 'Style', 'Text', 'String', ...
                        '#Parameters:');
      hfitpar.num_pars = uicontrol('Parent', hbox, 'Style', 'PopUpMenu', ...
                               'String', {'1'}, gui_settings{:}, ...
                                   'Tag', 'num_pars', 'UserData', 1);

      hbox = uiextras.HBox('Parent', parent);
      htext = uicontrol('Parent', hbox, 'Style', 'Text', 'String', ...
                        'Algorithm:');
      hfitpar.algorithm = uicontrol('Parent', hbox, 'Style', ...
                                    'PopUpMenu', 'String', 'none', ...
                                    gui_settings{:}, 'Tag', ...
                                    'ialgorithm', 'UserData', 1);

      hbox = uiextras.HBox('Parent', parent);
      htext = uicontrol('Parent', hbox, 'Style', 'Text', 'String', ...
                        'lambda:');
      hfitpar.lm_lambda = uicontrol('Parent', hbox, edit_properties{:}, ...
                               gui_settings{:}, 'Tag', 'lm_lambda', ...
                                    'UserData', 1);
      htext = uicontrol('Parent', hbox, 'Style', 'Text', 'String', 'maxiter:');
      hfitpar.maxiter = uicontrol('Parent', hbox, edit_properties{:}, ...
                                  gui_settings{:}, 'Tag', 'maxiter', ...
                                  'UserData', 1);

      hbox = uiextras.HBox('Parent', parent);
      htext = uicontrol('Parent', hbox, 'Style', 'Text', 'String', 'xmin:');
      hfitpar.xmin_down = uicontrol('Parent', hbox, 'Style', 'PushButton', ...
                                    gui_settings{:}, 'String', '<', ...
                                    'Tag', 'xmin_down', 'UserData', 1);
      hfitpar.xmin = uicontrol('Parent', hbox, edit_properties{:}, ...
                               gui_settings{:}, 'Tag', 'xmin', ...
                               'UserData', 1);
      hfitpar.xmin_up = uicontrol('Parent', hbox, 'Style', 'PushButton', ...
                                  gui_settings{:}, 'String', '>', ...
                                  'Tag', 'xmin_down', 'UserData', 1);
      set(hbox, 'Sizes', [-1,-1,-2,-1]);
      
      hbox = uiextras.HBox('Parent', parent);
      htext = uicontrol('Parent', hbox, 'Style', 'Text', 'String', 'xmax:');
      hfitpar.xmax_down = uicontrol('Parent', hbox, 'Style', 'PushButton', ...
                                    gui_settings{:}, 'String', '<', ...
                                    'Tag', 'xmax_down', 'UserData', 1);
      hfitpar.xmax = uicontrol('Parent', hbox, edit_properties{:}, ...
                               gui_settings{:}, 'Tag', 'xmax', 'UserData',1);
      hfitpar.xmax_up = uicontrol('Parent', hbox, 'Style', 'PushButton', ...
                                    gui_settings{:}, 'String', '>', ...
                                    'Tag', 'xmax_up', 'UserData', 1);
      set(hbox, 'Sizes', [-1,-1,-2,-1]);
      
      fitpar_names = num2lege(1:7, 'par');
      for i=1:length(fitpar_names)
         hfitpar.panel(i) = uiextras.Panel('Parent', parent, 'Title', ...
                                           fitpar_names{i}, 'Padding', 6);
         hgrid = uiextras.Grid('Parent', hfitpar.panel(i), 'Spacing', 2);
         mygui_settings = {'Parent', hgrid, 'Callback', @gui_events_fitpar, ...
                         'UserData', i};

         hfitpar.fit(i) = uicontrol(mygui_settings{:}, 'Style', ...
                                    'CheckBox', 'String', 'fit', 'Tag', 'fit');
         hfitpar.limit(i) = uicontrol(mygui_settings{:}, 'Style', ...
                                      'CheckBox', 'String', 'limit', ...
                                      'Tag', 'limit');
         hfitpar.slider(i) = uicontrol(mygui_settings{:}, 'Style', ...
                                       'Slider', 'Tag', 'slider');
         hfitpar.lower(i) = uicontrol(mygui_settings{:}, edit_properties{:}, ...
                                      'Tag', 'lower');
         hfitpar.value(i) = uicontrol(mygui_settings{:}, edit_properties{:}, ...
                                      'Tag', 'value');
         hfitpar.upper(i) = uicontrol(mygui_settings{:}, edit_properties{:}, ...
                                      'Tag', 'upper');

         set(hgrid, 'ColumnSizes', [50,70,70], 'RowSizes', [25,25]);
      end
      
      set(parent, 'Sizes', [27,30,25,25,25,27,27,27,25,repmat(70,1,length(fitpar_names))]);
   end

   function gui_events_fitpar(hObject, eventdata, varargin)
      xc = guidata(hObject);
      iselect = find([xc.xydata(:).select]);
      hfitpar = xc.hfitpar;
      j = get(hfitpar.func, 'Value');
      
      switch hObject
         case hfitpar.func
            [xc.xydata(iselect).ifunc] = deal(j);
            guidata(hObject, xc);
            gui_events_fitpar(xc.hfitpar.calculate, []);
            gui_update(xc, 'update_fitpar');
        case hfitpar.addfunc
          newfuncname = get(hfitpar.newfuncname, 'string');
          showinfo(['Adding new fit function : ' newfuncname]);
          for i=1:length(iselect)
              xc.xydata(iselect(i)).funclist = ...
                  {xc.xydata(iselect(i)).funclist{:}, newfuncname};
              xc.xydata(iselect(i)).ifunc = ...
                  length(xc.xydata(iselect(i)).funclist);
              xc.xydata(iselect(i)) = xypro_fitfunc(xc.xydata(iselect(i)), ...
                                                    'init_fitpar', xc.xydata(iselect(i)).ifunc);
          end
          guidata(hObject, xc);
          gui_events_fitpar(xc.hfitpar.calculate, []);
          gui_update(xc, 'update_fitpar');
         case {hfitpar.xmin_down, hfitpar.xmin_up}
            for i=1:length(iselect)
               xmin = xc.xydata(iselect(i)).fitpar(j).xmin;
               imin = locate(xc.xydata(iselect(i)).data(:,1), xmin);

               if (hObject == hfitpar.xmin_down)
                  if (xmin <= xc.xydata(iselect(i)).data(imin,1)) && (imin > 1)
                     imin = imin-1;
                  end
               elseif (hObject == hfitpar.xmin_up)
                  if (xmin >= xc.xydata(iselect(i)).data(imin,1)) && ...
                              (imin < length(xc.xydata(iselect(i)).data(:,1)))
                     imin = imin+1;
                  end
               end
               xc.xydata(iselect(i)).fitpar(j).xmin = ...
                   xc.xydata(iselect(i)).data(imin,1);
            end
            guidata(hObject, xc);
            if get(hfitpar.auto_calc, 'Value')
               gui_events_fitpar(xc.hfitpar.calculate, []);
            end
            if get(hfitpar.auto_fit, 'Value')
               gui_events_fitpar(xc.hfitpar.xyfit, []);
            end
         case {hfitpar.xmax_down, hfitpar.xmax_up}
            for i=1:length(iselect)
               xmax = xc.xydata(iselect(i)).fitpar(j).xmax;
               imax = locate(xc.xydata(iselect(i)).data(:,1), xmax);

               if (hObject == hfitpar.xmax_down)
                  if (xmax <= xc.xydata(iselect(i)).data(imax,1)) && (imax > 1)
                     imax = imax-1;
                  end
               elseif (hObject == hfitpar.xmax_up)
                  if (xmax >= xc.xydata(iselect(i)).data(imax,1)) && ...
                              (imax < length(xc.xydata(iselect(i)).data(:,1)))
                     imax = imax+1;
                  end
               end
               xc.xydata(iselect(i)).fitpar(j).xmax = ...
                   xc.xydata(iselect(i)).data(imax,1);
            end
            guidata(hObject, xc);
            if get(hfitpar.auto_calc, 'Value')
               gui_events_fitpar(xc.hfitpar.calculate, []);
            end
            if get(hfitpar.auto_fit, 'Value')
               gui_events_fitpar(xc.hfitpar.xyfit, []);
            end
         case hfitpar.undo
            for ix=1:length(iselect)
               xc.xydata(iselect(ix)).fitpar(j).value = ...
                   xc.xydata(iselect(ix)).fitpar(j).oldvalue;
            end
            guidata(hObject, xc);
            gui_events_fitpar(xc.fitpar.calculate, []);
            gui_update(xc, 'update_fitpar');
         case hfitpar.calculate
            xc.xydata(iselect) = xypro_fitfunc(xc.xydata(iselect), ...
                                                'calc_only', 1);
            guidata(hObject, xc);
            if get(xc.hplotrun.liveupdate, 'Value');
               gui_update(xc, 'update_plot');
            end
         case hfitpar.xyfit
            xc.xydata(iselect) = xypro_fitfunc(xc.xydata(iselect));
            guidata(hObject, xc);
            if get(xc.hplotrun.liveupdate, 'Value');
               gui_update(xc, 'update_plot', 1, 'update_fitpar', 1);
            else
               gui_update(xc, 'update_fitpar');
            end
         otherwise
            k = get(hObject, 'UserData'); % index which par, i.e.,
                                          % par(k) in xyfit functions
            tagname = get(hObject, 'Tag');
            
            switch upper(get(hObject, 'Style'))
               case 'SLIDER'
                  disp(['set ' num2str(k, 'value(%d)') ' to ' num2str(get(hObject, 'Value'))])
               case 'EDIT'
                  for ix=1:length(iselect)
                     xc.xydata(iselect(ix)).fitpar(j).(tagname)(k) = str2num(get(hObject, 'String'));
                     disp(['set ' tagname num2str(k, '(%d)') ' to ' get(hObject, 'String')])
                  end
                  guidata(hObject, xc);
                  if strmatch(tagname, 'value', 'exact');
                     gui_events_fitpar(xc.hfitpar.calculate, []);
                  end
               case 'POPUPMENU'
                  for ix=1:length(iselect)
                     xc.xydata(iselect(ix)).fitpar(j).(tagname)(k) = get(hObject, 'Value');
                     disp(['set ' tagname num2str(k, '(%d)') ' to ' num2str(get(hObject, 'Value'))])
                  end
                  guidata(hObject, xc);
                  if (hObject == hfitpar.algorithm); 
                     gui_update(xc, 'update_fitpar');
                  end
               case 'CHECKBOX'
                  for ix=1:length(iselect)
                     xc.xydata(iselect(ix)).fitpar(j).(tagname)(k) = get(hObject, 'Value');
                     disp(['set ' tagname num2str(k, '(%d)') ' to ' ...
                           num2str(get(hObject, 'Value'))])
                  end
                  guidata(hObject, xc);
               otherwise
                  showinfo(['Events from widget style: ' get(hObject, 'Type') ...
                            'are ignored!']);
            end
      end
   end
function gui_update(xc, varargin)
% default is to do nothing
   update_all = 0;
   update_datapro = 0; 
   update_plot = 0;
   update_fitpar = 0;
   parse_varargin(varargin);
   
   if (update_all+update_datapro+update_plot+update_fitpar) == 0
      % showinfo('No GUI update is requested!');
      return
   end
   if isempty(xc.xydata);
      set(xc.hdatapro.datalist, 'Value', [], 'String', ['no data ' ...
                          'available, do not click here!']);
      return; 
   end

   xydata = xc.xydata;
   iselect = find([xydata(:).select]);

   if (update_all == 1) || (update_datapro == 1)
      hdatapro = xc.hdatapro;
      % data info
      set(hdatapro.datalist, 'Value', [], 'String', {xydata(:).title});
      set(hdatapro.match_data, 'String', {'[1,1]' '[0,0]' xydata(:).title});
      if ~isempty(iselect)
         set(hdatapro.datalist, 'Value', iselect);
         i = iselect(1);
         set(hdatapro.id, 'String', xydata(i).id);
         set(hdatapro.xcol, 'String', num2lege(1:length(xydata(i).rawdata(1,:))));
         set(hdatapro.xcol, 'value', xydata(i).xcol);
         set(hdatapro.ycol, 'String', num2lege(1:length(xydata(i).rawdata(1,:))));
         set(hdatapro.ycol, 'value', xydata(i).ycol);
         set(hdatapro.ecol, 'String', num2lege(1:length(xydata(i).rawdata(1,:))));
         set(hdatapro.ecol, 'value', xydata(i).ecol);
         
         set(hdatapro.sortx, 'Value', xydata(i).sortx);
         set(hdatapro.imin, 'String', xydata(i).imin);
         set(hdatapro.imax, 'String', xydata(i).imax);
         set(hdatapro.xmin, 'String', xydata(i).xmin);
         set(hdatapro.xmax, 'String', xydata(i).xmax);
         
         set(hdatapro.match, 'Value', xydata(i).match);
         set(hdatapro.match_scale, 'Value', xydata(i).match_scale);
         set(hdatapro.match_offset, 'Value', xydata(i).match_offset);
         set(hdatapro.match_range, 'String', num2str(xydata(i).match_range, ...
                                                     '[%0.4g,%0.4g]'));

         set(hdatapro.mathstring, 'String', xydata(i).mathstring);
      end
   end

   if (update_all ==1) || (update_plot ==1);
      gui_events_plotrun(xc.hplotrun.plot, []);
   end
   
   if (update_all ==1) || (update_fitpar == 1)
      hfitpar = xc.hfitpar;
      onoff = {'on', 'off'};
      
      if ~isempty(iselect)
         i = iselect(1);
         j = xydata(i).ifunc;
         set(hfitpar.func, 'String', xydata(i).funclist, 'Value', j);
         set(hfitpar.num_pars, 'String', num2lege(1: length(xydata(i).fitpar(j).value)), 'Value', xydata(i).fitpar(j).num_pars);
         set(hfitpar.algorithm, 'String', ...
                           xydata(i).fitpar(j).algorithmlist, 'Value', ...
                           xydata(i).fitpar(j).ialgorithm);
         set(hfitpar.lm_lambda, 'String', ...
                           num2str(xydata(i).fitpar(j).lm_lambda), ...
                           'Enable', onoff{3-xydata(i).fitpar(j).ialgorithm});
         set(hfitpar.maxiter, 'String', num2str(xydata(i).fitpar(j).maxiter));
         set(hfitpar.xmin, 'String', num2str(xydata(i).fitpar(j).xmin));
         set(hfitpar.xmax, 'String', num2str(xydata(i).fitpar(j).xmax));
         for k=1:length(xydata(i).fitpar(j).value)
            set(hfitpar.panel(k), 'Title', xydata(i).fitpar(j).name{k}, 'Enable', 'on');
            set(hfitpar.fit(k), 'Value', xydata(i).fitpar(j).fit(k), ...
                              'Enable', onoff{xydata(i).fitpar(j).ialgorithm});
            set(hfitpar.limit(k), 'Value', xydata(i).fitpar(j).limit(k));
            if ~isinf(xydata(i).fitpar(j).lower(k)) && ~isinf(xydata(i).fitpar(j).lower(k))
               set(hfitpar.slider(k), 'Value', xydata(i).fitpar(j).value(k), 'Min', ...
                                 xydata(i).fitpar(j).lower(k), 'Max', xydata(i).fitpar(j).upper(k));
            end
            set(hfitpar.value(k), 'String', xydata(i).fitpar(j).value(k));
            set(hfitpar.lower(k), 'String', xydata(i).fitpar(j).lower(k));
            set(hfitpar.upper(k), 'String', xydata(i).fitpar(j).upper(k));
         end
         for k=(length(xydata(i).fitpar(j).value)+1):length(hfitpar.panel)
            set(hfitpar.panel(k), 'Enable', 'off');
         end
      end
   end
end
end