function hdirgui = dirbrowser_gui(varargin);

   Parent = [];
   LoadFileFunc = [];
   LoadNewFileFunc = [];
   
   edit_properties = {'Style', 'Edit', 'BackgroundColor', 'w', ...
                      'Position', [10, 10, 20, 10]};
   gui_settings = {'CallBack', @gui_events_dirgui};

   parse_varargin(varargin);
   %   functions(LoadFileFunc)
   
   % if no parent, just create a new figure
   if isempty(Parent);
      Parent = uipanel('Parent', figure('Position', [50,50,300,500]));
   end

   % GUI setup
   hdirbox = uiextras.VBox('Parent', Parent);
   
   hbox = uiextras.HBox('Parent', hdirbox);
   hdirgui.workdir = pwd();
   hdirgui.currentdir = uicontrol('Parent', hbox, edit_properties{:}, 'String', pwd(), 'Tag', ...
             'currentdir', gui_settings{:}, 'HorizontalAlignment', 'Right');
   hdirgui.gotocwd = uicontrol('Parent', hbox, 'String', 'CWD', 'Tag', ...
             'gotocwd', gui_settings{:}, 'HorizontalAlignment', 'Right');
   set(hbox, 'Sizes', [-1,38]);
   hbox = uiextras.HBox('Parent', hdirbox);
   hdirgui.refresh = uicontrol('Parent', hbox, 'String', 'Show:', gui_settings{:});
   hdirgui.dirfilter = uicontrol('Parent', hbox, edit_properties{:}, 'String', '*', ...
             'Tag', 'dirfilter', gui_settings{:});
   hdirgui.dirkeepdir = uicontrol('Parent', hbox, 'Style', 'CheckBox', ...
                                  'String', 'Directory', 'Value', 1, ...
                                  'Tag', 'dirkeepdir', gui_settings{:});
   
   hdirgui.dirshowhidden = uicontrol('Parent', hbox, 'Style', ...
                                     'CheckBox', 'String', ...
                                     'Hidden', 'Value', 0, ...
                                     gui_settings{:});
   
   set(hbox, 'Sizes', [-1,-1,-1,-1]);
   hbox = uiextras.HBox('Parent', hdirbox);
   %   dummy = uicontrol('Parent', hbox, 'Style', 'Text', 'String', 'Format:');
   hdirgui.dirsortorder = uicontrol('Parent', hbox, 'Style', ...
                                    'CheckBox', 'String', ['a->' ...
                       'z:'], 'Value', 1, gui_settings{:});
   hdirgui.dirsortby = uicontrol('Parent', hbox, 'Style', ...
                                 'PopUpMenu', 'String', {'name', ...
                       'suffix', 'size', 'time'}, 'Value', 1, ...
                                 gui_settings{:});
   hdirgui.dirloadfile = uicontrol('Parent', hbox, 'String', ...
                                   'Load', gui_settings{:});

   hdirgui.dirwatchdir = uicontrol('Parent', hbox, 'Style', 'Checkbox', ...
                                   'String', 'Auto', gui_settings{:});

