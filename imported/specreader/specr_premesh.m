function specr(varargin)
% SPECR Program to read spec files
% 
% Copyright 2009 Zhang Jiang

hFigSpecr = findall(0,'Tag','specr_Fig');
if isempty(hFigSpecr)
    initFigure;
else
    figure(hFigSpecr);
    return;
end

% --- turn off waring;
warning off MATLAB:Axes:NegativeDataInLogAxis;


%================================================================
% --- initialize figure layout
%================================================================
function initFigure
% --------------------------------
% --- main figure handle
% --------------------------------
posScreen   = get(0,'screenSize');
hFigWidth   = 700;
hFigHeight  = 401;
% hFigPos     = [...
%      posScreen(3)/2-hFigWidth/2,...
%      posScreen(4)/2-hFigHeight/2,...
%      hFigWidth,hFigHeight];
%hFigPos = [    5   724   697   401];
hFigPos     = [...
     5,...
     posScreen(4)-hFigHeight-75,...
     hFigWidth,hFigHeight];
hFigSpecr = figure(...
    'BackingStore','on',...
    'Units','pixels',...
    'DockControls','off',...
    'Resize','on',...
    'ResizeFcn',@specr_ResizeFcn,...
    'PaperOrient','portrait',...
    'PaperPositionMode','auto',...
    'IntegerHandle','off',...
    'NumberTitle','off',...
    'MenuBar','none',...
    'Toolbar','none',...
    'Name','Spec Reader',...
    'Position',hFigPos,...
    'HandleVisibility','callback',...
    'Tag','specr_Fig',...
    'CreateFcn',@specr_CreateFcn,...
    'WindowButtonMotionFcn',@specr_WindowButtonMotionFcn,...    
    'CloseRequestFcn',@specr_CloseRequestFcn,...
    'UserData',[]);


% --------------------------------
% --- axes handle
% --------------------------------
hAxes = axes(...
    'Parent',hFigSpecr,...
    'Box','on',...
    'XGrid','on',...
    'YGrid','on',...
    'Tag','specr_Axes');

% --------------------------------
% --- file menu handles
% --------------------------------
hMenuFile = uimenu(hFigSpecr,...
    'Label','&File',...
    'Position',1,...
    'HandleVisibility','callback',...
    'Tag','specr_MenuFile');
hMenuFileOpen = uimenu(hMenuFile,...
    'Label','&Open Spec File...',...
    'Position',1,...
    'HandleVisibility','callback',...
    'Tag','specr_MenuFileOpen',...
    'Accelerator','O',...
    'callback',@openspec);
hMenuFileClose = uimenu(hMenuFile,...
    'Label','&Close',...
    'Position',2,...
    'HandleVisibility','callback',...
    'Tag','specr_MenuFileClose',...
    'Accelerator','W',...
    'callback',@specr_CloseRequestFcn);
hMenuFileSave = uimenu(hMenuFile,...
    'Label','&Save',...
    'Position',3,...
    'Separator','on',...
    'HandleVisibility','callback',...
    'Tag','specr_MenuFileSave',...
    'Accelerator','S',...
    'callback','curvesave');
hMenuFileSave2Workspace = uimenu(hMenuFile,...
    'Label','Save to &Workspace',...
    'Position',4,...
    'HandleVisibility','callback',...
    'Tag','specr_MenuFileSave2Workspace',...
    'callback','save2workspace');
hMenuFilePreferences = uimenu(hMenuFile,...
    'Label','Pre&ferences...',...
    'Position',5,...
    'Separator','on',...
    'HandleVisibility','callback',...
    'Tag','specr_MenuFilePreferences',...
    'callback','preferences');
hMenuFilePageSetup = uimenu(hMenuFile,...
    'Label','Pa&ge Setup...',...
    'Position',6,...
    'Separator','on',...
    'HandleVisibility','callback',...
    'Tag','specr_MenuFilePageSetup',...
    'callback','pagesetupdlg');
hMenuFilePrintPreview = uimenu(hMenuFile,...
    'Label','Print Pre&view...',...
    'Position',7,...
    'HandleVisibility','callback',...
    'Tag','specr_MenuFilePrintPreview',...
    'callback',@specr_PrintPreviewFcn);
hMenuFilePrint = uimenu(hMenuFile,...
    'Label','&Print...',...
    'Position',8,...
    'HandleVisibility','callback',...
    'Tag','specr_MenuFilePrint',...
    'Accelerator','P',...
    'callback',@specr_PrintFcn);
