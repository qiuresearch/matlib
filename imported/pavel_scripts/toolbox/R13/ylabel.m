function hh = ylabel(string,varargin)
%YLABEL Y-axis label.
%   YLABEL('text') adds text beside the Y-axis on the current axis.
%
%   YLABEL('text','Property1',PropertyValue1,'Property2',PropertyValue2,...)
%   sets the values of the specified properties of the ylabel.
%
%   H = YLABEL(...) returns the handle to the text object used as the label.
%
%   See also XLABEL, ZLABEL, TITLE, TEXT.

%   Copyright (c) 1984-96 by The MathWorks, Inc.
%   $Revision: 5.5 $  $Date: 1996/10/24 17:33:45 $

ax = gca;
h = get(ax,'ylabel');
DefaultYLabelProp=[];%struct('Fontweight', 'bold');

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
  if ~isempty(DefaultYLabelProp)
      set(h, DefaultYLabelProp)
  end
end
set(h, 'string', string, varargin{:});

if nargout > 0
  hh = h;
end
