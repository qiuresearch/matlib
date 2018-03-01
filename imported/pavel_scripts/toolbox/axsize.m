function axsize(ha, wh)
% AXSIZE( handle, [width heigt] )  or
% AXSIZE( [width height] )
% reset 'PaperPosition' so that axis size is width x height

% const
UNITS = 'Inches';

if ~ishandle(ha(1)) & length(ha)==2
    wh = ha;
    ha = gca;
else
    ha = ha(1);
end
w = wh(1);
h = wh(2);

hf = get(ha, 'Parent');
set(ha, 'Units', 'normalized');
pa = get(ha, 'Position');
set(hf, 'Units', UNITS);
pf = get(hf, 'PaperPosition');

qw = w / (pa(3)*pf(3));
qh = h / (pa(4)*pf(4));

set(hf, 'PaperPosition', [pf(1:2) qw*pf(3) qh*pf(4)]);