hMenuFilePrintToFigure = uimenu(hMenuFile,...
    'Label','Print to Figure...',...
    'Position',9,...
    'Accelerator','G',...
    'HandleVisibility','callback',...
    'Tag','specr_MenuFilePrintToFigure',...
    'callback','print2figure');

% --------------------------------
% --- tools menu handles
% --------------------------------
hMenuTools = uimenu(hFigSpecr,...
    'Label','&Tools',...
    'Position',2,...
    'HandleVisibility','callback',...
    'Tag','specr_MenuTools');
hMenuToolsShowScan = uimenu(hMenuTools,...
    'Label','Sh&ow Current Scan',...
    'Callback','showscan',...
    'HandleVisibility','callback',...
    'Tag','specr_MenuToolsShowScan');
hMenuToolsShowMotorPos = uimenu(hMenuTools,...
    'Label','Sho&w Current Motor Positions',...
    'Callback','showmotorposition',...
    'HandleVisibility','callback',...
    'Tag','specr_MenuToolsShowMotorPos');
hMenuToolsCopyFigure = uimenu(hMenuTools,...
    'separator','on',...        
    'Label','Copy Figure',...
    'Callback','editmenufcn(gcbf,''EditCopyFigure'')',...
    'HandleVisibility','callback',...
    'Tag','specr_MenuToolsCopyFigure');
hMenuToolsCopyFigure = uimenu(hMenuTools,...
    'Label','Copy Options...',...
    'Callback','editmenufcn(gcbf,''EditCopyOptions'')',...
    'HandleVisibility','callback',...
    'Tag','specr_MenuToolsCopyOptions');
hMenuToolsInvertX = uimenu(hMenuTools,...
    'separator','on',...    
    'Label','&Invert X Axis',...
    'Callback','invertxaxis',...
    'HandleVisibility','callback',...
    'Tag','specr_MenuToolsInvertX');
hMenuToolsFoldX = uimenu(hMenuTools,...
    'Label','Fold X &Axis (New Figure) ...',...
    'Callback','foldxaxis',...
    'HandleVisibility','callback',...
    'Tag','specr_MenuToolsFoldX');
hMenuToolsSmooth = uimenu(hMenuTools,...
    'Label','Smoot&h Curve',...
    'Callback','curvesmooth',...
    'HandleVisibility','callback',...
    'Tag','specr_MenuToolsSmooth');
hMenuToolsDev = uimenu(hMenuTools,...
    'Label','&Derivate',...
    'Callback','curvederivative',...
    'HandleVisibility','callback',...
    'Tag','specr_MenuToolsDev');
hMenuToolsFFT = uimenu(hMenuTools,...
    'Label','Fast Fourier Tranform (For Reflectivity in Qz)',...
    'Callback',@specr_xrr_fft,...
    'HandleVisibility','callback',...
    'Tag','specr_MenuToolsFFT');
hMenuToolsSubBKG = uimenu(hMenuTools,...
    'Label','Subtract Constant &Background',...
    'Callback','subtractbkg',...
    'separator','on',...
    'HandleVisibility','callback',...
    'Accelerator','B',...    
    'Tag','specr_MenuToolsISubBKG');
hMenuToolsScanMerge = uimenu(hMenuTools,...
    'Label','&Merge Scans',...
    'HandleVisibility','callback',...
    'Accelerator','M',...
    'Callback','scanmerge');
hMenuToolsConvert = uimenu(hMenuTools,...
    'Label','&Convert 2Theta to Qz (For Reflectivity and Longitudinal Diffuse)',...
    'Callback','convert2theta2qz',...
    'HandleVisibility','callback',...
    'Accelerator','T',...
    'Tag','specr_MenuToolsConvert');
hMenuToolsFootprint = uimenu(hMenuTools,...
    'Label','&Footprint Correction (For Reflectivity in Qz Only)',...
    'Callback','footprint',...
    'HandleVisibility','callback',...
    'Tag','specr_MenuToolsFootprint');
hMenuToolsNormalize = uimenu(hMenuTools,...
    'Label','&Normalize...',...
    'HandleVisibility','callback',...
    'Callback','curvenormalize');
hMenuToolsRocking = uimenu(hMenuTools,...
    'Label','&Geometric Correction for Rocking Scan (hscan) ...',...
    'HandleVisibility','callback',...
    'Callback','georocking');
