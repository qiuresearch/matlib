function sasaGui()
% 
% 
% 
%  for limiting the q range, use function: locate(x, value) 
%  finds the closest element of x to the input value
% 
%
%
% Author:  Steve Howell
% Date:  24 Sep 2011

%         'position',[left bottom width height],...
% w = {'unit','pix','position'};
S = createInterface();

%--------------------------------------------------------------------------%
    function S = createInterface()
        % create the user interface for the application and return
        % a structure of handles for global use
        S = struct();
        % open a window and add menus
        S.window = figure('name','SASA Gui',...
                          'numbertitle','off',...
                          'Position', 100*[1 1 10 7]);
        % set panel defaults
        uiextras.set( S.window, 'DefaultBoxPanelTitleColor', [0.7 1.0 0.7] );
        stdSpacing = {'Padding',3,'Spacing', 3};
        
        % Arrange the main interface
        mainLayout = uiextras.HBoxFlex( 'Parent', S.window, stdSpacing{:} );


        % divide the space
        leftSec = uiextras.VBox('Parent',mainLayout, stdSpacing{:} );
        rightSec = uiextras.VBox('Parent',mainLayout, stdSpacing{:} );
        set(mainLayout, 'Sizes', [-1, 250]);
        topSec = uiextras.HBox('Parent',leftSec, stdSpacing{:} );
        bottomSec = uiextras.HBox('Parent',leftSec, stdSpacing{:} );
        set(leftSec, 'Sizes', [-1, 150]);
        
        % + create the panels
        dataPanel = uiextras.Panel('Parent', topSec,...
                                   'Title', 'Data');
        % controls2Panel = uiextras.Panel('Parent',topSec,...
        %                                 'Title', 'Controls2');
        plotPanel = uiextras.Panel('Parent', topSec);
        controlsPanel = uiextras.Panel('Parent',bottomSec,...
                                      'Title', 'Controls');
        % set( topSec, 'Sizes', [200,200,-1]);
        set( topSec, 'Sizes', [200,-1]);


        % + create file controls
        dataBox = uiextras.VBox('Parent',dataPanel,...
                                stdSpacing{:});
        filesControls = uiextras.HBox('Parent', dataBox);
        S.pb.setupFile = uicontrol('Parent',filesControls, ...
                                  'string','load setup');
        S.tx.nskip = uicontrol('style','text',...
                               'Parent',filesControls, ...
                               'string','nskip: ');
        S.ed.nskip = uicontrol('style','edit',...
                               'Parent',filesControls,...
                               'tag','nskip',...
                               'string','5');                   
        set( filesControls, 'Sizes', [-3 -1 -1]);
%         S.tx.nskip = uicontrol('style','text',...
%                             'Parent',filesControls, ...
%                             'string','header lines: ');
%         S.ed.nskip = uicontrol('style','edit',...
%                                'Parent',filesControls,...
%                                'tag','nskip',...
%                                'string','5');    
%         set( filesControls, 'Sizes', [-3 -4 -1]);
        
        filesBox = uiextras.VBox('Parent',dataBox,stdSpacing{:});
        S.ls.filesList = uicontrol('Parent',filesBox,...
                               'style','list',...
                               'backgroundcolor','w',...
                               'min',0,'max',2,...
                               'tag','currentFiles',...
                               'string','no files loaded',...
                               'fontsize',12);
        set( dataBox, 'Sizes', [17 -1]);
        
        % + create the controls
        controls = uiextras.VBox('Parent', controlsPanel, stdSpacing{:});
        plotControls = uiextras.HBox('Parent', controls,...
                                     stdSpacing{:});
        newControls = uiextras.HBox('Parent', controls, ...
                                     stdSpacing{:});
        set( controls, 'Sizes', [50, -1]);
        axisControls = uiextras.VButtonGroup('Parent',plotControls, stdSpacing{:});                                  
        S.cb.logx = uicontrol('Parent', axisControls,...
                              'style','checkbox',...
                              'value',0,...
                              'tag','plot',...
                              'string','logx');
        S.cb.logy = uicontrol('Parent', axisControls,...
                              'style','checkbox',...
                              'value',0,...
                              'tag','plot',...
                              'string','logy');
        minMaxVal = uiextras.VBox('Parent',plotControls, stdSpacing{:});
        S.tx.qmin = uicontrol('Parent',minMaxVal,...
                              'style','text',...
                              'string','Qmin:');
        S.tx.qmax = uicontrol('Parent',minMaxVal,...
                              'style','text',...
                              'string','Qmax:');  
        minMaxControls = uiextras.VBox('Parent',plotControls, stdSpacing{:});                                       
        S.ed.qmin = uicontrol('Parent',minMaxControls,...
                              'style','edit',...
                              'tag','qrange',...
                              'string','0');
        S.ed.qmax = uicontrol('Parent',minMaxControls,...
                              'style','edit',...
                              'tag','qrange',...
                              'string','0.2');
        S.pb.plot = uicontrol('Parent', plotControls,...
                            'style','push',...
                            'tag','plot',...
                            'string','plot');
        S.bg.plotType = uiextras.VButtonGroup('Parent',plotControls,...
                                              'Buttons',{'guinier','kratky'},...
                                              stdSpacing{:},...
                                              'SelectedChild', 1,...
                                              'SelectionChangeFcn',{@myPlot,S});
        S.axes = axes('Parent',plotPanel,...
                      'ActivePositionProperty', 'OuterPosition');
        
        set([S.pb.setupFile],'Callback', {@loadFiles,S});
        set([S.cb.logx,S.cb.logy,S.ed.qmax,S.ed.qmin,S.pb.plot], 'callback',{@myPlot,S});
        guidata(S.pb.plot, S);
    end % createInterface
