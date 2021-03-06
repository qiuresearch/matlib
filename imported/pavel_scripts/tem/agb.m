function agb(action, parameter)
%AGB       GUI for plot of YBCO artificial grain boundary

% 1996 by Pavol

%Global Function Parameters:
global cellno;
if isempty(cellno)
   cellno=20;
end
a=ybco('abc'); b=a(2); a=a(1);
thetamax=180/pi*atan(a/b);
coincmax=10;
global ElStyles;
ElStyles = ['.w';'.r';'ob';'+b'];
%End

if nargin==0
%INITIALIZATION
   if findobj('Name','AGB Controls') & findobj('Name', 'YBCO AGB')
         figure(2); figure(1);
         return;
   end
%FIGURES CREATION
   close all;
   scr = get(0,'ScreenSize'); scr = scr(3:4);
   ctfs= [200 207];
   figure('Visible','Off', 'MenuBar','None', 'Resize','Off',...
        'NumberTitle','Off', 'Name','AGB Controls','NextPlot','Add',...
        'Position',[5 scr(2)-5-19-ctfs(2) ctfs]);
   figure('Visible','Off', 'NumberTitle','Off', 'BackingStore', 'Off', 'Name', 'YBCO AGB',...
        'Position',[12+ctfs(1) 31 scr(1)-16-ctfs(1) scr(2)-74],'tag','');
   axes('Position', [0 0 1 1], 'Visible', 'Off');
%DEFAULT VALUES
   theta=[0 0];
   showel = [1 1 0 0];
   rotin  = 2;
   grid = 0;
   sym = 0;
   coinc = 0;
