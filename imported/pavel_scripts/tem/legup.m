function legup()
if isempty(get(0,'Chil'))
	return
end
h = findobj(gcf,'type','axes','tag','legend');
if h
	h0=gca;
	axes(h);
	refresh;
	axes(h0);
end
