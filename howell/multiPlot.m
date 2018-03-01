% --- Usage:
%        multiPlot
%
% --- Purpose:
%        fix the axis and titles for a 2x3 axes_create
%
%
%
% --- Parameter(s):
%
%
%
% --- Return(s):
%
% --- Example(s):
%
%        haxes = axes_create(columns, rows, 'queensize', 10,
%        'xmargin', .0,'ymargin',.05);
%        for i = length(files)
%            xyplot(file(i))
%            multiPlot
%        end
%
%
% --- Code:
%
% $Id: multiPlot.m,v 1.2 2013/08/01 21:09:39 schowell Exp $
% pos
t = title(get(get(gca,'title'),'string'));
pos = get(t,'Position');
pos(2) = .95*pos(2);

set(t,'Position',pos)

switch i
    case 1
        set(gca,'xticklabel',[])
        xlabel('')
    case {2, 3}
        set(gca,'xticklabel',[],'yticklabel',[])
        ylabel('')
        xlabel('')
    case 4
        %             set(gca,'xticklabel',1:4)
    case {5, 6}
        set(gca,'yticklabel',[])
        ylabel('')
end