%   hbox = uiextras.HBox('Parent', hdirbox);
%   dummy = uicontrol('Parent', hbox, 'Style', 'Text', 'String', 'Format:');
%   hdirgui.formattype = uicontrol('Parent', hbox, 'Style', 'PopUpMenu', ...
%                                  'String', {'auto', 'XY Data', ...
%                       'Image'}, 'Value', 1, gui_settings{:});
%   hdirgui. = uicontrol('Parent', hbox, 'String', ...
%                                   'Load', gui_settings{:});
%   
%   hdirgui.dirwatchdir = uicontrol('Parent', hbox, 'Style', 'Checkbox', ...
%                                   'String', 'Auto', gui_settings{:});
%   
   
   hdirgui.dirbrowser = uicontrol('Parent', hdirbox, 'Style', ...
                                  'ListBox', 'Max', 100, 'Min', 1, ...
                                  'BackgroundColor', 'w', ...
                                  'ForegroundColor', 'b', 'FontWeight', ...
                                  'normal', 'Enable', 'On', gui_settings{:});
   
   set(hdirbox, 'Sizes', [28,26,26,-1]);
   
   set(hdirgui.currentdir, 'String', pwd());
   gui_events_dirgui(hdirgui.currentdir, []);
   
   function gui_events_dirgui(hObject, eventdata, varargin)
   %set(xc.hfig, 'Pointer', 'Watch')
      switch hObject
         case {hdirgui.currentdir, hdirgui.refresh, hdirgui.dirfilter, ...
               hdirgui.dirkeepdir, hdirgui.dirshowhidden}
            currentdir = get(hdirgui.currentdir, 'String');
            dirfilter = strtrim(get(hdirgui.dirfilter, 'String'));
            if isempty(dirfilter); dirfilter = '*'; end
            if (get(hdirgui.dirkeepdir, 'Value') == 1)
               dirinfo = dir(fullfile(currentdir, '*'));
               dirsonly = dirinfo([dirinfo.isdir] == 1);
               dirinfo = dir(fullfile(currentdir, dirfilter));
               dirinfo([dirinfo.isdir] == 1) = [];
               % merge the dir into
               dirinfo = [dirsonly; dirinfo];
            else
               dirinfo = dir(fullfile(currentdir, dirfilter));
            end
            % remove hidden directories and files as wished
            if ~isempty(dirinfo) && (get(hdirgui.dirshowhidden, 'Value') == 0)
               ihidden = strncmp('.', {dirinfo.name}, 1);
               dirinfo(ihidden) = [];
            end
            % add "." and ".." to the list if not present
            if isempty(dirinfo) || ~strcmp(dirinfo(1).name, '.')
               dirinfo = [dir('*.'); dirinfo];
            end
            set(hdirgui.currentdir, 'UserData', dirinfo);
            gui_events_dirgui(hdirgui.dirsortorder, []);
         case hdirgui.gotocwd
            set(hdirgui.currentdir, 'String', pwd());
            gui_events_dirgui(hdirgui.currentdir);
         case  {hdirgui.dirsortorder, hdirgui.dirsortby}
            dirinfo = get(hdirgui.currentdir, 'UserData');
            % get the sortdata to sort
            names = {dirinfo.name};
            switch get(hdirgui.dirsortby, 'Value');
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
            if get(hdirgui.dirsortorder, 'Value') == 0
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
            set(hdirgui.dirbrowser, 'Value', [], 'String', names, ...
                              'UserData', dirinfo);
         case hdirgui.dirbrowser
            % can preview single click events
            % only try double click events
            if strcmp(get(gcf, 'SelectionType'), 'normal')
               disp('This is a single click ...')
            else % double click --> load data
               disp('This is a double click ...')
               dirinfo = get(hdirgui.dirbrowser, 'UserData');
               idir = get(hdirgui.dirbrowser, 'Value');
               if dirinfo(idir(1)).isdir
                  hdirgui.workdir = pwd();
                  cd(fullfile(get(hdirgui.currentdir, 'String'), dirinfo(idir(1)).name));
                  set(hdirgui.currentdir, 'String', pwd());
                  cd(hdirgui.workdir);
                  gui_events_dirgui(hdirgui.currentdir, []);
               else
                  gui_events_dirgui(hdirgui.dirloadfile, []);
               end
            end
         case hdirgui.dirloadfile
            dirinfo = get(hdirgui.dirbrowser, 'UserData');
            dirinfo = dirinfo(get(hdirgui.dirbrowser, 'Value'));
            ignore = find([dirinfo.isdir]);
            if ~isempty(ignore);
               disp('Ignore directories when loading data');
               dirinfo(ignore) = [];
            end
            if ~isempty(dirinfo); 
               disp('Loading selected files...');
               currentdir = get(hdirgui.currentdir, 'String');
               for i=1:length(dirinfo)
                  filenames{i} = fullfile(currentdir,dirinfo(i).name);
               end
               feval(LoadFileFunc, filenames);
            else
               disp('No file selected!');
            end
         case hdirgui.dirwatchdir
            currentdir = get(hdirgui.currentdir, 'String');
            global htimer
            htimer = get(hdirgui.dirwatchdir, 'UserData');
            if isempty(htimer) || ~isvalid(htimer)
               htimer = timer('TimerFcn', {LoadNewFileFunc, [currentdir '/']}, ...
                              'Period', 5, 'StartDelay', 3, ...
                              'ExecutionMode', 'fixedDelay');
               set(hdirgui.dirwatchdir, 'UserData', htimer);
            end
            if get(hdirgui.dirwatchdir, 'Value')
               start(htimer);
               showinfo('Starting timer...');
            else
               stop(htimer);
               showinfo(['Stopping timer... NumTasksExecuted:' ...
                         num2str(htimer.TasksExecuted)]);
               delete(htimer);
            end
         otherwise
            wtype = upper(get(hObject, 'Style'));
            tagname = get(hObject, 'Tag');
            switch wtype
               otherwise
                  showinfo(['Events from this widget: ' get(hObject, 'Type') ...
                            'are ignored!']);
            end
      end
   end
   
end
