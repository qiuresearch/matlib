function engwave
% ENGWAVE GUI to convert between energy and wavelength (X-ray)
%
% Copyright 2004 Zhang Jiang
% $Reversion: 2.0 $ $Date: 2013/08/17 12:47:23 $

h1 = findall(0,'Tag','figureEngwav');
if isempty(h1)
    initFigure;
else
    figure(h1);
end


%===================================================
% initialize figure layout
%===================================================
function initFigure
screenSize = get(0,'screensize');
figureWidth = 260;
figureHeight = 180;
figureSize = [screenSize(3)/2-figureWidth/2,screenSize(4)/2-figureHeight/2,figureWidth,figureHeight];
h1 = figure(...
    'Units','pixels',...
    'MenuBar','none',...
    'Name','Convert Energy/Wavelength',...
    'NumberTitle','off',...
    'Position',figureSize,...
    'HandleVisibility','callback',...
    'Tag','figureEngwav',...
    'Resize','off',...
    'UserData',[]);
panelSize = [10 figureHeight-90 figureWidth-20 80];
h2 = uipanel(...
    'Parent',h1,...
    'BackgroundColor',get(h1,'Color'),...
    'Title','Select X-ray Energy <===> Wavelength',...
    'Units','pixels',...
    'Position',panelSize);
radiobutton1Size = [20 panelSize(4)-45 panelSize(3)-30 30];
h3 = uicontrol(...
    'Parent',h2,...
    'Units','pixels',...
    'Callback',@radiobuttonEng2Wav_Callback,...    
    'Style','radiobutton',...
    'BackgroundColor',get(h1,'Color'),...
    'Position',radiobutton1Size,...
    'String',{'Energy to Wavelength'},...
    'Tag','radiobuttonEng2Wav',...
    'Value',1);
radiobutton2Size = [20 panelSize(4)-70 panelSize(3)-30 30];
h4 = uicontrol(...
    'Parent',h2,...
    'Units','pixels',...
    'Callback',@radiobuttonWav2Eng_Callback,...    
    'Style','radiobutton',...
    'BackgroundColor',get(h1,'Color'),...
    'Position',radiobutton2Size,...
    'String',{'Wavelength to Energy'},...
    'Tag','radiobuttonWav2Eng',...
    'Value',0);
edit1Size = [10 panelSize(2)-40 110 23];
h5 = uicontrol(...
    'Parent',h1,...
    'Units','pixels',...
    'Style','edit',...
    'Position',edit1Size,...
    'BackgroundColor',[1 1 1],...
    'Tag','edit1',...
    'HorizontalAlignment','right');
edit2Size = [10 edit1Size(2)-35 110 23];
h6 = uicontrol(...
    'Parent',h1,...
    'Units','pixels',...
    'Style','edit',...
    'Position',edit2Size,...
    'BackgroundColor',[1 1 1],...
    'Tag','edit2',...
    'HorizontalAlignment','right');
text1Size = [edit1Size(1)+edit1Size(3)+5 edit1Size(2)-10 30 30];
h7 = uicontrol(...
    'Parent',h1,...
    'Units','pixels',...
    'Style','text',...
    'Position',text1Size,...
    'BackgroundColor',get(h1,'Color'),...
    'Tag','textUnit1',...
    'HorizontalAlignment','left',...
    'String','KeV');
OKSize = [text1Size(1)+text1Size(3) edit1Size(2) figureWidth-text1Size(1)-text1Size(3)-10 25];
h8 = uicontrol(...
    'Parent',h1,...
    'Units','pixels',...
    'Callback',@pushbuttonConvert_Callback,...
    'Style','pushbutton',...
    'String','Convert',...
    'Tag','pushbuttonConvert',...
    'Position',OKSize);
text2Size = [edit2Size(1)+edit2Size(3)+5 edit2Size(2)-10 30 30];
h9 = uicontrol(...
    'Parent',h1,...
    'Units','pixels',...
    'Style','text',...
    'Position',text2Size,...
    'BackgroundColor',get(h1,'Color'),...
    'Tag','textUnit2',...
    'HorizontalAlignment','left',...
    'String','Ang');
cancelSize = [text2Size(1)+text2Size(3) edit2Size(2) figureWidth-text2Size(1)-text2Size(3)-10 25];
h10 = uicontrol(...
    'Parent',h1,...
    'Units','pixels',...
    'Callback','close(findall(0,''Tag'',''figureEngwav''))',...
    'Style','pushbutton',...
    'String','Close',...
    'Tag','pushbuttonClose',...
    'Position',cancelSize);    


function radiobuttonEng2Wav_Callback(obj,eventdata)
set(findobj(gcf,'Tag','radiobuttonEng2Wav'),'Value',1);
set(findobj(gcf,'Tag','radiobuttonWav2Eng'),'Value',0);
set(findobj(gcf,'Tag','textUnit1'),'String','KeV');
set(findobj(gcf,'Tag','textUnit2'),'String','Ang');
set(findobj(gcf,'Style','edit'),'String','');


function radiobuttonWav2Eng_Callback(obj,eventdata)
set(findobj(gcf,'Tag','radiobuttonEng2Wav'),'Value',0);
set(findobj(gcf,'Tag','radiobuttonWav2Eng'),'Value',1);
set(findobj(gcf,'Tag','textUnit1'),'String','Ang');
set(findobj(gcf,'Tag','textUnit2'),'String','KeV');
set(findobj(gcf,'Style','edit'),'String','');


function pushbuttonConvert_Callback(obj,eventdata)
edit1 = get(findobj(gcf,'Tag','edit1'),'String');
edit1 = str2double(edit1);
if isnan(edit1)
    return;
end
h = 6.626068E-34 ;
c = 299792458;
e = 1.60217646E-19;
warning off Matlab:divideByZero;
if get(findobj(gcf,'Tag','radiobuttonEng2Wav'),'Value')
    wavelength = double(h*c/(edit1*1000.0*e)*1e10);
    set(findobj(gcf,'Tag','edit2'),'String',sprintf('%12.12f',wavelength));
else
    energy = double(h*c/(edit1*1E-10)/e/1000.0);
    set(findobj(gcf,'Tag','edit2'),'String',sprintf('%12.12f',energy));
end
warning on Matlab:divideByZero;