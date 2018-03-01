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
                      'Position', 100*[.1 .1 10 6]);
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
    set( topSec, 'Sizes', [200,-1]);
    % set( topSec, 'Sizes', [200,200,-1]);
    
    controlsPanel = uiextras.Panel('Parent',bottomSec,...
                                   'Title', 'Controls');
    editPanel = uiextras.Panel('Parent',rightSec,...
                               'Title','Manipulation');
    
    % + create manipulation controls
    editBox = uiextras.VBox('Parent',editPanel,...
                            stdSpacing{:});
    % --- master file --- %
    mfPanel = uiextras.Panel('Parent',editBox,...
                             'Title', 'Master File');
    mfBox = uiextras.HBox('Parent',mfPanel,...
                          stdSpacing{:});
    S.pb.mfSelect = uicontrol('style','push', ...
                              'Parent',mfBox,...
                              'string','file: ',...
                              'tag', 'pickFile');
    S.ed.masterFile = uicontrol('style','edit',...
                                'Parent', mfBox,...
                                'string', 'none',...
                                'tag', 'masterFile');
    % --- manipulation controls --- %
    manipBox1a = uiextras.HBox('Parent',editBox,...
                               stdSpacing{:});
    arithmaticPanel = uiextras.Panel('Parent',manipBox1a,...
                                     'Title', 'Arithmatic');
    manipBox1 = uiextras.HBox('Parent',arithmaticPanel,...
                              stdSpacing{:});
    S.cb.newFile = uicontrol('Parent', manipBox1,...
                             'style','checkbox',...
                             'value',0,...
                             'tag','new',...
                             'string','new');
    S.pb.addExe = uicontrol('style','push', ...
                            'Parent',manipBox1,...
                            'string','add',...
                            'tag', 'add');
    S.pb.subExe = uicontrol('style','push', ...
                            'Parent',manipBox1,...
                            'string','subtract',...
                            'tag', 'sub');
    S.pb.divExe = uicontrol('style','push', ...
                            'Parent',manipBox1,...
                            'string','divide',...
                            'tag', 'div');
    S.pb.mulExe = uicontrol('style','push', ...
                            'Parent',manipBox1,...
                            'string','multiply',...
                            'tag', 'mul');
    set( manipBox1, 'Sizes', [-1 -2 -2 -2 -2]);
    
    manipBox2 = uiextras.HBox('Parent',editBox,...
                              stdSpacing{:});
    matchPanel = uiextras.Panel('Parent',manipBox2,...
                                'Title', 'Match');
    manipBox2a = uiextras.HBox('Parent',matchPanel,...
                               stdSpacing{:});
    %        matchMinBox = uiextras.VBox('Parent', manipBox2,...
    %                                    stdSpacing{:});
    %        matchMaxBox = uiextras.VBox('Parent', manipBox2,...
    %                                    stdSpacing{:});
    manipBox2vBox1 = uiextras.VBox('Parent',manipBox2a, ...
                                   stdSpacing{:});
    manipBox2vBox2 = uiextras.VBox('Parent',manipBox2a, ...
                                   stdSpacing{:});
    manipBox2vBox3 = uiextras.VBox('Parent',manipBox2a, ...
                                   stdSpacing{:});
    manipBox2vBox4 = uiextras.VBox('Parent',manipBox2a, ...
                                   stdSpacing{:});
    S.cb.scale = uicontrol('Parent', manipBox2vBox1,...
                           'style','checkbox',...
                           'value',1,...
                           'tag','match',...
                           'string','scale');
    S.cb.offset = uicontrol('Parent', manipBox2vBox1,...
                            'style','checkbox',...
                            'value',0,...
                            'tag','match',...
                            'string','offset');
    S.tx.min = uicontrol('style','text',...
                         'Parent',manipBox2vBox2,...
                         'string','Min: ');
    S.ed.min = uicontrol('style','edit',...
                         'Parent', manipBox2vBox3,...
                         'string', '0.2',...
                         'tag', 'min');
    S.tx.max = uicontrol('style','text',...
                         'Parent',manipBox2vBox2,...
                         'string','Max: ');
    S.ed.max = uicontrol('style','edit',...
                         'Parent', manipBox2vBox3,...
                         'string', '0.25',...
                         'tag', 'max');
    S.pb.matchExe = uicontrol('style','push', ...
                              'Parent',manipBox2vBox4,...
                              'string','match',...
                              'tag', 'scale');
    set( mfBox, 'Sizes', [-1 -4 ]);
    set( manipBox2a, 'Sizes', [-4 -2 -3 -3]);
    
    % guinier controls
    manipBox3 = uiextras.HBox('Parent',editBox,...
                              stdSpacing{:});
    guinierPanel = uiextras.Panel('Parent',manipBox3,...
                                  'Title', 'Guinier Range');
    guinierBox = uiextras.HBox('Parent',guinierPanel,...
                               stdSpacing{:});
    guiniervBox1 = uiextras.VBox('Parent',guinierBox, ...
                                 stdSpacing{:});
    guiniervBox2 = uiextras.VBox('Parent',guinierBox, ...
                                 stdSpacing{:});
    guiniervBox3 = uiextras.VBox('Parent',guinierBox, ...
                                 stdSpacing{:});
    guiniervBox4 = uiextras.VBox('Parent',guinierBox, ...
                                 stdSpacing{:});
    S.tx.guinierMin = uicontrol('Parent',guiniervBox1,...
                                'style','text',...
                                'string','min Q:');
    S.tx.guinierMax = uicontrol('Parent',guiniervBox1,...
                                'style','text',...
                                'string','max Q:');
    S.ed.guinierMin = uicontrol('style','edit',...
                                'Parent', guiniervBox2,...
                                'string', '0.01',...
                                'tag', 'min');        
    S.ed.guinierMax = uicontrol('style','edit',...
                                'Parent', guiniervBox2,...
                                'string', '0.02',...
                                'tag', 'max'); 
    
    manipBox9 = uiextras.HBox('Parent',editBox,...
                              stdSpacing{:});
    S.pb.resetExe = uicontrol('style','push',...
                              'Parent', manipBox9,...
                              'string','reset',...
                              'tag','reset');
    set( editBox, 'Sizes', [40, 45, 70, 70, 30]); 
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
    controls = uiextras.HBox('Parent', controlsPanel, stdSpacing{:});
    plotControls = uiextras.VBox('Parent', controls,...
                                 stdSpacing{:});

    axisControls = uiextras.VButtonGroup('Parent',plotControls, stdSpacing{:});                                  
    S.cb.logx = uicontrol('Parent', axisControls,...
                          'style','checkbox',...
                          'value',1,...
                          'tag','plot',...
                          'string','logx');
    S.cb.logy = uicontrol('Parent', axisControls,...
                          'style','checkbox',...
                          'value',1,...
                          'tag','plot',...
                          'string','logy');
    S.bg.plotType = uiextras.VButtonGroup('Parent',plotControls,...
                                          'Buttons',{'standard','guinier','guinier rod','kratky',},...
                                          stdSpacing{:},...
                                          'SelectedChild', 1,...
                                          'SelectionChangeFcn',{@myPlot,S});
    set( plotControls, 'Sizes', [-1 -2]);
    
