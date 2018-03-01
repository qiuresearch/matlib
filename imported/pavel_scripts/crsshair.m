function crsshair(action);
%CRSSHAIR  crosshair for reading (x,y) values from a plot
%    A set of mouse driven crosshairs is placed on the current axes,
%    and displays the current (x,y) position, interpolated between points.
%    Select done after using to remove the gui stuff,
%    and to restore the mouse buttons to previous values.


%    Richard G. Cobb    3/96
%    cobbr@plk.af.mil

global xhr_plot xhr_xdata xhr_ydata xhr_plot_data xhr_button_data
if nargin == 0
        xhr_plot=gcf;
        xhrx_axis=gca;
        sibs=findobj(xhrx_axis,'Type', 'line', 'Visible', 'on');
        found=length(sibs);
        sibs=sibs(found:-1:1);
        if found==0; return; end
        xhr_xdata=cell(found,1);
        xhr_ydata=xhr_xdata;
        for i=1:found
            xhr_xdata{i}=get(sibs(i),'Xdata');
            xhr_ydata{i}=get(sibs(i),'Ydata');
        end
        xhr_button_data=get(xhr_plot,'WindowButtonDownFcn');
        set(xhr_plot,'WindowButtonDownFcn','crsshair(''down'');');
        x_rng=get(xhrx_axis,'Xlim');
        y_rng_ydata=get(xhrx_axis,'Ylim');
%
        xaxis_text=uicontrol('Style','edit','Units','Normalized',...
                        'Position',[.2 .96 .2 .045],...
                        'String','X value',...
                        'BackGroundColor',[.7 .7 .7]);
        x_num=uicontrol('Style','edit','Units','Normalized',...
                        'Position',[.4 .96 .2 .045],...
                        'String',' ',...
                        'BackGroundColor',[0 .7 .7]);
        y_text=uicontrol('Style','edit','Units','Normalized',...
                        'Position',[.6 .96 .2 .045],...
                        'String','Y value',...
                        'BackGroundColor',[.7 .7 .7]);
        y_num=uicontrol('Style','edit','Units','Normalized',...
                        'Position',[.8 .96 .2 .045],...
                        'String',' ',...
                        'BackGroundColor',[0 .7 .7]);
        xhairs_on=uicontrol('Style','Text','Units','Normalized',...
                                'Position',[0 .05 .2 .04],...
                                'String','Crosshairs on:',...
                                'Visible','off');
                z='Trace 1';
                for i=2:found,
                        z=[z sprintf('|Trace %i', i)];
                end
                traces=z;
        trace_switcher=uicontrol('Style','Popup','Units','Normalized',...
                        'Position',[0 0 .2 .05],...
                        'String',traces,...
                        'BackGroundColor','w',...
                        'Visible','off',...
                        'CallBack',['crsshair(''up'');',]);
        if found>1,
                set(trace_switcher,'Visible','On','Value',1);
                set(xhairs_on,'Visible','On');
        end
                x_ydata_line=line(x_rng,[y_rng_ydata(1) y_rng_ydata(1)]);
                y_ydata_line=line(x_rng,[y_rng_ydata(1) y_rng_ydata(1)]);
                set(x_ydata_line,'Color','r');set(y_ydata_line,'Color','r');
                set(x_ydata_line,'EraseMode','xor');set(y_ydata_line,...
                   'EraseMode','xor');
        closer=uicontrol('Style','Push','Units','Normalized',...
                'Position',[.92 0 .08 .04],...
                'String','Done',...
                'CallBack','crsshair(''close'')',...
                'Visible','on');
        xhr_plot_data=[x_ydata_line y_ydata_line  ...
                  xhrx_axis   xaxis_text x_num...
                y_text y_num  trace_switcher...
                xhairs_on closer ];
