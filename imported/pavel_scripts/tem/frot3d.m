function frot3d(arg);
%FROT3D    Track mouse motion with rotating cube.
%	   FROT3D ON turns on mouse-based 3-D rotation.
%	   FROT3D OFF turns if off.
%	   FROT3D by itself toggles the state.

%	Clay M. Thompson 5-3-94
%	Copyright (c) 1994-95 by The MathWorks, Inc.
%	$Revision: 1.6 $  $Date: 1995/02/17 13:08:10 $

%       $Revision by Pavol ... keeps perspective view

global ROTATE_gca ROTATE_axis ROTATE_box ROTATE_x0 ROTATE_xx ...
       ROTATE_text ROTATE_units

SENS = .4; 					% Mouse sensitivity
%POSITION = [8 185 130 20];	% Text info box position (lower left)
POSITION = [450 390 130 20];	% Text info box position (upper right)

if(nargin == 0) % Toggle state
  if strcmp(get(gcf,'windowbuttonupfcn'),'frot3d(''up'')')
    frot3d('off')
  else
    frot3d('on')
  end
  return

elseif strcmp(lower(arg),'down') % ButtonDownFcn
  ROTATE_units = get(gcf,'units'); set(gcf,'units','pixels')
  ROTATE_x0=get(gcf,'currentpoint');
  ROTATE_x0=ROTATE_x0(1,1:2);
  x1 = ROTATE_x0;

  % Activate axis that is clicked in
  ax = get(gcf,'Children');
  ROTATE_gca = [];
  for i=1:length(ax),
    if strcmp(get(ax(i),'Type'),'axes'),
      % Find axes that was clicked in.
      units = get(ax(i),'units'); set(ax(i),'units','Pixels');
      pos = get(ax(i),'Position'); set(ax(i),'units',units)
      if ((pos(1) <= ROTATE_x0(1)) & (ROTATE_x0(1) <= pos(1)+pos(3)) & ...
          (pos(2) <= ROTATE_x0(2)) & (ROTATE_x0(2) <= pos(2)+pos(4))),
        ROTATE_gca = ax(i);
        break
      end
    end
  end
  if isempty(ROTATE_gca), return, end

  AZEL = get(ROTATE_gca,'view');
  az = round(AZEL(1)-  SENS*(x1(1)-ROTATE_x0(1)));
  el = round(min(max(AZEL(2)-2*SENS*(x1(2)-ROTATE_x0(2)),-90),90));
  T2 = viewmtx(az,el);
  if el < 0, T2 = T2*[1 0 0 0;0 1 0 0;0 0 -1 .5;0 0 0 1]; end
  Y = ROTATE_xx*T2(1:3,1:3)';

  pos = get(ROTATE_gca,'Position');
  ROTATE_axis = axes('Units',get(ROTATE_gca,'Units'),'Position',pos, ...
                     'AspectRatio',get(ROTATE_gca,'AspectRatio'), ...
                     'xdir',get(ROTATE_gca,'xdir'), ...
                     'ydir',get(ROTATE_gca,'ydir'), ...
                     'zdir',get(ROTATE_gca,'zdir'));
  axes(ROTATE_axis)
  ROTATE_box = line(Y(:,1),Y(:,2),Y(:,3),'erase','xor', ...
                    'clipping','off','visible','on');
  set(ROTATE_axis,'visible','off','drawmode','fast')
  axis(reshape([fnanmin(Y);fnanmax(Y)],1,6)); view(2)

  % Create text box
  ROTATE_text = axes('units','Pixels','Position',POSITION,'visible','off');
  ROTATE_text(2) = text(0,0,sprintf('Az: %4.0f El: %4.0f',az,el), ...
            'erasemode','back','visible','off', ...
            'verticalAlignment','bottom','HorizontalAlignment','left');
  axis([0 1 0 1])
  if strcmp(arg,'down'),
    set(ROTATE_text(2),'visible','on')
  end
  set(gcf,'windowbuttonmotionfcn','frot3d(''move'')')

elseif strcmp(arg,'move'), % ButtonMotionFcn
  AZEL = get(ROTATE_gca,'view');
  x1 = get(gcf,'currentpoint'); x1 = x1(1,1:2);
  az = round(AZEL(1)-  SENS*(x1(1)-ROTATE_x0(1)));
  el = round(min(max(AZEL(2)-2*SENS*(x1(2)-ROTATE_x0(2)),-90),90));
  T2 = viewmtx(az,el);
  if el < 0, T2 = T2*[1 0 0 0;0 1 0 0;0 0 -1 .5;0 0 0 1]; end
  Y = ROTATE_xx*T2(1:3,1:3)';
  set(ROTATE_box,'Xdata',Y(:,1),'Ydata',Y(:,2),'Zdata',Y(:,3));

  % Update text box
  set(ROTATE_text(2),'String',sprintf('Az: %4.0f El: %4.0f',az,el));

elseif strcmp(arg,'up'), % ButtonUpFcn
  if isempty(ROTATE_gca), return, end
  AZEL = get(ROTATE_gca,'view');
  x1 = get(gcf,'currentpoint'); x1 = x1(1,1:2);
  axes(ROTATE_gca)
  az = round(AZEL(1)-  SENS*(x1(1)-ROTATE_x0(1)));
  el = round(min(max(AZEL(2)-2*SENS*(x1(2)-ROTATE_x0(2)),-90),90));
  phi = persp;
  view(viewmtx(az,el,phi))
  set(gcf,'windowbuttonmotionfcn','','units',ROTATE_units)

  delete(ROTATE_axis),
  delete(ROTATE_text(1))

elseif strcmp(lower(arg),'on'),
  % Define cube edges
  X = [0 0 1;0 1 1;1 1 1;1 1 0;0 0 0;0 0 1;1 0 1;1 0 0;0 0 0; ...
       0 1 0;1 1 0;1 0 0;0 1 0;0 1 1;NaN NaN NaN;1 1 1;1 0 1];
        
  ROTATE_xx = (2*X-1);
  if strcmp(arg,'ON'),
    set(gcf,'windowbuttondownfcn','frot3d(''DOWN'')', ...
            'windowbuttonupfcn','frot3d(''up'')', ...
            'windowbuttonmotionfcn','',...
            'buttondownfcn','')
  else
    set(gcf,'windowbuttondownfcn','frot3d(''down'')', ...
            'windowbuttonupfcn','frot3d(''up'')', ...
            'windowbuttonmotionfcn','',...
            'buttondownfcn','')
  end

elseif strcmp(lower(arg),'off'),
  set(gcf,'windowbuttondownfcn','', ...
          'windowbuttonupfcn','', ...
          'windowbuttonmotionfcn','',...
          'buttondownfcn','')
  clear global ROTATE_gca ROTATE_axis ROTATE_box ROTATE_x0 ROTATE_xx ...
               ROTATE_text ROTATE_units
else
  error('Unknown action string.');

end
