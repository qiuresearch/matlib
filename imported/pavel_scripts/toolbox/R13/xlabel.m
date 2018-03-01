function hh = xlabel(string,varargin)
%XLABEL X-axis label.
%   XLABEL('text') adds text beside the X-axis on the current axis.
%
%   XLABEL('text','Property1',PropertyValue1,'Property2',PropertyValue2,...)
%   sets the values of the specified properties of the xlabel.
%
%   H = XLABEL(...) returns the handle to the text object used as the label.
%
%   See also YLABEL, ZLABEL, TITLE, TEXT.

%   Copyright (c) 1984-96 by The MathWorks, Inc.
%   $Revision: 5.5 $  $Date: 1996/10/24 17:33:40 $

ax = gca;
h = get(ax,'xlabel');
DefaultXLabelProp=[];%struct('Fontweight', 'bold');

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
  if ~isempty(DefaultXLabelProp)
      set(h, DefaultXLabelProp)
  end
end
set(h, 'string', string, varargin{:});

if nargout > 0
  hh = h;
end
