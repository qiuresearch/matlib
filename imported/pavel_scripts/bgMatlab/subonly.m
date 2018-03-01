function subonly(ha)
%SUBONLY     removes all except specified axis from the figure,
%  SUBONLY(H)  keeps only axis H in the figure, the dimensions of H are
%    reset to the default value
%  SUBONLY 211  keeps and zooms subplot(211)

%  $Id: subonly.m 26 2007-02-27 22:45:38Z juhas $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin==0
    ha = gca;
elseif (ha > 100 & round(ha) == ha) | isstr(ha)
    ha = subplot(ha);
end

hall = findobj(get(gca,'Parent'), 'type', 'axes');
hall = hall(hall~=ha);
delete(hall);
subpos(ha,111);
