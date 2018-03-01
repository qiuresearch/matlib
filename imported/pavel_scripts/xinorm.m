function nI = xinorm(I);
%XINORM    normalizes xrd intensity
%   I=XINORM(I);
%   XINORM plt     normalizes intensity in gca
%   XINORM allplt  normalizes intensity of all plots in gcf

%   1999 by Pavol

if isstr(I)
    if strcmp(I, 'plt')
	h=findobj(gca,'type','line');
    elseif strcmp(I, 'allplt')
	h=findobj(gcf,'type','line');
    else 
	error(sprintf('Unknown option %s', I))
    end
    for i=1:length(h)
       set(h(i), 'ydata', xinorm(get(h(i),'ydata')));
    end
    return;
end

nI=100*I/max(I);