elseif strcmp(action,'down');
        handles=xhr_plot_data;
        x_ydata_line=handles(1);
        y_ydata_line=handles(2);
        xhrx_axis=handles(3);
        xaxis_text=handles(4);
        x_num=handles(5);
        y_text=handles(6);
        y_num=handles(7);
        trace_switcher=handles(8);
        xhairs_on=handles(9);
        closer=handles(10);
        index=get(trace_switcher,'Value');
                xhr_xdata_col=xhr_xdata{index};
                xhr_ydata_col=xhr_ydata{index};
        set(xhr_plot,'WindowButtonMotionFcn','crsshair(''move'');');
        set(xhr_plot,'WindowButtonUpFcn','crsshair(''up'');');
        pt=get(xhrx_axis,'Currentpoint');
        xdata_pt=pt(1); ypt=pt(3);
        if xdata_pt>=max(xhr_xdata_col),
                [xdata_pt,i]=max(xhr_xdata_col);
                ydata_pt=xhr_ydata_col(i);
        elseif xdata_pt<=min(xhr_xdata_col),
                [xdata_pt,i]=min(xhr_xdata_col);
                ydata_pt=xhr_ydata_col(i);
        else,
                xsg=(xhr_xdata_col > xdata_pt);
                k=find(diff(xsg));
                rad= sqrt( (xhr_xdata_col(k)-xdata_pt).^2 +...
                           (xhr_ydata_col(k)-ypt).^2 ) + ...
                     sqrt( (xhr_xdata_col(k+1)-xdata_pt).^2 +...
                           (xhr_ydata_col(k+1)-ypt).^2 );
                [ignore,l]=min(rad);
                k=k(l);
                ydata_pt=xhr_ydata_col([k+1 k])*[xdata_pt-xhr_xdata_col(k);...
                                               xhr_xdata_col(k+1)-xdata_pt]/...
                      (xhr_xdata_col(k+1)-xhr_xdata_col(k));
        end
        x_rng=get(xhrx_axis,'Xlim');
        y_rng_ydata=get(xhrx_axis,'Ylim');
        set(x_ydata_line,'Xdata',[xdata_pt xdata_pt],'Ydata',y_rng_ydata);
                set(y_ydata_line,'Xdata',x_rng,'Ydata',[ydata_pt ydata_pt]);
                set(x_ydata_line,'Color','r');set(y_ydata_line,'Color','r');
        set(x_num,'String',num2str(xdata_pt,6));
        set(y_num,'String',num2str(ydata_pt,6));
        xhr_plot_data=[x_ydata_line y_ydata_line  ...
                  xhrx_axis   xaxis_text x_num ...
                y_text y_num trace_switcher ...
                xhairs_on closer ];
elseif strcmp(action,'move');
        handles=xhr_plot_data;
        x_ydata_line=handles(1);
        y_ydata_line=handles(2);
        xhrx_axis=handles(3);
        xaxis_text=handles(4);
        x_num=handles(5);
        y_text=handles(6);
        y_num=handles(7);
        trace_switcher=handles(8);
        xhairs_on=handles(9);
        closer=handles(10);
        index=get(trace_switcher,'Value');
        xhr_xdata_col=xhr_xdata{index};
        xhr_ydata_col=xhr_ydata{index};
        pt=get(xhrx_axis,'Currentpoint');
        xdata_pt=pt(1); ypt=pt(3);
        if xdata_pt>=max(xhr_xdata_col),
                [xdata_pt,i]=max(xhr_xdata_col);
                ydata_pt=xhr_ydata_col(i);
        elseif xdata_pt<=min(xhr_xdata_col),
                [xdata_pt,i]=min(xhr_xdata_col);
                ydata_pt=xhr_ydata_col(i);
        else,
                xsg=(xhr_xdata_col > xdata_pt);
                k=find(diff(xsg));
                rad= sqrt( (xhr_xdata_col(k)-xdata_pt).^2 +...
                           (xhr_ydata_col(k)-ypt).^2 ) + ...
                     sqrt( (xhr_xdata_col(k+1)-xdata_pt).^2 +...
                           (xhr_ydata_col(k+1)-ypt).^2 );
                [ignore,l]=min(rad);
                k=k(l);
                ydata_pt=xhr_ydata_col([k+1 k])*[xdata_pt-xhr_xdata_col(k);...
                                               xhr_xdata_col(k+1)-xdata_pt]/...
                      (xhr_xdata_col(k+1)-xhr_xdata_col(k));
        end
        x_rng=get(xhrx_axis,'Xlim');
        y_rng_ydata=get(xhrx_axis,'Ylim');
                set(x_ydata_line,'Xdata',[xdata_pt xdata_pt],...
                    'Ydata',y_rng_ydata);
                set(y_ydata_line,'Xdata',x_rng,'Ydata',[ydata_pt ydata_pt]);
                set(x_ydata_line,'Color','r');set(y_ydata_line,'Color','r');
        set(x_num,'String',num2str(xdata_pt,6));
        set(y_num,'String',num2str(ydata_pt,6));
        xhr_plot_data=[x_ydata_line y_ydata_line  ...
                  xhrx_axis   xaxis_text x_num...
                y_text y_num trace_switcher ...
                 xhairs_on closer ];
