function holdall(opt_hold_state);
%HOLDALL   Hold all graphs within current figure.
%   HOLDALL ON is HOLD applied to all axis within current figure
%
%   See also ISHOLD, NEWPLOT, FIGURE, AXES.

%   Copyright (c) 1984-96 by The MathWorks, Inc.
%   $Revision: 5.2 $  $Date: 1996/10/25 19:34:55 $

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