%UICONTROLS CREATION
   figure(1);
   %text axis
   ha = axes('Position', [0 0 1 1],...
             'visible', 'off',...
             'units', 'pixels',...
             'xlim', [1 ctfs(1)],...
             'ylim', [1 ctfs(2)],...
             'NextPlot', 'Add');
   %Angle label
   htal = text(29, ctfs(2)-15, 'q = ',...
        'FontName', 'Symbol',...
        'FontSize', 12,...
        'HorizontalAlignment', 'Right',...
        'Color', 'y');
   %Angle value
   htav(2) = uicontrol('style', 'Edit',...
                    'Position', [25 ctfs(2)-38 50 15],...
                    'string',sprintf('%6.2f  ',theta(2)),...
                    'HorizontalAlignment', 'Right',...
                    'BackGroundColor', 'k',...
                    'ForeGroundColor', 'w',...
                    'Callback', 'agb(''edit'',2)');
   htav(1) = uicontrol('style', 'Edit',...
                    'Position', [25 ctfs(2)-23 50 15],...
                    'string',sprintf('%6.2f  ',theta(1)),...
                    'HorizontalAlignment', 'Right',...
                    'BackGroundColor', 'k',...
                    'ForeGroundColor', 'w',...
                    'Callback', 'agb(''edit'',1)');
   %Angle sliders
   hsa =  uicontrol('style', 'Slider',...
                    'Position', [77 ctfs(2)-22 117 13],...
                    'Value', theta(1),...
                    'Min', -thetamax,...
                    'Max', thetamax,...
                    'UserData', theta(1),...
                    'Callback', 'agb(''slider'',1)');
   hsa(2) = uicontrol('style', 'Slider',...
                    'Position', [77 ctfs(2)-36 117 13],...
                    'Value', theta(2),...
                    'Min', -thetamax,...
                    'Max', thetamax,...
                    'UserData', theta(2),...
                    'Callback', 'agb(''slider'',2)');
   %Angle check boxes
   hacb = uicontrol('style','checkbox',...
                    'Position', [9 ctfs(2)-55 90 15],...
                    'string', 'Symetrical',...
                    'Value', sym,...
                    'HorizontalAlignment', 'Left',...
                    'BackGroundColor', 'k',...
                    'ForeGroundColor', 'w',...
                    'Callback', 'agb(''symetrical'')');
   hacb(2)=uicontrol('style','checkbox',...
                    'Position', [102 ctfs(2)-55 90 15],...
                    'string','Coincidence',...
                    'Value', coinc,...
                    'HorizontalAlignment', 'Left',...
                    'BackGroundColor', 'k',...
                    'ForeGroundColor', 'w',...
                    'Callback', 'agb(''coincidence'')');
   %Show text label
   hstl = uicontrol('style', 'Text',...
                    'Position', [7 ctfs(2)-82 90 15],...
                    'string','Show:',...
                    'HorizontalAlignment', 'Left',...
                    'BackGroundColor', 'k',...
                    'ForeGroundColor', 'y' );
   %Show check boxes
   hstb = zeros(1,4);
   hstb(1)=uicontrol('style','checkbox',...
                    'Position', [9 ctfs(2)-97 50 15],...
                    'string','Y/Ba',...
                    'HorizontalAlignment', 'Left',...
                    'BackGroundColor', 'k',...
                    'ForeGroundColor', 'w',...
                    'Callback', 'agb(''show'',1)');
   hstb(2)=uicontrol('style','checkbox',...
                    'Position', [9 ctfs(2)-112 50 15],...
                    'string','Cu',...
                    'HorizontalAlignment', 'Left',...
                    'BackGroundColor', 'k',...
                    'ForeGroundColor', 'w',...
                    'Callback', 'agb(''show'',2)' );
   hstb(3)=uicontrol('style','checkbox',...
                    'Position', [9 ctfs(2)-127 50 15],...
                    'string','O1',...
                    'HorizontalAlignment', 'Left',...
                    'BackGroundColor', 'k',...
                    'ForeGroundColor', 'w',...
                    'Callback', 'agb(''show'',3)' );
   hstb(4)=uicontrol('style','checkbox',...
                    'Position', [9 ctfs(2)-142 50 15],...
                    'string','O2',...
                    'HorizontalAlignment', 'Left',...
                    'BackGroundColor', 'k',...
                    'ForeGroundColor', 'w' ,...
                    'Callback', 'agb(''show'',4)');
   for i=1:length(hstb)
        set(hstb(i), 'value', showel(i));
   end
   %Rotation text label
   hrtl = uicontrol('style', 'Text',...
                    'Position', [100 ctfs(2)-82 100 15],...
                    'string','Rotate in:',...
                    'HorizontalAlignment', 'Left',...
                    'BackGroundColor', 'k',...
                    'ForeGroundColor', 'y' );
   %Rotation radio buttons
   hrrb = zeros(1,4);
   hrrb(1)=uicontrol('style','RadioButton',...
                    'Position', [102 ctfs(2)-97 70 15],...
                    'string','Y/Ba',...
                    'HorizontalAlignment', 'Left',...
                    'BackGroundColor', 'k',...
                    'ForeGroundColor', 'w' ,...
                    'Callback', 'agb(''rotate'',1)');
   hrrb(2)=uicontrol('style','RadioButton',...
                    'Position', [102 ctfs(2)-112 70 15],...
                    'string','Cu',...
                    'HorizontalAlignment', 'Left',...
                    'BackGroundColor', 'k',...
                    'ForeGroundColor', 'w'  ,...
                    'Callback', 'agb(''rotate'',2)');
   hrrb(3)=uicontrol('style','RadioButton',...
                    'Position', [102 ctfs(2)-127 70 15],...
                    'string','O1',...
                    'HorizontalAlignment', 'Left',...
                    'BackGroundColor', 'k',...
                    'ForeGroundColor', 'w' ,...
                    'Callback', 'agb(''rotate'',3)' );
   hrrb(4)=uicontrol('style','RadioButton',...
                    'Position', [102 ctfs(2)-142 70 15],...
                    'string','O2',...
                    'HorizontalAlignment', 'Left',...
                    'BackGroundColor', 'k',...
                    'ForeGroundColor', 'w'  ,...
                    'Callback', 'agb(''rotate'',4)');
   set(hrrb, 'value', 0);
   set(hrrb(1), 'UserData', rotin);
   set(hrrb(rotin), 'value', 1);
   for i=1:4
        p=plot(77,-15*(i-1)+ctfs(2)-89,ElStyles(i,:));
        if(ElStyles(i,1)=='.')
           set(p, 'MarkerSize', 13);
        end
   end
   %PushButtons
   hpp = uicontrol('style','PushButton',...
                    'Position', [7 ctfs(2)-177 90 22],...
                    'string','Plot' ,...
                    'Callback', 'agb(''plot'')');
   hpz = uicontrol('style','PushButton',...
                    'Position', [7 ctfs(2)-201 90 22],...
                    'string','Zoom On' ,...
                    'Callback', 'agb(''zoom'')');
   hpg = uicontrol('style','PushButton',...
                    'Position', [103 ctfs(2)-177 90 22],...
                    'string','Grid On' ,...
                    'Callback', 'agb(''grid'')');
         if grid
               set(hpg, 'string', 'Grid Off');
         end
   hpc = uicontrol('style','PushButton',...
                    'Position', [103 ctfs(2)-201 90 22],...
                    'string','Close' ,...
                    'Callback', 'agb(''close'')');
   figure(2);
   agbplot(theta, grid, showel, cellno, rotin);
%SHOW FIGURE
   set(1, 'UserData', [htav, hsa, hacb, hstb, hrrb, hpp, hpz, hpg, hpc],...
          'NextPlot', 'New');
   pause(.5);
   set([1 2], 'Visible', 'On');
   figure(1);
   return;