hMenuToolsEngwav = uimenu(hMenuTools,...
    'Label','Calculate &Energy/Wavelength...',...
    'Separator','on',...
    'HandleVisibility','callback',...
    'Callback','engwav');
hMenuToolsTrueRef = uimenu(hMenuTools,...
    'Label','&True Reflectivity...',...
    'HandleVisibility','callback',...
    'Callback','trueref');
hMenuToolsSettings = uimenu(hMenuTools,...
    'Label','&Settings...',...
    'Separator','on',...
    'HandleVisibility','callback',...
    'Callback','specrsettings');
    
% --------------------------------
% --- help menu handles
% --------------------------------
hMenuHelp = uimenu(hFigSpecr,...
    'Label','&Help',...
    'Position',3,...
    'HandleVisibility','callback',...
    'Tag','specr_MenuHelp');    
hMenuHelpSpecr = uimenu(hMenuHelp,...
    'Label','&Spec Reader Help',...
    'HandleVisibility','callback',...
    'Callback',@specr_Help);
hMenuHelpAbout = uimenu(hMenuHelp,...
    'Label','&About Spec Reader',...
    'HandleVisibility','callback',...
    'Separator','on',...
    'Callback',@specr_AboutSpecr);
    
% --------------------------------
% --- toolbar handles
% --------------------------------
icons = load('icons.mat');
hToolbar = uitoolbar(hFigSpecr,...
    'Tag','specr_Toolbar');
hToolbarOpen = uipushtool(hToolbar,...
    'CData',icons.opendoc,...
    'TooltipString','Open Spec File',...
    'ClickedCallback',@openspec,...
    'Tag','toolbarOpen');
hToolbarSave = uipushtool(hToolbar,...
    'CData',icons.savedoc,...
    'TooltipString','Save Data',...
    'ClickedCallback','curvesave',...
    'Tag','toolbarSave');
hToolbarPrint = uipushtool(hToolbar,...
    'CData',icons.printdoc,...
    'TooltipString','Print Figure',...
    'ClickedCallback',@specr_PrintFcn,...
    'Tag','toolbarPrint');
hToolbarEditPlot = uitoggletool(hToolbar,...
    'CData',icons.iconpointer,...
    'TooltipString','Edit Plot',...
    'ClickedCallback',@toolbarEditPlotFcn,...
    'Separator','on',...
    'Tag','toolbarEditPlot');
hToolbarZoom = uitoggletool(hToolbar,...
    'CData',icons.iconzoomin,...
    'TooltipString','Zoom',...
    'Separator','on',...
    'State','off',...
    'ClickedCallback',@toolbarZoomFcn,...
    'Tag','toolbarZoom');
hToolbarPan = uitoggletool(hToolbar,...
    'CData',icons.iconpan,...
    'TooltipString','Pan',...
    'ClickedCallback',@toolbarPanFcn,...
    'Tag','toolbarPan');
hToolbarDataCursor = uitoggletool(hToolbar,...
    'CData',icons.icondatatip,...
    'TooltipString','Data Cursor',...
    'ClickedCallback',@toolbarDataCursorFcn,...
    'Separator','on',...
    'Tag','toolbarDataCursor');
hToolbarMouseTracking = uitoggletool(hToolbar,...
    'CData',icons.iconmousetrack,...
    'TooltipString','Mouse Tracking On/Off',...
    'ClickedCallback',@toolbarMouseTrackingCallbackFcn,...
    'State','on',...
    'Tag','toolbarMouseTracking');
hToolbarLegend = uitoggletool(hToolbar,...
    'CData',icons.iconlegend,...
    'TooltipString','Legend On/Off',...
    'ClickedCallback',@toolbarLegendFcn,...
    'Tag','toolbarLegend');
hToolbarGrid = uitoggletool(hToolbar,...
    'CData',icons.icongrid,...
    'TooltipString','Grid On/Off',...
    'ClickedCallback','grid',...
    'State','on',...
    'Tag','toolbarGrid');
hToolbarPlottoolsOff = uipushtool(hToolbar,...
    'CData',icons.iconplottoolsoff,...
    'TooltipString','Hide Plot Tools',...
    'ClickedCallback',@toolbarPlottoolsOffFcn,...
    'Separator','on',...
    'Enable','off',...
    'Tag','toolbarPlottoolsOff');
