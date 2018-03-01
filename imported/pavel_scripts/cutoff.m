function cutoff(action)
%CUTOFF    GUI for colormap cut off 
%    CUTOFF ON turns on cutoff window
%    CUTOFF OFF turns off cutoff window
%    CUTOFF by itself toggles the state.

if nargin==0
        h=findobj('type', 'figure', 'Tag', 'cutoff window');
        if isempty(h)
           cutoff('on');
        else
           cutoff('off');
        end
        return;
end
H=findobj('type', 'figure');
h=findobj('type', 'figure', 'Tag', 'cutoff window');
if isempty(h)
   i=1:length(H);
else
   i=find(H~=h);
end
if isempty(i)% & ~isempty(h)
        return;
else
        H=H(i(1));
        maplen=size(get(H,'colormap'),1)-1;
end

if strcmp(action, 'on')
        if isempty(h)
           pos=get(H,'Position'); pos(2)=pos(2)-57;     
           h=figure('MenuBar','None','Resize','Off','Position',[pos(1:2)   238    30],...
             'NumberTitle','Off','Name','Colormap cut off','Tag','cutoff window');
           hs  =uicontrol('Style','Slider','Position',[33 5 200 18],...
                           'Min', 0, 'Max' ,maplen, 'Value', 0,...
                           'UserData', 0,...
                           'callback', 'cutoff(''cut'')');
           ht  =uicontrol('Style','Edit','Position',[5 7 25 15],...
                        'ForeGroundColor','w',...
                        'BackGroundColor','k',...
                        'HorizontalAlignment', 'Right',...
                        'String', '  0',...
                        'callback', 'cutoff(''edit'')');
           if isempty(get(H,'UserData'))
                   set(H,'UserData', get(H,'colormap'));
           end
           set(h,'UserData', [hs ht]);
           figure(H);
        end
        return;
elseif strcmp(action, 'off')
        delete(h);
        h=get(0,'Children');
        for i=1:length(h)
                map=get(h(i),'colormap');
                data=get(h(i),'userdata');
                if strcmp(size(map),size(data))
                        set(h(i),'colormap',data);
                        set(h(i),'UserData',[]);
                end
        end
        return;
end

handles=get(h,'UserData');
hs=handles(1);
ht=handles(2);

if strcmp(action, 'cut')
        n0=get(hs, 'UserData');
        n=get(hs, 'Value');
        if n>n0
                n=ceil(n); 
        else
                n=floor(n);
        end
        set(hs, 'Value', n, 'UserData', n, 'Max', maplen);
        set(ht, 'string', sprintf('%3.0f', n));
        orgmap=get(H, 'UserData');
        map=get(H, 'ColorMap');
        if isempty(orgmap) 
                orgmap=get(H, 'ColorMap');
                set(H, 'UserData', orgmap);
        end
        if ~strcmp(map(n0+1:maplen,:),orgmap(n0+1:maplen,:))
                orgmap=get(H, 'ColorMap');
                set(H, 'UserData', orgmap);
        end
        newmap=orgmap;
        newmap(1:n,:)=zeros(n,3);
        set(H, 'colormap', newmap);
elseif strcmp(action, 'edit')
        s=get(ht,'String');
        n0=get(hs,'value');
        n=eval(s ,sprintf('%f', n0));
        if n<0
                n=0;
        elseif n>maplen
                n=maplen;
        end
        set(hs,'value',n);
        cutoff cut;
end
