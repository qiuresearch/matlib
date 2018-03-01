function rgb = ncol(n, h)
%NCOL        returns the color number N from the GCA ColorOrder
%  RGB = NCOL(N) returns the Nth color of the ColorOrder
%  NCOL(N, H)  sets the color of object H to the Nth color
%  NCOL 4  is an abbreviation for
%    ncol(4, [ gco; findobj(gca,'Selected','on') ])

%  $Id: ncol.m 26 2007-02-27 22:45:38Z juhas $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 2
    h = [];
end
h = h(:);
co=get(gca, 'ColorOrder');
if isstr(n)
    if isempty(h)
	h = [ gco; findobj(gca, 'Selected', 'on') ];
    end
    [nc,k]=sscanf(n,'%i');
    if k>0
	c = co(mod(nc(:)-1, size(co,1))+1,:);
    else
	c = n;
    end
else
    c = co(mod(n(:)-1, size(co,1))+1,:);
end
if ~isempty(h)
    if length(h) > 1 & size(c,1) == length(h)
	for i = 1:length(h)
	    set( h(i), 'Color', c(i,:) )
	end
    else
	set(h , 'Color', c)
    end
end
if nargout > 0 | isempty(h)
    rgb = c;
end