hToolbarPlottoolsOn = uipushtool(hToolbar,...
    'CData',icons.iconplottoolson,...
    'TooltipString','Show Plot Tools',...
    'ClickedCallback',@toolbarPlottoolsOnFcn,...
    'Enable','on',...
    'Tag','toolbarPlottoolsOn');
hToolbarInvert = uipushtool(hToolbar,...
    'CData',icons.iconinvertx,...
    'Separator','on',...
    'TooltipString','Invert X Axis',...
    'ClickedCallback','invertxaxis',...
    'Tag','toolbarInvert');
hToolbarFold = uipushtool(hToolbar,...
    'CData',icons.iconfoldx,...
    'TooltipString','Fold X Axis',...
    'ClickedCallback','foldxaxis',...
    'Tag','toolbarFold');
hToolbarSmooth = uipushtool(hToolbar,...
    'CData',icons.iconsmooth,...
    'TooltipString','Smooth Curve',...
    'ClickedCallback','curvesmooth',...
    'Tag','toolbarSmooth');
hToolbarDev = uipushtool(hToolbar,...
    'CData',icons.icondev,...
    'TooltipString','Derivate',...
    'ClickedCallback','curvederivative',...
    'Tag','toolbarDev');
hToolbarFFT = uipushtool(hToolbar,...
    'CData',icons.iconfft,...
    'TooltipString','FFT of Reflectivity in Qz',...
    'ClickedCallback',@specr_xrr_fft,...
    'Tag','toolbarFFT');
hToolbarBkg = uipushtool(hToolbar,...
    'Separator','on',...       
    'CData',icons.iconbk,...
    'TooltipString','Subtract Background',...
    'ClickedCallback','subtractbkg',...
    'Tag','toolbarSubtractbkg');
hToolbarMerge = uipushtool(hToolbar,...
    'CData',icons.iconmerge,...
    'TooltipString','Merge Scans',...
    'ClickedCallback','scanmerge',...
    'Tag','toolbarMerge');
hToolbarConvert = uipushtool(hToolbar,...
    'CData',icons.iconconvert,...
    'TooltipString','Convert 2Theta to Qz (For Reflectivity and Longitudinal Diffuse)',...
    'ClickedCallback','convert2theta2qz',...
    'Tag','toolbarConvert');
hToolbarFootprint = uipushtool(hToolbar,...
    'CData',icons.iconfootprint,...
    'TooltipString','Footprint Correction (For Reflectivity in Qz Space Only)',...
    'ClickedCallback','footprint',...
    'Tag','toolbarFootprint');
hToolbarGeorocking = uipushtool(hToolbar,...
    'CData',icons.iconrocking,...
    'TooltipString','Geometric Correction For Rocking Scan (hscan Only)',...
    'ClickedCallback','georocking',...
    'Tag','toolbarGeorocking');
hToolbarShowScan = uipushtool(hToolbar,...
    'CData',icons.iconshowscan,...
    'separator','on',...
    'TooltipString','Show Current Scan',...
    'ClickedCallback','showscan',...
    'Tag','toolbarShowScan');
hToolbarShowMotor = uipushtool(hToolbar,...
    'CData',icons.iconshowmotorpos,...
    'TooltipString','Show Current Motor Position',...
    'ClickedCallback','showmotorposition',...
    'Tag','toolbarShowMotor');
hToolbarSettings = uipushtool(hToolbar,...
    'CData',icons.iconsettings,...
    'Separator','on',...    
    'TooltipString','System Settings',...
    'ClickedCallback','specrsettings',...
    'Tag','toolbarSettings');
hToolbarMonitorErase = uitoggletool(hToolbar,...
    'CData',icons.iconerase,...
    'Separator','on',...    
    'TooltipString','Erase Mode On/Off',...
    'ClickedCallback',@toolbarMonitorEraseCallbackFcn,...
    'State','on',...
    'Tag','toolbarMonitorErase');
hToolbarMonitor = uitoggletool(hToolbar,...
    'CData',icons.iconmonitor.play,...
    'TooltipString','Scan Monitor On/Off',...
    'ClickedCallback','monitorscan',...
    'State','off',...
    'Tag','toolbarMonitor');

% --------------------------------
% --- pushbotton handles
% --------------------------------
hPushbuttonSelectScan = uicontrol(hFigSpecr,...
    'Style','pushbutton',...
    'String','Select Scan',...
    'TooltipString',' Select Scan',...
    'Tag','specr_PushbuttonSelectScan',...
    'callback',@selectscan);