end

%GET HANDLES...
h = get(1, 'UserData');
htav=h(1:2); hsa=h(3:4); hacb=h(5:6);
hstb=h(7:10); hrrb=h(11:14);
hpp=h(15); hpz=h(16); hpg=h(17); hpc=h(18);

theta=[get(hsa(1),'UserData') get(hsa(2),'UserData')];
rotin=get(hrrb(1), 'UserData');
sym=get(hacb(1), 'Value');
coinc=get(hacb(2), 'Value');
grid=strcmp(get(hpg, 'String'), 'Grid Off');
for i=1:length(hstb)
     showel(i) = get(hstb(i), 'value');
end

%CALLBACKS:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(action, 'slider')
    i = parameter;
    if coinc
        i=[1 2];
        if theta(1)==0
              n0=Inf;
        else
              n0 = round(a/b/tan(pi/180*theta(1)));
        end
        val = get(hsa(parameter),'value');
        if val==0
              n=Inf;
        else
              n = round(a/b/tan(pi/180*val));
        end
        if n==n0
              dir = sign(val - get(hsa(parameter),'UserData'));
              n = n0-dir;
        end
        if n>coincmax
              n = -coincmax;
        elseif n<-coincmax
              n = coincmax;
        end
        theta = [180 180]/pi*atan(a/(n*b));
        set(hsa(i), 'Value', theta(parameter) );        
        set(htav(1), 'string', sprintf('%6.2f  ', theta(1)));
        set(htav(2), 'string', sprintf('%6.2f  ', theta(2)));
        if strcmp(theta, [get(hsa(1), 'UserData') get(hsa(2), 'UserData')])
                return;
        end
        set(hsa(i), 'UserData', theta(parameter));
        agb plot
    else
        if sym
              i=[1 2];
        end
        theta(i)=0*i + get(hsa(parameter), 'Value');
        set(hsa(i), 'UserData', theta(parameter), 'Value', theta(parameter) );
        set(htav(1), 'string', sprintf('%6.2f  ', theta(1)));
        set(htav(2), 'string', sprintf('%6.2f  ', theta(2)));
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(action, 'edit')
    t = eval(get(htav(parameter),'String'), '[]');
    if isempty(t)
        set(htav(parameter), 'string', sprintf('%6.2f  ', theta(2)));
    else
        t = t(1);
        if t>thetamax
              t = thetamax;
        elseif t<-thetamax
              t = -thetamax;
        end    
        set(hsa(parameter), 'Value', t);
        agb('slider', parameter);
        if ~coinc
              agb plot;
        end  
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(action, 'symetrical')
    if sym
        set(hsa(2), 'UserData', theta(1), 'Value', theta(1));
        set(htav, 'string', sprintf('%6.2f  ', theta(1)));
        agb plot;
    else
        set(hacb, 'Value', 0);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(action, 'coincidence')
    if ~coinc
        return;
    end
    set(hacb(1), 'Value', 1);           %set symetry on
    if theta(1)==0
        n=Inf;
    else
        n = round(a/b/tan(pi/180*theta(1)));
    end
    if n>coincmax
        n = coincmax;
    end
    theta = [180 180]/pi*atan(a/(n*b));
    set(hsa, 'Value', theta(1), 'UserData', theta(1));
    set(htav(1), 'string', sprintf('%6.2f  ', theta(1)));
    set(htav(2), 'string', sprintf('%6.2f  ', theta(2)));
    agb plot;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(action, 'show')
    agb plot;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(action, 'rotate')
    set(hrrb, 'Value', 0); set(hrrb(parameter), 'Value', 1);
    set(hrrb(1), 'UserData', parameter);
    agb('plot');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(action, 'plot')
    figure(2);
    agbplot(theta, grid, showel, cellno, rotin);
    figure(1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(action, 'zoom')
    figure(2);
    if strcmp(get(hpz, 'string'), 'Zoom On')
         zoom on;
         set(2, 'Pointer', 'cross');
         set(hpz, 'String', 'Zoom Off');
    else
         zoom out;
         zoom off;
         set(hpz, 'String', 'Zoom On');
         set(2, 'Pointer', 'arrow');
    end
    figure(1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(action, 'grid')
    if grid
          grid=0;
          set(hpg, 'String', 'Grid On');
    else
          grid=1;
          set(hpg, 'String', 'Grid Off');
    end
    agb plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(action, 'close')
    close(1); figure(2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif strcmp(action, 'manual')
    set(hsa(1), 'Value', parameter(1));
    set(hsa(2), 'Value', parameter(2));
    agb('slider', 1); agb('slider', 2);
    agb plot
else
    error(sprintf('Unknown option ''%s''', action))
end