%%s    minMaxVal = uiextras.VBox('Parent',plotControls, stdSpacing{:});
%%s    S.tx.qmin = uicontrol('Parent',minMaxVal,...
%%s                          'style','text',...
%%s                          'string','Qmin:');
%%s    S.tx.qmax = uicontrol('Parent',minMaxVal,...
%%s                          'style','text',...
%%s                          'string','Qmax:');  
%%s    minMaxControls = uiextras.VBox('Parent',plotControls, stdSpacing{:});                                       
%%s    S.ed.qmin = uicontrol('Parent',minMaxControls,...
%%s                          'style','edit',...
%%s                          'tag','qrange',...
%%s                          'string','0');
%%s    S.ed.qmax = uicontrol('Parent',minMaxControls,...
%%s                          'style','edit',...
%%s                          'tag','qrange',...
%%s                          'string','0.4');

    S.pb.plot = uicontrol('Parent', controls,...
                          'style','push',...
                          'tag','plot',...
                          'string','plot');
    S.pb.save = uicontrol('Parent', controls,...
                          'style','push',...
                          'tag','plot',...  
                          'string','save plot');

    S.axes = axes('Parent',plotPanel,...
                  'ActivePositionProperty', 'OuterPosition');
    
    set([S.pb.setupFile],'callback', {@loadFiles,S});
    set([S.pb.mfSelect],'callback', {@pickFile,S});
    set([S.pb.subExe, S.pb.addExe],'callback', {@subtract,S});
    set([S.pb.mulExe, S.pb.divExe],'callback', {@divide,S});
    set([S.pb.matchExe],'callback', {@scale,S});
    set([S.pb.resetExe],'callback', {@reset,S});
    set([S.ls.filesList],'callback', {@display,S});      
    set([S.cb.logx,S.cb.logy,S.pb.plot], 'callback',{@myPlot,S});
    guidata(S.pb.plot, S);
    %guidata(gcbo, S)
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
    %         S = guidata(S.pb.setupFile);
    S = guidata(gcbo);
    [S.DATA.setupfile,pathname] = uigetfile( ...
        '*.txt;*.hst',...
        'Pick the setup file','/home/schowell/Dropbox/gw_phd/research/NIST/0811NIST/datafit');
    S.DATA.iqfit=iqfit_readsetup(str2mat(strcat(pathname,S.DATA.setupfile)));
    set(S.ls.filesList, 'String', {S.DATA.iqfit(:).title});
    set(S.pb.setupFile, 'String', {S.DATA.setupfile});
    S.DATA.iqfit=iqfit_getdata(S.DATA.iqfit,'readiq',1,'nskip',str2double(get(S.ed.nskip,'string')));  % !!add a reload iq checkbox or button