hPushbuttonRefresh = uicontrol(hFigSpecr,...
    'Style','pushbutton',...
    'String','Replot',...
    'TooltipString',' Replot',...
    'Tag','specr_PushbuttonRefresh',...
    'callback','refreshscanplot');

% --------------------------------
% --- popupmenu handles
% --------------------------------
hPopupmenuX = uicontrol(hFigSpecr,...
    'Style','popupmenu',...
    'Background','w',...
    'String','X Axis',...
    'TooltipString',' Select X Axis',...
    'Tag','specr_PopupmenuX',...
    'callback',@scanplot);
hPopupmenuY = uicontrol(hFigSpecr,...
    'Style','popupmenu',...
    'Background','w',...
    'String','Y Axis',...
    'TooltipString',' Select Y Axis',...
    'Tag','specr_PopupmenuY',...
    'callback',@scanplot);
hPopupmenuPlotStyle = uicontrol(hFigSpecr,...
    'Style','popupmenu',...
    'Background','w',...
    'String',{'linear','logx','logy','logxy'},...
    'TooltipString',' Plot Style',...
    'Tag','specr_PopupmenuPlotStyle',...
    'callback',@plotstyle);

% --------------------------------------
% --- mouse tracking text
% ---------------------------------------
uicontrol('Parent',hFigSpecr,'Style','Text',...
    'BackgroundColor',get(hFigSpecr,'color'),...
    'String','',                       ...
    'units','normalized',              ...
    'HorizontalAlignment','left',      ...
    'Fontsize',10,...
    'visible','on',...
    'Tag','specr_mouseposition')                ;


%================================================================
% --- things to do when starting specr:
% 1. initalize the settings; save to application data 'settings'
%================================================================
function specr_CreateFcn(hObject,eventdata)
hFigSpecr = hObject;
settings.wavelength = 1.686859478480;
settings.footprintAngle     = 0.5;              % incident side footprint angle
settings.footprintAngleSC   = 0.5;              % detector side footprint angle
settings.georockingSCFlag   = 0;                % 0) no detector side correction 1) yes
settings.qz4Rocking         = 0.15;             % default qz for rocking scan
settings.merge.mode  = 2;        % 1) intensity based 2) # of points based (default) 
settings.merge.interpMethod = 1; % 1) spline (default) 2) linear 3) nearest 4) cubic
settings.monitorPeriod   = 0.5;  % scan monitor period (sec)
settings.monitorAutoPeriodMode = 1; % flag for automatic adjustment of monitor period       1/2: on/off
settings.monitorAutoPeriod = 0.5;   % automatic period
settings.monitorErasemode = 1;   % erase previous scans
settings.file       = '';
settings.scan       = '';
settings.savepath   = '';
settings.trueref.openfiles = {};
settings.trueref.openpath = '';
setappdata(hFigSpecr,'settings',settings);


function specr_xrr_fft(~,~)
hLine = findall(gca,'Type','line');
% --- if no curve plotted, return
if isempty(hLine)
    return;
end
% --- dlg to input normalization factor
for iLine = 1:length(hLine)
    if isempty(strfind(get(hLine(iLine),'tag'),'specr'))
        continue;
    end
    x = get(hLine(iLine),'XData');
    y = get(hLine(iLine),'YData');
    data = [x(:),y(:)];
    xrr_fft(data);
end

%================================================================
% --- specr figure close request function
%================================================================
function specr_CloseRequestFcn(hObject,eventdata)
hFigSpecr = findall(0,'Tag','specr_Fig');
hFigShowScan = findall(0,'Tag','figSpecrShowScan');
hFigShowMotorPos = findall(0,'Tag','figSpecrShowMotorPos');
hFigTrueref = findall(0,'Tag','trueref_Fig');
hPopupmenuX = findall(hFigSpecr,'Tag','specr_PopupmenuX');
hPopupmenuY = findall(hFigSpecr,'Tag','specr_PopupmenuY');
hPopupmenuPlotStyle = findall(hFigSpecr,'Tag','specr_PopupmenuPlotStyle');
hAxes = findall(hFigSpecr,'Tag','specr_Axes');
hTimerMonitor   = timerfindall('Tag','timerMonitor');
settings = getappdata(hFigSpecr,'settings');
file = settings.file;
scan = settings.scan;
% --- if no plot, then close without request
if ~isempty(file) & ~isempty(scan) & isfield(scan,'selection') & ~isempty(scan.selection{1})
    quitButton = questdlg('Quit without saving data ?',...
        'Spec Reader - Confirm Close','Quit','Cancel','Cancel');
    switch quitButton
        case 'Cancel'
            % take no action
            return;
        case 'Quit'
    end
