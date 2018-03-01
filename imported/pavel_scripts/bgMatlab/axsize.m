function axsize(h, wh)
%AXSIZE      adjust size of axis for postscript output
%  AXSIZE(WH)  set output dimensions of the current axis to
%    WH=[Width,Height] inches
%  AXSIZE(H, WH)  set output dimensions for the axis with handle H
%    This function adjusts 'PaperPosition' a way that makes the size
%    of axis in postscript output equal to WH

%  $Id: axsize.m 26 2007-02-27 22:45:38Z juhas $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% constants:
UNITS = 'inches';

if ~ishandle(h(1)) & length(h)==2
    wh = h;
    h = gca;
elseif length(h)~=1
    error('H must be scalar');
end

if prod(size(wh))~=2
    error('WH must have exactly 2 elements');
end

w = wh(1);
h = wh(2);

hfig = get(h, 'Parent');
set(h, 'Units', 'normalized');
apos = get(h, 'Position');
set(hfig, 'Units', UNITS);
fpos = get(hfig, 'PaperPosition');

qw = w / (apos(3)*fpos(3));
qh = h / (apos(4)*fpos(4));

set(hfig, 'PaperPosition', [fpos(1:2) qw*fpos(3) qh*fpos(4)]);
