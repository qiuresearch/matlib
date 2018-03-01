function ctf(h)
%CTF       Change text fonts
%          CTF(H) applies to objects with handles H
%          CTF - use mouse to select text objects

if nargin==0
     h=findobj(gca,'type','text');
     h=seltext(h);
end
if isempty(h)
     return;
end

OldFontAngle = get(h(1), 'FontAngle');
OldFontName = get(h(1), 'FontName');
OldFontSize = get(h(1), 'FontSize');
OldFontWeight = get(h(1), 'FontWeight' );
uisetfont(h(1));
status= ~strcmp(OldFontAngle, get(h(1), 'FontAngle'))|...
	~strcmp( OldFontName, get(h(1), 'FontName'))|...
	~strcmp( OldFontSize, get(h(1), 'FontSize'))|...
	~strcmp(OldFontWeight, get(h(1), 'FontWeight' ));
if status
     set(h(2:length(h)),...
         'FontAngle', get(h(1), 'FontAngle'),...
         'FontName', get(h(1), 'FontName'),...
         'FontSize', get(h(1), 'FontSize'),...
         'FontWeight', get(h(1), 'FontWeight' ));
end
