function rmallad(figs)
%RMALLAD   removes all APPDATA from current or specified figures
%use to reset loaded *.fig figure when PLOTEDIT does not work

if nargin == 0
    h = get(0,'Children');
    if ~isempty(h)
	h = gcf;
    end
elseif strcmp(figs, 'all')
    h=get(0,'Children');
else
    h=figs;
end

for hh=h(:)'
    plotedit(hh,'off');
    names=fieldnames(getappdata(hh));
    for name=names'
	rmappdata(hh,char(name));
    end
end