%-------------------------------------------------------------------------%
%    function updateInterface()
%        % Update various parts of the interface in response to the demo
%        % being changed.
%
%        % Update the list and menu to show the current demo
%        set( gui.ListBox, 'Value', data.SelectedDemo );
%        % Update the help button label
%        demoName = data.DemoNames{ data.SelectedDemo };
%        set( gui.HelpButton, 'String', ['Help for ',demoName] );
%        % Update the view panel title
%        set( gui.ViewPanel, 'Title', sprintf( 'Viewing: %s', demoName ) );
%        % Untick all menus
%        menus = get( gui.ViewMenu, 'Children' );
%        set( menus, 'Checked', 'off' );
%        % Use the name to work out which menu item should be ticked
%        whichMenu = strcmpi( demoName, get( menus, 'Label' ) );
%        set( menus(whichMenu), 'Checked', 'on' );
%    end % updateInterface   
        
    

%-------------------------------------------------------------------------%
     function [] = loadFiles(varargin)
         S = varargin{3};
         S = guidata(S.pb.setupFile);
         [S.DATA.setupfile,pathname] = uigetfile( ...
             '*.txt;*.hst',...
             'Pick the setup file', ...
             '/home/schowell/Dropbox/gw_phd/research/NIST/0811NIST/datafit/');
         S.DATA.iqfit=iqfit_readsetup(str2mat(strcat(pathname,S.DATA.setupfile)));
         set(S.ls.filesList, 'String', {S.DATA.iqfit(:).prefix});
         set(S.pb.setupFile, 'String', [{S.DATA.setupfile}]);
         S.DATA.iqfit=iqfit_getdata(S.DATA.iqfit,'readiq','1','nskip',get(S.ed.nskip,'string'));  % !!add a reload iq checkbox or button
%          calc = ({'.q';'.IqRaw';'.std';'.sigmaq';'.meanq'});size(calc,1);
%          for i=1:size(S.DATA.iqfit(:).prefix,2)
%              temp=loadxy(fullfile(S.DATA.iqfit(i).datadir,S.DATA.iqfit(i).prefix),'#','nskip',str2double(get(S.ed.nskip,'string'))); % calculate values for each new file
%              for j=1:size(calc,2); eval([['S.DATA.',varnames{i},calc{i}] '=temp(:,i)']); end % store values
%              eval([['S.DATA.iqfit.',varnames{i},'.all'] '=temp'])
%          end
         guidata(varargin{1},S)
     end

%-------------------------------------------------------------------------%
     function [] = myPlot(varargin)
         S = varargin{3};  % Get the structure.
         S = guidata(S.pb.plot);
         set(S.pb.plot,'string','replot')
         cla reset
         L = get(S.ls.filesList,{'string','value'})
         hold all
         for i=1:size(L{2},2)
             disp(['plotting: ' L{1}{L{2}(i)}])
             switch S.bg.plotType.SelectedChild
               case 1 % guinier
                 xyplot(guinier(S.DATA.iqfit(L{2}(i)).iq))
                 guinierlabel
               case 2 % kratky
                 xyplot(kratky(S.DATA.iqfit(L{2}(i)).iq))
                 kratkylabel
               otherwise
                 disp([' Not supported yet!'])
             end
         end
         axis tight
         if get(S.cb.logx,'value');set(gca,'xscale','log');end;
         if get(S.cb.logy,'value');set(gca,'yscale','log');end;
%          xlim([str2double(get(S.ed.qmin,'string')) str2double(get(S.ed.qmax,'string'))])
         guidata(S.pb.plot,S)
     end
%-------------------------------------------------------------------------%
end