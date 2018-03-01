function varargout = puttext(x,y,plottext, varargin)
%        varargout = puttext(x,y,plottext, option)
%   x, y - the fractional coordinate of the text position
%  

if nargin < 1
   help puttext
   return
end

xdim = get(gca, 'XLim');
ydim = get(gca, 'YLim');

if strmatch(upper(get(gca, 'XScale')), 'LINEAR')
   x = xdim(1) + x*(xdim(2) - xdim(1));
else
   xdim = log10(xdim);
   x = 10^(xdim(1) + x*(xdim(2) - xdim(1)));
end

if strmatch(upper(get(gca, 'YScale')), 'LINEAR')
   y = ydim(1) + y*(ydim(2) - ydim(1));
else
   ydim = log10(ydim);
   y = 10^(ydim(1) + y*(ydim(2) - ydim(1)));
end

htext = text(x,y,plottext, varargin{:});

if (nargout == 1)
   varargout{1} = htext;
end
