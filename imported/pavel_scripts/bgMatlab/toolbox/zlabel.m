function hh = zlabel(varargin)
%ZLABEL Z-axis label.
%   ZLABEL('text') adds text above the Z-axis on the current axis.
%
%   ZLABEL('txt','Property1',PropertyValue1,'Property2',PropertyValue2,...)
%   sets the values of the specified properties of the zlabel.
%
%   ZLABEL(AX,...) adds the zlabel to the specified axes.
%
%   H = ZLABEL(...) returns the handle to the text object used as the label.
%
%   See also XLABEL, YLABEL, TITLE, TEXT.

%   Hacked from zlabel.m.  Copyright 1984-2003 The MathWorks, Inc.
%   $Id: zlabel.m 26 2007-02-27 22:45:38Z juhas $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PJ begin:
if nargin == 0
    hh = get(gca, 'title');
    return
end
% PJ end:

error(nargchk(1,inf,nargin));

[ax,args,nargs] = axescheck(varargin{:});
if isempty(ax)
  % call zlabel recursively or call method of Axes subclass
  h = zlabel(gca,varargin{:});
  if nargout > 0, hh = h; end
  return;
end

if nargs > 1 && (rem(nargs-1,2) ~= 0)
  error('Incorrect number of input arguments')
end

string = args{1};
pvpairs = args(2:end);

h = get(ax,'zlabel');

set(h, 'FontAngle',  get(ax, 'FontAngle'), ...
        'FontName',   get(ax, 'FontName'), ...
        'FontSize',   get(ax, 'FontSize'), ...
        'FontWeight', get(ax, 'FontWeight'), ...
        'string',     string, pvpairs{:});

if nargout > 0
  hh = h;
end
