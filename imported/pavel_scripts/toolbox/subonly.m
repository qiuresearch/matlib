function subonly(ha)
% SUBONLY([H])  removes all but axis H from the figure,
%     size of H is reset to the default value
% SUBONLY 211   keeps and zooms subplot(211)

if nargin==0
    ha = gca;
elseif (ha > 100 & round(ha) == ha) | isstr(ha)
    ha = subplot(ha);
end

hall = findobj(get(gca,'Parent'), 'type', 'axes');
hall = hall(hall~=ha);
delete(hall);
subpos(ha,111);