end
resetfigspecr;
warning on MATLAB:Axes:NegativeDataInLogAxis;
if ~isempty(hFigTrueref)
    delete(hFigTrueref);
end
if ~isempty(hFigShowScan)
    delete(hFigShowScan);
end
if ~isempty(hFigShowMotorPos)
    delete(hFigShowMotorPos);
end
delete(hFigSpecr);
return;


%================================================================
% --- specr figure resize function
%================================================================
function specr_ResizeFcn(hObject,eventdata)
hFigSpecr = findall(0,'Tag','specr_Fig');
hAxes = findall(hFigSpecr,'Tag','specr_Axes');
hPushbuttonSelectScan = findall(hFigSpecr,'Tag','specr_PushbuttonSelectScan');
hPushbuttonRefresh = findall(hFigSpecr,'Tag','specr_PushbuttonRefresh');
hPopupmenuX = findall(hFigSpecr,'Tag','specr_PopupmenuX');
hPopupmenuY = findall(hFigSpecr,'Tag','specr_PopupmenuY');
hPopupmenuPlotStyle = findall(hFigSpecr,'Tag','specr_PopupmenuPlotStyle');
hTextMouseTrack = findall(hFigSpecr,'Tag','specr_mouseposition');
figureSize = get(hFigSpecr,'Position');
PosFigureTopCenter = [(figureSize(3))/2,figureSize(4)-35];
try         % in case figure size is too samll that width and height < 0
    set(hPushbuttonSelectScan,...
        'Units','Pixels',...
        'Position',[PosFigureTopCenter(1)-220,PosFigureTopCenter(2),80,25]);
    set(hPopupmenuX,...
        'Units','Pixels',...
        'Position',[PosFigureTopCenter(1)-130,PosFigureTopCenter(2),80,25]);
    set(hPopupmenuY,...
        'Units','Pixels',...
        'Position',[PosFigureTopCenter(1)-40,PosFigureTopCenter(2),80,25]);
    set(hPopupmenuPlotStyle,...
        'Units','Pixels',...
        'Position',[PosFigureTopCenter(1)+50,PosFigureTopCenter(2),80,25]);
    set(hPushbuttonRefresh,...
        'Units','Pixels',...
        'Position',[PosFigureTopCenter(1)+140,PosFigureTopCenter(2),80,25]);    
    set(hTextMouseTrack,...
        'Units','Pixels',...
        'Position',[PosFigureTopCenter(1)+230,PosFigureTopCenter(2)-25,100,50]);        
    set(hAxes,...
        'Units','Pixels',...
        'Position',[80,80,figureSize(3)-115,figureSize(4)-160]);
catch
end

%================================================================
% --- print preview callback function
%================================================================
function specr_PrintPreviewFcn(hObject,eventdata)
hFigSpecr = findall(0,'Tag','specr_Fig');
hHide = [findall(hFigSpecr,'Style','pushbutton');...
         findall(hFigSpecr,'Style','popupmenu')];
%set(hHide,'Visible','off');
hPrintPreview = printpreview(hFigSpecr);
%set(hHide,'Visible','on');


%================================================================
% --- print callback function
%================================================================
function specr_PrintFcn(hObject,eventdata)
hFigSpecr = findall(0,'Tag','specr_Fig');
hHide = [findall(hFigSpecr,'Style','pushbutton');...
         findall(hFigSpecr,'Style','popupmenu')];
if  strcmp(lower(get(findall(hFigSpecr,'Tag','toolbarMouseTracking'),'state')),'on') 
    hHide = [hHide; findall(hFigSpecr,'Tag','specr_mouseposition')];
end;
set(hHide,'Visible','off');
printdlg;
set(hHide,'Visible','on');


