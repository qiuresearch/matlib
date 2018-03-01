function hh = title(string,varargin)
%TITLE  Graph title.
%   TITLE('text') adds text at the top of the current axis.
%
%   TITLE('text','Property1',PropertyValue1,'Property2',PropertyValue2,...)
%   sets the values of the specified properties of the title.
%
%   H = TITLE(...) returns the handle to the text object used as the title.
%
%   See also XLABEL, YLABEL, ZLABEL, TEXT.

%   Copyright (c) 1984-96 by The MathWorks, Inc.
%   $Revision: 5.6 $  $Date: 1996/10/24 17:33:35 $

ax = gca;
h = get(ax,'title');
DefaultTitleProp=[]; % struct('FontSize',12);

if nargin > 1 & (nargin-1)/2-fix((nargin-1)/2),
  error('Incorrect number of input arguments')
elseif nargin==0
  hh=h;
  return;
end

%Over-ride text objects default font attributes with
%the Axes' default font attributes.
if isempty(get(h,'String'))
  set(h, 'FontAngle',  get(ax, 'FontAngle'), ...
          'FontName',   get(ax, 'FontName'), ...
          'FontSize',   get(ax, 'FontSize'), ...
          'FontWeight', get(ax, 'FontWeight'))
  if ~isempty(DefaultTitleProp)
      set(h, DefaultTitleProp)
  end
end
set(h, 'string', string, varargin{:});

if nargout > 0
  hh = h;
end