%          calc = ({'.q';'.IqRaw';'.std';'.sigmaq';'.meanq'});size(calc,1);
%          for i=1:size(S.DATA.iqfit(:).prefix,2)
%              temp=loadxy(fullfile(S.DATA.iqfit(i).datadir,S.DATA.iqfit(i).prefix),'#','nskip',str2double(get(S.ed.nskip,'string'))); % calculate values for each new file
%              for j=1:size(calc,2); eval([['S.DATA.',varnames{i},calc{i}] '=temp(:,i)']); end % store values
%              eval([['S.DATA.iqfit.',varnames{i},'.all'] '=temp'])
%          end
%         guidata(varargin{1},S)
    guidata(gcbo,S);
end

%-------------------------------------------------------------------------%
function [] = myPlot(varargin)
    S = varargin{3};  % Get the structure.
    S = guidata(gcbo);
    set(S.pb.plot,'string','replot')
    cla reset
    L = get(S.ls.filesList,{'string','value'});
    hold all
    for i=1:size(L{2},2)
        disp(['plotting: ' L{1}{L{2}(i)}])
        switch S.bg.plotType.SelectedChild
          case 1 % standard
            xyplot(S.DATA.iqfit(L{2}(i)).iq);
            mylabel('standard');
          case 2 % guinier
            xyplot(guinier(S.DATA.iqfit(L{2}(i)).iq));
            mylabel('guinier');
          case 3 % guinier rod
            xyplot(guinier_rod(S.DATA.iqfit(L{2}(i)).iq));
            mylabel('guinier rod');
          case 4 % kratky
            xyplot(kratky(S.DATA.iqfit(L{2}(i)).iq));
            mylabel('kratky');
            %                 kratkylabel
          otherwise
            disp(' Not supported yet!');
        end
    end
    axis tight
    if get(S.cb.logx,'value');set(gca,'xscale','log');end;
    if get(S.cb.logy,'value');set(gca,'yscale','log');end;
    %          xlim([str2double(get(S.ed.qmin,'string')) str2double(get(S.ed.qmax,'string'))])
    guidata(gcbo,S);
    %guidata(S.pb.plot,S)
end
%-------------------------------------------------------------------------%
function [] = pickFile(varargin)
    S = varargin{3};  % Get the structure.
    S = guidata(gcbo);
    %S = guidata(S.pb.mfSelect);
    masterFile = get(S.ls.filesList,{'string','value'});
    if 1 ~= size(masterFile{2},2)
        display('! please only select one file from the list !');
    else
        %             masterFile{1}{masterFile{2}}
        set(S.ed.masterFile,'string',masterFile{1}{masterFile{2}});
        S.masterFile.iq = S.DATA.iqfit(masterFile{2}).iq;
    end
    %guidata(S.pb.mfSelect,S);
    guidata(gcbo,S);
