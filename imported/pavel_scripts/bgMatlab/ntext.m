function th = ntext(varargin)
%NTEXT       text annotation, same as TEXT, but it uses normalized units
%
%  See also TEXT.

%  $Id: ntext.m 26 2007-02-27 22:45:38Z juhas $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h = text(varargin{:}, 'Units', 'normalized');
if nargout>0
    th=h;
end