elseif strcmp(action,'up');
        handles=xhr_plot_data;
        x_ydata_line=handles(1);
        y_ydata_line=handles(2);
        xhrx_axis=handles(3);
        xaxis_text=handles(4);
        x_num=handles(5);
        y_text=handles(6);
        y_num=handles(7);
        trace_switcher=handles(8);
        xhairs_on=handles(9);
        closer = handles(10);
        index=get(trace_switcher,'Value');
                xhr_xdata_col=xhr_xdata{index};
                xhr_ydata_col=xhr_ydata{index};
        set(xhr_plot,'WindowButtonMotionFcn',' ');
        set(xhr_plot,'WindowButtonUpFcn',' ');
        pt=get(xhrx_axis,'Currentpoint');
        xdata_pt=pt(1); ypt=pt(3);
        if xdata_pt>=max(xhr_xdata_col),
                [xdata_pt,i]=max(xhr_xdata_col);
                ydata_pt=xhr_ydata_col(i);
        elseif xdata_pt<=min(xhr_xdata_col),
                [xdata_pt,i]=min(xhr_xdata_col);
                ydata_pt=xhr_ydata_col(i);
        else,
                xsg=(xhr_xdata_col > xdata_pt);
                k=find(diff(xsg));
                rad= sqrt( (xhr_xdata_col(k)-xdata_pt).^2 +...
                           (xhr_ydata_col(k)-ypt).^2 ) + ...
                     sqrt( (xhr_xdata_col(k+1)-xdata_pt).^2 +...
                           (xhr_ydata_col(k+1)-ypt).^2 );
                [ignore,l]=min(rad);
                k=k(l);
                ydata_pt=xhr_ydata_col([k+1 k])*[xdata_pt-xhr_xdata_col(k);...
                                               xhr_xdata_col(k+1)-xdata_pt]/...
                      (xhr_xdata_col(k+1)-xhr_xdata_col(k));
        end
        x_rng=get(xhrx_axis,'Xlim');
        y_rng_ydata=get(xhrx_axis,'Ylim');
                set(x_ydata_line,'Xdata',[xdata_pt xdata_pt],'Ydata',y_rng_ydata);
                set(y_ydata_line,'Xdata',x_rng,'Ydata',[ydata_pt ydata_pt]);
                set(x_ydata_line,'Color','r');set(y_ydata_line,'Color','r');
        set(x_num,'String',num2str(xdata_pt,6));
        set(y_num,'String',num2str(ydata_pt,6));
        xhr_plot_data=[x_ydata_line y_ydata_line  ...
                  xhrx_axis   xaxis_text x_num...
                y_text y_num trace_switcher ...
                xhairs_on closer ];
elseif strcmp(action,'close')
        handles=xhr_plot_data;
        x_ydata_line=handles(1);
        y_ydata_line=handles(2);
        xhrx_axis=handles(3);
        xaxis_text=handles(4);
        x_num=handles(5);
        y_text=handles(6);
        y_num=handles(7);
        trace_switcher=handles(8);
        xhairs_on=handles(9);
        closer=handles(10);
        delete(xaxis_text);
        delete(x_ydata_line);
        delete(y_ydata_line);
        delete(x_num);
        delete(y_text);
        delete(y_num);
        delete(xhairs_on);
        delete(trace_switcher);
        delete(closer);
        set(xhr_plot,'WindowButtonUpFcn','');
        set(xhr_plot,'WindowButtonMotionFcn','');
        set(xhr_plot,'WindowButtonDownFcn',xhr_button_data);
        refresh(xhr_plot)
        clear global xhr_plot xhr_xdata xhr_ydata xhr_plot_data xhr_button_data
end