%================================================================
% --- toolbar plottools off callback function
%================================================================
function toolbarPlottoolsOffFcn(hObject,eventdata)
hFigSpecr = findall(0,'Tag','specr_Fig');
hToolbarPlottoolsOff = findall(hFigSpecr,'Tag','toolbarPlottoolsOff');
hToolbarPlottoolsOn  = findall(hFigSpecr,'Tag','toolbarPlottoolsOn');
hToolbarEditPlot = findall(hFigSpecr,'Tag','toolbarEditPlot');
hToolbarZoom = findall(hFigSpecr,'Tag','toolbarZoom');
hToolbarPan = findall(hFigSpecr,'Tag','toolbarPan');
hToolbarDataCursor = findall(hFigSpecr,'Tag','toolbarDataCursor');
if strcmp(get(hToolbarPlottoolsOff,'Enable'),'off')
    return;
else
    zoom off;
    pan off;
    datacursormode off;
    set(hToolbarZoom,'State','off');
    set(hToolbarPan,'State','off');
    set(hToolbarDataCursor,'State','off');
    set(hToolbarPlottoolsOff,'Enable','off');
    set(hToolbarPlottoolsOn,'Enable','on');
    plottools off;
end


%================================================================
% --- toobar plottools on callback function
%================================================================
function toolbarPlottoolsOnFcn(hObject,eventdata)
hFigSpecr = findall(0,'Tag','specr_Fig');
hToolbarPlottoolsOff = findall(hFigSpecr,'Tag','toolbarPlottoolsOff');
hToolbarPlottoolsOn  = findall(hFigSpecr,'Tag','toolbarPlottoolsOn');
hToolbarEditPlot = findall(hFigSpecr,'Tag','toolbarEditPlot');
hToolbarZoom = findall(hFigSpecr,'Tag','toolbarZoom');
hToolbarPan = findall(hFigSpecr,'Tag','toolbarPan');
hToolbarDataCursor = findall(hFigSpecr,'Tag','toolbarDataCursor');
if strcmp(get(hToolbarPlottoolsOn,'Enable'),'off')
    return;
else
    plotedit;
    zoom off;
    pan off;
    datacursormode off;
    set(hToolbarEditPlot,'State','on');
    set(hToolbarZoom,'State','off');
    set(hToolbarPan,'State','off');
    set(hToolbarDataCursor,'State','off');
    set(hToolbarPlottoolsOn,'Enable','off');
    set(hToolbarPlottoolsOff,'Enable','on');
    plottools on;
end


%================================================================
% --- toolbar edit plot callback
%================================================================
function toolbarEditPlotFcn(hObject,eventdata)
hFigSpecr = findall(0,'Tag','specr_Fig');
hToolbarEditPlot = findall(hFigSpecr,'Tag','toolbarEditPlot');
hToolbarZoom = findall(hFigSpecr,'Tag','toolbarZoom');
hToolbarPan = findall(hFigSpecr,'Tag','toolbarPan');
hToolbarDataCursor = findall(hFigSpecr,'Tag','toolbarDataCursor');
plotedit;
zoom off;
pan off;
datacursormode off;
set(hToolbarZoom,'state','off');
set(hToolbarPan,'state','off');
set(hToolbarDataCursor,'state','off');

%================================================================
% --- toolbar zoom callback
%================================================================
function toolbarZoomFcn(hObject,eventdata)
hFigSpecr = findall(0,'Tag','specr_Fig');
hToolbarEditPlot = findall(hFigSpecr,'Tag','toolbarEditPlot');
hToolbarZoom = findall(hFigSpecr,'Tag','toolbarZoom');
hToolbarPan = findall(hFigSpecr,'Tag','toolbarPan');
hToolbarDataCursor = findall(hFigSpecr,'Tag','toolbarDataCursor');
plotedit off;
zoom;
pan off;
datacursormode off;
set(hToolbarEditPlot,'state','off');
set(hToolbarPan,'state','off');
set(hToolbarDataCursor,'state','off');

%================================================================
% --- toolbar pan callback
%================================================================
function toolbarPanFcn(hObject,eventdata)
hFigSpecr = findall(0,'Tag','specr_Fig');
hToolbarEditPlot = findall(hFigSpecr,'Tag','toolbarEditPlot');
hToolbarZoom = findall(hFigSpecr,'Tag','toolbarZoom');
hToolbarPan = findall(hFigSpecr,'Tag','toolbarPan');
hToolbarDataCursor = findall(hFigSpecr,'Tag','toolbarDataCursor');
plotedit off;
zoom off;
pan;
datacursormode off;
set(hToolbarEditPlot,'state','off');
set(hToolbarZoom,'state','off');
set(hToolbarDataCursor,'state','off');


