function locator(action)
%LOCATOR   shows mouse pointer location within current axes
%	   LOCATOR ON turns on the locator for current figure
%	   LOCATOR ALLON turns the locator on for all figures
%	   LOCATOR OFF closes the locator window
%	   LOCATOR by itself toggles the state.

c_wbmf = 'locator(''read'')';	% WindowButtonMotionFcn callback

h = findall(0, 'type', 'figure', 'Tag', 'Position Window');
if nargin==0
    if isempty(h)
	locator('on');
    else
	hf = get(0,'Children');
	hf = hf(hf~=h);
	if isempty(hf) | strcmp( get(hf(1), 'WindowButtonMotionFcn'), c_wbmf )
	    locator('off');
	else
	    locator('on');
	end
    end
    return;
end

switch action
case { 'on', 'allon' },
    if isempty(h)
	scrsz=get(0,'ScreenSize'); scrsz=scrsz(3:4);
	h = figure( 'MenuBar','None','Toolbar','None','Resize','Off', ...
		'Position',[scrsz(1)-109 scrsz(2)-97 105 74],...
		'NumberTitle','Off',...
		'Name','Position','Tag','Position Window',...
		'Color','Black', 'IntegerHandle', 'off',...
		'CloseRequestFcn', 'locator off', ...
		'HandleVisibility', 'callback' );
	hx = uicontrol('Style','Text','Position',[5 54 95 15],...
		'Parent', h, ...
		'ForeGroundColor','w',...
		'BackGroundColor','k');
	hy = uicontrol('Style','Text','Position',[5 39 95 15],...
		'Parent', h, ...
		'ForeGroundColor','w',...
		'BackGroundColor','k');
	uicontrol('Style','Frame','Position',[10 37 85 1],...
		'Parent', h, ...
		'ForeGroundColor','w');
	hr = uicontrol('Style','Text','Position',[5 19 95 15],...
		'Parent', h, ...
		'ForeGroundColor','w',...
		'BackGroundColor','k');
	hphi = uicontrol('Style','Text','Position',[5 4 95 15],...
		'Parent', h, ...
		'ForeGroundColor','w',...
		'BackGroundColor','k');
	set(h, 'UserData',[hx hy hr hphi]);
    end
    hf = get(0,'Children');
    hf = hf(hf~=h);
    if isempty(hf)
	hf=figure;
    elseif strcmp( action, 'on' );
	hf=hf(1);
    end
    set( hf, 'WindowButtonMotionFcn', c_wbmf );
    figure(hf(1));
    locator('read');
case 'off',
    delete(h);
    hf = get(0,'Children');
    for i = hf(:)'
	if strcmp( get(i, 'WindowButtonMotionFcn'), c_wbmf )
	    set(hf,'WindowButtonMotionFcn', '');
	end
    end
case 'read',
    if isempty(h)
	locator off;
	return;
    end
    if h==gcf
	return
    end     
    handles=get(h,'UserData');
    hx=handles(1);
    hy=handles(2);
    hr=handles(3);
    hphi=handles(4);
    x=get(gca, 'CurrentPoint');
    y=x(3); x=x(1);
    r=sqrt(x^2 + y^2);
    phi=atan2(y,x)*180/pi;
    set(hx,'string',sprintf('X = %6.5g',x));
    set(hy,'string',sprintf('Y = %6.5g',y));
    set(hr,'string',sprintf('R = %6.5g',r));
    set(hphi,'string',sprintf('P = %6.3f',phi));
end