end
%-------------------------------------------------------------------------%
function [] = subtract(varargin)
    S = varargin{3};  % Get the structure.
    S = guidata(gcbo);
    %S = guidata(S.pb.subExe);
    
    tagname = get(varargin{1}, 'Tag');
    switch tagname
      case 'sub'
        addSub=-1;
        dispStr = {'subracting: ',' from '};
      case 'add'
        addSub=1;
        dispStr = {'adding: ',' to '};
      otherwise
        disp('case not supported yet (only add and subtract)');
    end
    L = get(S.ls.filesList,{'string','value'});
    
    % interpolate the file being subtracted then do the subtraction
    if get(S.cb.newFile,'value')
        nNew = size(L{1},1)+1;
        S.DATA.iqfit(nNew) = S.DATA.iqfit(L{2}(1));
        S.DATA.iqfit(nNew).iq
        S.DATA.iqfit(nNew).title = [S.DATA.iqfit(nNew).title,'*'];
        for i=2:size(L{2},2)
            disp([dispStr{1} ,S.DATA.iqfit(L{2}(i)).title, dispStr{2}, S.DATA.iqfit(nNew).title]);
            S.DATA.iqfit(nNew).iq(:,2) = S.DATA.iqfit(nNew).iq(:,2) ...
                + addSub * interp1q(S.DATA.iqfit(L{2}(i)).iq(:,1), ...
                                    S.DATA.iqfit(L{2}(i)).iq(:,2), ...
                                    S.DATA.iqfit(L{2}(nNew)).iq(:,1));
        end
        set(S.ls.filesList, 'String', {S.DATA.iqfit(:).title});
    else
        S.subFile.str = get(S.ed.masterFile,'string');
        for i=1:size(L{2},2)
            disp([dispStr{1} ,S.subFile.str, dispStr{2}, L{1}{L{2}(i)}]);
            S.masterFile.interp = interp1q(S.masterFile.iq(:,1), S.masterFile.iq(:,2), S.DATA.iqfit(L{2}(i)).iq(:,1));
            S.DATA.iqfit(L{2}(i)).iq(:,2) = S.DATA.iqfit(L{2}(i)).iq(:,2) + addSub * S.masterFile.interp;
        end
    end
    guidata(gcbo,S);
end
%-------------------------------------------------------------------------%
function [] = divide(varargin)
    S = varargin{3};  % Get the structure.
    S = guidata(gcbo);
    %S = guidata(S.pb.divExe);
    S.masterFile.str = get(S.ed.masterFile,'string');
    tagname = get(varargin{1}, 'Tag');
    switch tagname
      case 'div'
        divMul=-1;
        dispStr = {'dividing: ',' by '};
      case 'mul'
        divMul=1;
        dispStr = {'multiplying: ',' by '};
      otherwise
        disp('case not supported yet (only add and subtract)');
    end
    L = get(S.ls.filesList,{'string','value'});
    % for i=1:size(L{1},1)
    %     if strcmp(S.masterFile.str, L{1}(i))
    %         S.masterFile.iq = S.DATA.iqfit(i).iq;
    %         break
    %     end
    % end
    % interpolate the file being subtracted then do the subtraction
    for i=1:size(L{2},2)
        disp([dispStr{1} , L{1}{L{2}(i)}, dispStr{2}, S.masterFile.str ]);
        S.masterFile.interp = interp1q(S.masterFile.iq(:,1), S.masterFile.iq(:,2), S.DATA.iqfit(L{2}(i)).iq(:,1));
        S.DATA.iqfit(L{2}(i)).iq(:,2) = S.DATA.iqfit(L{2}(i)).iq(:,2) .* S.masterFile.interp.^divMul ;
        %             S.DATA.iqfit(L{2}(i)).iq(:,2)
    end
    %guidata(S.pb.divExe,S)
    guidata(gcbo,S);
    %guidata(varargin{1},S)