%================================================================
% --- toolbar datacuror callback
%================================================================
function toolbarDataCursorFcn(hObject,eventdata)
hFigSpecr = findall(0,'Tag','specr_Fig');
hToolbarEditPlot = findall(hFigSpecr,'Tag','toolbarEditPlot');
hToolbarZoom = findall(hFigSpecr,'Tag','toolbarZoom');
hToolbarPan = findall(hFigSpecr,'Tag','toolbarPan');
hToolbarDataCursor = findall(hFigSpecr,'Tag','toolbarDataCursor');
plotedit off;
zoom off;
pan off;
try
    datacursormode;
catch
end
set(hToolbarEditPlot,'state','off');
set(hToolbarZoom,'state','off');
set(hToolbarPan,'state','off');


%================================================================
% --- toolbar mousetracking callback function
%================================================================
function toolbarMouseTrackingCallbackFcn(hObject,eventdata)
hFigSpecr = findall(0,'Tag','specr_Fig');
hTextMouseTracking = findall(hFigSpecr,'Tag','specr_mouseposition');
if strcmp(get(hObject,'state'),'on')
    set(hTextMouseTracking,'string','');    
    set(hTextMouseTracking,'visible','on');
    set(hFigSpecr,'WindowButtonMotionFcn',@specr_WindowButtonMotionFcn);
else
    set(hTextMouseTracking,'visible','off');
    set(hFigSpecr,'WindowButtonMotionFcn','');    
end

%================================================================
% --- window button motion callback function for mouse tracking
%================================================================
function specr_WindowButtonMotionFcn(hObject,eventdata)
hFigSpecr = findall(0,'Tag','specr_Fig');
if gcf ~= hFigSpecr, return; end;
%set(hFigSpecr,'selected','on');
hAxes = findall(hFigSpecr,'tag','specr_Axes');
pointPosition = get(hAxes,'CurrentPoint');
XLim=get(gca,'XLim');
YLim=get(gca,'YLim');
XLimFlag=(pointPosition(1,1)>=XLim(1) & pointPosition(1,1)<=XLim(2));
YLimFlag=(pointPosition(1,2)>=YLim(1) & pointPosition(1,2)<=YLim(2));
xpos = pointPosition(1,1);
ypos = pointPosition(1,2);
if (XLimFlag == 1 && YLimFlag ==1 )
   set(hFigSpecr,'Pointer','crosshair');
    set(...
        findall(hFigSpecr,'Tag','specr_mouseposition'),...
        'string',{'Mouse Position';['x=',num2str(xpos,'%g')];['y=',num2str(ypos,'%g')]});        
else
   set(hFigSpecr,'Pointer','arrow');
end


%================================================================
% --- toolbar legend callback funcion
%================================================================
function toolbarLegendFcn(hObject,eventdata)
hFigSpecr = findall(0,'Tag','specr_Fig');
curvelegend(hFigSpecr);


%================================================================
% --- toolbar monitorerase callback function
%================================================================
function toolbarMonitorEraseCallbackFcn(hObject,eventdata)
hFigSpecr = findall(0,'Tag','specr_Fig');
settings = getappdata(hFigSpecr,'settings');
if strcmp(get(gcbo,'state'),'off')
    settings.monitorErasemode = 0;      
else
    settings.monitorErasemode = 1;
end
setappdata(hFigSpecr,'settings',settings);
return;

%================================================================
% --- menu specr help callback fcn
%================================================================
function specr_Help(hObject,eventdata)
%helpWeb = fullfile(matlabroot,'toolbox','xraylabtool','help','xraylabtool_page.html');
%helpview(helpWeb);
msgbox('No help!','Help on Spec Reader','Help','modal');
 

%================================================================
% --- menu aboutspecr function callback
%================================================================
function specr_AboutSpecr(hObject,eventdata)
text_string = {...
    'Spec Reader 4.1 (2009-02-03)';...
    'Zhang Jiang';...
    'Adanced Photon Source';...
	'Argonne National Laboratory';...
    'Email: zjiang@aps.anl.gov'};
msgbox(text_string,'About Spec Reader','modal');
%icons = load('icons.mat');
%msgbox(text_string,'About Spec Reader','custom',icons.logo.cdata,icons.logo.colormap,'modal');
