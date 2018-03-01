function varargout = xcurves(varargin)
   
   fig_size = [1100,700];
   scr_size = get(0,'ScreenSize');
   leftpanel_width = 260;
   rightpanel_width = 200;
   edit_properties = {'Style', 'Edit', 'BackgroundColor', 'w', ...
                      'Position', [10, 10, 20, 10]};
   
   xc.hfig = figure('Position', [scr_size(3)-fig_size(1), ...
                       scr_size(4)-fig_size(2), fig_size(1), ...
                       fig_size(2)], 'Name', 'XCurves', 'Resize', ...
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
   hMainPanel = uiextras.HBox('Parent', xc.hfig);
   hLeftPanel =  uiextras.VBox('Parent', hMainPanel);
   hMidPanel =  uiextras.VBox('Parent', hMainPanel);
   hRightPanel = uiextras.VBox('Parent', hMainPanel);
   set(hMainPanel, 'Sizes', [leftpanel_width,-1, rightpanel_width]);
   
   % dummy data for testing
   xc.xydata = []; %xydata_init({'GT20CNTNa150_osmoforce.dat', ...
                   %    'GT20CNTNa1000_osmoforce.dat'});

   % create GUIs
   xc.hdatapro = gui_create_datapro('parent', hLeftPanel);
   xc.hplotrun = gui_create_plotrun('parent', hMidPanel);
   xc.hfitpar = gui_create_fitpar([], 'parent', hRightPanel);
   set(xc.hfig, 'Visible', 'on');
   % xc.curve will be the structure for data

   % save data and update GUIs
   guidata(xc.hfig, xc);
   set(xc.hdatapro.currentdir, 'String', pwd());
   gui_events_datapro(xc.hdatapro.currentdir, []);
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
      hpanel.TabNames = {'Browsing', 'Curves'};
      hpanel.SelectedChild = 1;
      
      % Panel #1) dir browser
      hdirbox = uiextras.VBox('Parent', hdirpanel);
      hbox = uiextras.HBox('Parent', hdirbox);
      hdatapro.currentdir = uicontrol('Parent', hbox, edit_properties{:}, ...
                                      'String', '', gui_settings{:});
      hbox = uiextras.HBox('Parent', hdirbox);
      hdatapro.dirsortorder = uicontrol('Parent', hbox, 'Style', ...
                                        'CheckBox', 'String', ['a->' ...
                          'z:'], 'Value', 1, gui_settings{:});
      hdatapro.dirsortby = uicontrol('Parent', hbox, 'Style', ...
                                     'PopUpMenu', 'String', {'name', ...
                          'suffix', 'size', 'time'}, 'Value', 1, ...
                                     gui_settings{:});
      htext = uicontrol('Parent', hbox, 'Style', 'text', 'String', 'Filter:');
      hdatapro.dirfilter = uicontrol('Parent', hbox, edit_properties{:}, ...
                                     'String', '*', gui_settings{:});

      hdatapro.dirbrowser = uicontrol('Parent', hdirbox, 'Style', ...
                                      'ListBox', 'Max', 100, 'Min', ...
                                      1, 'Enable', 'On', gui_settings{:});
      set(hdirbox, 'Sizes', [32,32,-1]);

      % Panel #2) data list
      hdatabox = uiextras.VBox('Parent', hdatapanel);
      hdatapro.datalist = uicontrol('Parent', hdatabox, 'Style', ...
                                    'ListBox', 'Max', 100, 'Min', ...
                                    1, 'String', 'no data available', ...
                                    gui_settings{:});
      
      % Load remove data
      hbox = uiextras.Grid('Parent', hdatabox);

      hdatapro.varname = uicontrol('Parent', hbox, edit_properties{:}, ...
                                   'String', 'varname', gui_settings{:});
      hdatapro.loadvar = uicontrol('Parent', hbox, 'String', 'Load Var', gui_settings{:});

      hdatapro.rmdata = uicontrol('Parent', hbox, 'String', ['Rm ' ...
                          'Data'], gui_settings{:});
      hdatapro.loadsetup = uicontrol('Parent', hbox, 'String', ['Load ' ...
                          'Setup'], gui_settings{:});
      set(hbox, 'ColumnSizes', [-1,-1], 'RowSizes', [-1,-1]);
      set(hdatabox, 'Sizes', [-1,50]);

      % 3) data correction
      hpanel = uiextras.Panel('Parent', parent, 'Title', ['data preparation']);
      hpanel = uiextras.TabPanel('Parent', hpanel);
      hsetupbox = uiextras.VBox('Parent', hpanel);
      hmathbox = uiextras.VBox('Parent', hpanel);
      hsasbox = uiextras.VBox('Parent', hpanel);
      hosmobox = uiextras.VBox('Parent', hpanel);
      hpanel.TabNames = {'setup', 'math', 'sas', 'osmo'};
      hpanel.SelectedChild = 1;

      % Tab Panel #1: set up data
      % column setup      
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
                                 'String', 'match', 'Tag', 'match', ...
                                 gui_settings{:});
      hdatapro.match_data = uicontrol('Parent', hpanel, 'Style', 'PopUpMenu', ...
                                'String', {'[1,1]', '1', '2'}, 'Tag', ...
                                      'match_data', gui_settings{:});
      hdatapro.match_scale = uicontrol('Parent', hpanel, 'Style', ...
                                       'CheckBox', 'String', 'scale', ...
                                       'Tag', 'match_scale', gui_settings{:});
      hdatapro.match_offset = uicontrol('Parent', hpanel, 'Style', ...
                                        'CheckBox', 'String', 'offset', ...
                                        'Tag', 'match_offset', gui_settings{:});

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
      htext = uicontrol('Parent', hbox, 'Style', 'Text', 'String', ...
                        'molweight:');
      hdatapro.molweight = uicontrol('Parent', hbox, 'String', ...
                                       100, 'Tag', 'molweight', ...
                                       edit_properties{:}, gui_settings{:});
      htext = uicontrol('Parent', hbox, 'Style', 'Text', 'String', 'concentration:');
      hdatapro.concentration = uicontrol('Parent', hbox, 'String', ...
                                         '0.1', 'Tag', 'concentration', ...
                                         edit_properties{:}, gui_settings{:});

      hbox = uiextras.HBox('Parent', hsasbox);
      htext = uicontrol('Parent', hbox, 'Style', 'Text', 'String', ...
                        'ion strength:');
      hdatapro.ionstrength = uicontrol('Parent', hbox, 'String', ...
                                       10, 'Tag', 'ionstrength', ...
                                       edit_properties{:}, gui_settings{:});
      htext = uicontrol('Parent', hbox, 'Style', 'Text', 'String', 'dmax:');
      hdatapro.dmax = uicontrol('Parent', hbox, 'String', ...
                                       100, 'Tag', 'dmax', ...
                                       edit_properties{:}, gui_settings{:});

      hbox = uiextras.HBox('Parent', hsasbox);
      hdatapro.guinier = uicontrol('Parent', hbox, 'Style', 'CheckBox', ...
                                   'String', 'Guinier  range:', ...
                                   'Tag', 'guinier', gui_settings{:});
      
      hdatapro.guinier_range = uicontrol('Parent', hbox, 'String', ...
                                        '[0, 0.01]', 'Tag', 'guinier_range', ...
                                        edit_properties{:}, gui_settings{:});

      hbox = uiextras.HBox('Parent', hsasbox);
      hbox = uiextras.HBox('Parent', hsasbox);

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

   function gui_events_datapro(hObject, eventdata, varargin)
      xc = guidata(hObject);
      set(xc.hfig, 'Pointer', 'Watch')

      if isempty(xc.xydata)
         disp('Please load data first...')
         %         set(xc.hfig, 'Pointer', 'Arrow');
         %return;
      else
         iselect = find([xc.xydata(:).select]);
         if isempty(iselect); iselect=0; end
      end
      hdatapro = xc.hdatapro;
      
      switch hObject
         case {hdatapro.currentdir, hdatapro.dirfilter}
            cd(get(hdatapro.currentdir, 'String'));
            dirfilter = get(hdatapro.dirfilter, 'String');
            dirinfo = dir(dirfilter);
            if isempty(dirinfo) || ~strcmp(dirinfo(1).name, '.')
               dirinfo = [dir('*.'); dirinfo];
            end
            set(hdatapro.currentdir, 'UserData', dirinfo);
            gui_events_datapro(hdatapro.dirsortorder, []);
         case  {hdatapro.dirsortorder, hdatapro.dirsortby}
            dirinfo = get(hdatapro.currentdir, 'UserData');
            % get the sortdata to sort
            names = {dirinfo.name};
            switch get(hdatapro.dirsortby, 'Value');
               case 1 % by name
                  sortdata = 1:length(names);
               case 2 % suffix
                  idot = strfind(names, '.');
                  for i=1:length(idot)
                     if isempty(idot{i})
                        sortdata{i} = '';
                     else
                        sortdata{i} = names{i}(idot{i}(end)+1:end);
                     end
                  end
               case 3 % size
                  sortdata = [dirinfo.bytes];
               case 4 % time
                  sortdata = [dirinfo.datenum];
               otherwise
            end
            [sortdata, isort] = sort(sortdata);
            if get(hdatapro.dirsortorder, 'Value') == 0
               isort = fliplr(isort);
            end
            dirinfo = dirinfo(isort);
            % directory always goes first
            [sortdata, isort] = sort([dirinfo.isdir],2,'descend');
            dirinfo = dirinfo(isort);
            % change the names a bit
            names = {dirinfo.name};
            for i=1:length(names);
               if dirinfo(i).isdir
                  names{i} = ['[D] ' names{i}];
               else
                  names{i} = ['[F] ' names{i}];
               end
            end
            set(hdatapro.dirbrowser, 'Value', [], 'String', names, ...
                              'UserData', dirinfo);
         case hdatapro.dirbrowser
            % can preview single click events
            % only try double click events
            if strcmp(get(xc.hfig, 'SelectionType'), 'normal')
               disp('Double click to select ...')
            else
               dirinfo = get(hdatapro.dirbrowser, 'UserData');
               idir = get(hdatapro.dirbrowser, 'Value');
               if dirinfo(idir(1)).isdir
                  cd(dirinfo(idir(1)).name);
                  set(hdatapro.currentdir, 'String', pwd());
                  gui_events_datapro(hdatapro.currentdir, []);
               else
                  % add the data
                  xc.xydata = [xc.xydata, ...
                               xydata_dataprep(xydata_init({dirinfo(idir).name}))];
                  guidata(hObject, xc);
                  gui_update(xc, 'update_all');
               end
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
            if iselect_gui(1) == iselect(1)
               gui_update(xc, 'update_plot');
            else
               gui_update(xc, 'update_all');
            end
         case hdatapro.loadsetup
            xydata.filename = uigetfile();
            specdata = specdata_readfile(xydata.filename);
            xydata = struct_assign(specdata, xydata, 'append')
            xc.xydata = xydata;
            guidata(hObject, xc);
         case hdatapro.loadvar
            
         case hdatapro.rmdata
            xc.xydata(iselect) = [];
            guidata(hObject, xc);
            gui_update(xc, 'update_all');
         otherwise
            wtype = upper(get(hObject, 'Style'));
            tagname = get(hObject, 'Tag');
            switch wtype
               case 'EDIT'
                  [xc.xydata(iselect).(tagname)] = deal(str2num(get(hObject, 'String')));
                  disp(['set ' tagname ' to ' get(hObject, 'String')])
               case 'CHECKBOX'
                  [xc.xydata(iselect).(tagname)] = deal(get(hObject, 'Value'));
                  disp(['set ' tagname ' to ' num2str(get(hObject, 'Value'))])
               case 'POPUPMENU'
                  [xc.xydata(iselect).(tagname)] = deal(get(hObject, 'Value'));
                  menustr = get(hObject, 'String');
                  disp(['set ' tagname ' to ' menustr{(get(hObject, ...
                                                           'Value'))}])
               otherwise
                  showinfo(['Events from this widget: ' get(hObject, 'Type') ...
                            'are ignored!']);
            end
            xc.xydata(iselect) = xydata_dataprep(xc.xydata(iselect));
            guidata(hObject, xc);
            gui_update(xc, 'update_plot');
      end
      set(xc.hfig, 'Pointer', 'Arrow')
   end
   
   function hplotrun = gui_create_plotrun(varargin);
      parse_varargin(varargin);
      if ~exist('parent', 'var') || isempty(parent)
         parent =  uiextras.VBox('Parent', figure());
      end
       
      gui_settings = {'CallBack', @gui_events_plotrun};
      
      % 1) visualization axis
      hpanel = uiextras.Panel('Parent', parent, 'Title','PLOT', 'Padding', 30);
      hplotrun.axes = axes('Parent', hpanel); 
      % xlabel('x'); ylabel('y');
      
      % 2) plot options box
      hpanel = uiextras.Panel('Parent', parent, 'Title', ['Options']);
      hpanel = uiextras.Grid('Parent', hpanel);
      hplotrun.liveupdate = uicontrol('Parent', hpanel, 'Style', ...
                                      'CheckBox', 'String', ...
                                      'LiveUpdate', 'Value', 1, ...
                                      'Tag', 'liveupdate', gui_settings{:});
      hplotrun.empty = uiextras.Empty('Parent', hpanel);
      hplotrun.plotopt.legend = uicontrol('Parent', hpanel, 'Style', ...
                                          'CheckBox', 'String', ...
                                          'Legend', 'Value', 1, gui_settings{:});
      hplotrun.plotopt.errorbar = uicontrol('Parent', hpanel, 'Style', ...
                                            'CheckBox', 'String', 'ErrorBar');
      hbox = uiextras.HBox('Parent', hpanel, 'Padding', 0);
      hplotrun.plotopt.symbol = uicontrol('Parent', hbox, 'Style', ...
                                          'CheckBox', 'String', ...
                                          'Symbol', 'Value', 1, gui_settings{:});
      hplotrun.plotopt.symbolsize = uicontrol('Parent', hbox, 'Style', ...
                                              'PopUpMenu', 'String', ...
                                              num2lege(1:16), 'Value', 5, gui_settings{:});
      set(hbox, 'Sizes', [-2,-1]);
      hbox = uiextras.HBox('Parent', hpanel, 'Padding', 0);
      hplotrun.plotopt.line = uicontrol('Parent', hbox, 'Style', ...
                                        'CheckBox', 'String', 'Line', gui_settings{:});
      hplotrun.plotopt.linewidth = uicontrol('Parent', hbox, 'Style', ...
                                             'PopUpMenu', 'String', ...
                                             num2lege(1:16), 'Value', 2, gui_settings{:});
      set(hbox, 'Sizes', [-2,-1]);
      hplotrun.plotopt.logx = uicontrol('Parent', hpanel, 'Style', ...
                                        'CheckBox', 'String', 'Log(x)', gui_settings{:});
      hplotrun.plotopt.logy = uicontrol('Parent', hpanel, 'Style', ...
                                        'CheckBox', 'String', 'Log(y)', gui_settings{:});
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

      hbox = uiextras.Empty('Parent', hpanel);
      hbox = uiextras.Empty('Parent', hpanel);
      
      set(hpanel, 'ColumnSizes', [-1,-1,-1,-1], 'RowSizes', [-1, -1]);

      % 4) action box
      hbox = uiextras.HBox('Parent', parent);
      hplotrun.undo = uicontrol('Parent', hbox, 'String', 'Undo', gui_settings{:});
      hplotrun.plot = uicontrol('Parent', hbox, 'String', 'Plot', gui_settings{:});
      %hplotrun.prepare = uicontrol('Parent', hbox, 'String', 'Prepare', gui_settings{:});
      hplotrun.calculate = uicontrol('Parent', hbox, 'String', 'Calculate', gui_settings{:});
      hplotrun.fit = uicontrol('Parent', hbox, 'String', 'Fit', gui_settings{:});
      hplotrun.save = uicontrol('Parent', hbox, 'String', 'Save', gui_settings{:});

      %set(hbox, 'Sizes', [-1,-1]);
      set(parent, 'Sizes', [-1, 60,60,40]);
   end
   
   function gui_events_plotrun(hObject, eventdata, varargin)
      xc = guidata(hObject);
      iselect = find([xc.xydata(:).select]);
      hplotrun = xc.hplotrun;
      
      switch hObject
         case hplotrun.undo
            %guidata(hObject, xc);
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
            xydata_plot(xc.xydata(iselect), dataselect, plotopt);
         case hplotrun.calculate
            xc.xydata(iselect) = xydata_fitfunc(xc.xydata(iselect), ...
                                                'calc_only', 1);
            guidata(hObject, xc);
            if get(hplotrun.liveupdate, 'Value');
               gui_update(xc, 'update_plot');
            end
         case hplotrun.fit
            xc.xydata(iselect) = xydata_fitfunc(xc.xydata(iselect));
            guidata(hObject, xc);
            if get(hplotrun.liveupdate, 'Value');
               gui_update(xc, 'update_plot', 1, 'update_fitpar', 1);
            else
               gui_update(xc, 'update_fitpar');
            end
         case hplotrun.save
            
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
   end
   
   function hfitpar = gui_create_fitpar(fitpar_names, varargin)
      parse_varargin(varargin);
      if ~exist('parent', 'var') || isempty(parent)
         parent =  uiextras.VBox('Parent', figure());
      end

      gui_settings = {'CallBack', @gui_events_fitpar};
      hfitpar.top = parent;
      hfitpar.undo = uicontrol('Parent', parent, 'String', ...
                               'undo', gui_settings{:});
      
      hbox = uiextras.HBox('Parent', parent);
      htext = uicontrol('Parent', hbox, 'Style', 'Text', 'String', ...
                        'Function:');
      hfitpar.func = uicontrol('Parent', hbox, 'Style', 'PopUpMenu', ...
                               'String', 'none', gui_settings{:});

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
      hfitpar.xmin = uicontrol('Parent', hbox, edit_properties{:}, ...
                               gui_settings{:}, 'Tag', 'xmin', ...
                               'UserData', 1);
      htext = uicontrol('Parent', hbox, 'Style', 'Text', 'String', 'xmax:');
      hfitpar.xmax = uicontrol('Parent', hbox, edit_properties{:}, ...
                               gui_settings{:}, 'Tag', 'xmax', 'UserData',1);
      
      
      fitpar_names = num2lege(1:7, 'par');
      for i=1:length(fitpar_names)
         hfitpar.panel(i) = uiextras.Panel('Parent', parent, 'Title', ...
                                           fitpar_names{i}, 'Padding', 6);
         hgrid = uiextras.Grid('Parent', hfitpar.panel(i), 'Spacing', 2);
         gui_settings = {'Parent', hgrid, 'Callback', @gui_events_fitpar, ...
                         'UserData', i};

         hfitpar.fit(i) = uicontrol(gui_settings{:}, 'Style', ...
                                    'CheckBox', 'String', 'fit', 'Tag', 'fit');
         hfitpar.limit(i) = uicontrol(gui_settings{:}, 'Style', ...
                                      'CheckBox', 'String', 'limit', ...
                                      'Tag', 'limit');
         hfitpar.slider(i) = uicontrol(gui_settings{:}, 'Style', ...
                                       'Slider', 'Tag', 'slider');
         hfitpar.lower(i) = uicontrol(gui_settings{:}, edit_properties{:}, ...
                                      'Tag', 'lower');
         hfitpar.value(i) = uicontrol(gui_settings{:}, edit_properties{:}, ...
                                      'Tag', 'value');
         hfitpar.upper(i) = uicontrol(gui_settings{:}, edit_properties{:}, ...
                                      'Tag', 'upper');

         set(hgrid, 'ColumnSizes', [50,70,70], 'RowSizes', [25,25]);
      end
      set(parent, 'Sizes', [30,30,30,30,32,repmat(72,1,length(fitpar_names))]);
   end

   function gui_events_fitpar(hObject, eventdata, varargin)
      xc = guidata(hObject);
      iselect = find([xc.xydata(:).select]);
      hfitpar = xc.hfitpar;
      j = get(hfitpar.func, 'Value');
      
      switch hObject
         case hfitpar.undo
            for ix=1:length(iselect)
               xc.xydata(iselect(ix)).fitpar(j).value = ...
                   xc.xydata(iselect(ix)).fitpar(j).oldvalue;
            end
            guidata(hObject, xc);
            gui_events_plotrun(xc.hplotrun.calculate, []);
            gui_update(xc, 'update_fitpar');
         case hfitpar.func
            [xc.xydata(iselect).ifunc] = deal(j);
            guidata(hObject, xc);
            gui_events_plotrun(xc.hplotrun.calculate, []);
            gui_update(xc, 'update_fitpar');
         otherwise
            k = get(hObject, 'UserData');
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
                     gui_events_plotrun(xc.hplotrun.calculate, []);
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
      set(xc.hdatapro.datalist, 'Value', [], 'String', 'no data available');
      return; 
   end

   xydata = xc.xydata;
   iselect = find([xydata(:).select]);

   if (update_all == 1) || (update_datapro == 1)
      hdatapro = xc.hdatapro;
      % data info
      set(hdatapro.datalist, 'Value', [], 'String', {xydata(:).title});
      set(hdatapro.match_data, 'String', {'[1,1]' xydata(:).title});
      if ~isempty(iselect)
         set(hdatapro.datalist, 'Value', iselect);
         i = iselect(1);
         set(hdatapro.id, 'String', xydata(i).id);
         set(hdatapro.xcol, 'String', num2lege(1:length(xydata(i).data(1,:))));
         set(hdatapro.xcol, 'value', xydata(i).xcol);
         set(hdatapro.ycol, 'String', num2lege(1:length(xydata(i).data(1,:))));
         set(hdatapro.ycol, 'value', xydata(i).ycol);
         set(hdatapro.ecol, 'String', num2lege(1:length(xydata(i).data(1,:))));
         set(hdatapro.ecol, 'value', xydata(i).ecol);
         
         set(hdatapro.imin, 'String', xydata(i).imin);
         set(hdatapro.imax, 'String', xydata(i).imax);
         set(hdatapro.xmin, 'String', xydata(i).xmin);
         set(hdatapro.xmax, 'String', xydata(i).xmax);
         
         set(hdatapro.match, 'Value', xydata(i).match);
         set(hdatapro.match_scale, 'Value', xydata(i).match_scale);
         set(hdatapro.match_offset, 'Value', xydata(i).match_offset);
         set(hdatapro.match_range, 'String', num2str(xydata(i).match_range, ...
                                                     '[%g,%g]'));

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