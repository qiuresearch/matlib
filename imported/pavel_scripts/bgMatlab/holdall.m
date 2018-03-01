function holdall(opt_hold_state);
%HOLDALL     hold all graphs within current figure.
%  HOLDALL ON  applies HOLD ON to all axis within current figure
%
%  See also ISHOLD, NEWPLOT, FIGURE, AXES.

%  hacked from hold.m
%  $Id: holdall.m 26 2007-02-27 22:45:38Z juhas $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ax = findobj(gcf, 'type','axes');
isnexta=1;
for i=1:length(ax)
    isnexta = isnexta & strcmp(lower(get(ax(i),'NextPlot')),'add');
end
isnextf = strcmp(lower(get(gcf,'NextPlot')),'add');
hold_state = isnexta & isnextf;
if(nargin == 0)
    if(hold_state)
        set(ax,'NextPlot','replace');
        disp('All plots released');
    else
        set(ax,'NextPlot','add');
        disp('All plots held');
    end
elseif(strcmp(opt_hold_state, 'on'))
    set(gcf,'NextPlot','add');
    set(ax,'NextPlot', 'add');
elseif(strcmp(opt_hold_state, 'off'))
    set(ax,'NextPlot', 'replace');
else
    error('Unknown command option.');
end