end
%-------------------------------------------------------------------------%
function [] = scale(varargin)
    S = varargin{3};  % Get the structure.
                      %S = guidata(S.pb.subExe);
    S = guidata(gcbo);
    masterFile.str = get(S.ed.masterFile,'string');
    L = get(S.ls.filesList,{'string','value'});
    min = str2double(get(S.ed.min,'string'));
    max = str2double(get(S.ed.max,'string'));
    s=0;if get(S.cb.scale,'value');s = 1; end;
    o=0;if get(S.cb.offset,'value');o = 1;end;
    % scale the data
    for i=1:size(L{2},2)
        disp(['scaling ' , L{1}{L{2}(i)}, ' to match ', masterFile.str, ' between ', num2str(min),' to ', num2str(max)]);
        [S.DATA.iqfit(L{2}(i)).iq(:,[1,2]), scalefactor] = ...
            match( S.DATA.iqfit(L{2}(i)).iq(:,[1,2]) , ...
                   S.masterFile.iq(:,[1,2]), [min,max],'scale', ...
                   s, 'offset', o);
    end
    guidata(gcbo,S);
end
%-------------------------------------------------------------------------%
function [] = display(varargin)
    S = varargin{3};  % Get the structure.
    S = guidata(gcbo);
    %         tagname = get(varargin{1}, 'Tag');
    L = get(S.ls.filesList,{'string','value'});
    S.DATA.iqfit(L{2}(1)).guinier_range(1)
    set(S.ed.guinierMax,'string',num2str(S.DATA.iqfit(L{2}(1)).guinier_range(1)));
    set(S.ed.guinierMin,'string',num2str(S.DATA.iqfit(L{2}(1)).guinier_range(2)));
    for i=1:size(L{2},2)
        disp([L{1}{L{2}(i)}, ' guinier range: ', ...
              num2str(S.DATA.iqfit(L{2}(1).guinier_range(1))), ...
              ' to ', num2str(S.DATA.iqfit(L{2}(1).guinier_range(2))) ]);
    end
    myPlot(varargin);
    guidata(gcbo,S);
end
%-------------------------------------------------------------------------%
function [] = reset(varargin)
    S = varargin{3};  % Get the structure.
    S = guidata(gcbo);
    L = get(S.ls.filesList,{'string','value'});
    
    for i=1:size(L{2},2)
        disp(['resetting ' , L{1}{L{2}(i)}, ' to raw data']);
        S.DATA.iqfit(L{2}(i)).iq = S.DATA.iqfit(L{2}(i)).iq_raw;
    end
    guidata(gcbo,S);
end
%-------------------------------------------------------------------------%
function [] = oldLoadFiles(varargin)
    S = varargin{3};
    S = guidata(S.pb.getFiles);
    [filename,pathname] = uigetfile( ...
        {'*.*','All Files (*.*)'},...
        'Pick a file', ...
        'MultiSelect','on',...
        '/home/schowell/Dropbox/gw_phd/research/NIST/0811NIST/datafit/');
    
    oldstr = get(S.ls.filesList,'string'); % The string as it is now.
    calc = ({'.q';'.IqRaw';'.std';'.sigmaq';'.meanq'});size(calc,1);
    %             class(filename)
    if 'char' == class(filename);filename={filename}; end;
    varnames=genvarname(filename);
    for i=1:size(filename,2)
        temp=loadxy(fullfile(pathname,filename{i}),'#','nskip',str2double(get(S.ed.nskip,'string'))); % calculate values for each new file
        for j=1:size(calc,2); eval([['S.DATA.',varnames{i},calc{i}] '=temp(:,i)']); end % store values
        eval([['S.DATA.',varnames{i},'.all'] '=temp'])
    end
    if strcmp(oldstr,'no files loaded');
        set(S.ls.filesList,'string',varnames);         
    elseif 1==size(oldstr,1);
        %set(S.ls.filesList,'string',{oldstr,varnames{:}});
        set(S.ls.filesList,'string',[{oldstr},varnames]);
    else
        %set(S.ls.filesList,'string',{oldstr{:},varnames{:}});
        set(S.ls.filesList,'string',[{oldstr},varnames]);
    end
    guidata(varargin{1},S)
end
%-------------------------------------------------------------------------%
end

