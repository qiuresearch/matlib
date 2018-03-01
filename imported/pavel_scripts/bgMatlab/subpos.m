function Props = subpos(varargin)
%SUBPOS      return special properties of subplot(ijk)
%  PROPS = SUBPOS(I,J,K)  or
%  PROPS = SUBPOS(IJK)
%    returns cell array of axes properties and values required to change
%    gca to subplot(IJK)
%  SUBPOS(IJK)
%    applies those properties to gca
%  SUBPOS(H, IJK) or SUBPOS(H, I, J, K) sets appropriate properties
%    to the axis with handle H
%  SUBPOS(H, IJK) or SUBPOS(H, I, J, K) sets appropriate properties

%  $Id: subpos.m 26 2007-02-27 22:45:38Z juhas $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% properties to obtain
copyAxesProperties = {'Position', 'OuterPosition', 'ActivePositionProperty'};

% deal with arguments
doset=0; iarg=1;
if ishandle(varargin{1}) & strcmp(get(varargin{1},'type'), 'axes')
    ha=varargin{1}(1);
    doset=1;
    iarg=2;
end
p0=varargin{iarg};
if isstr(p0) & nargin==1
    p0=sscanf(p0, '%i', 1);
    ha = gca; doset=1;
end
if(p0>100)
    p1=floor(p0/100);
    p3=rem(p0,10);
    p2=floor((p0-100*p1-p3)/10);
elseif length(p0)>1
    p3=p0(3); p2=p0(2); p1=p0(1);
else
    p1=p0(1);
    p2=varargin{iarg+1}(1);
    p3=varargin{iarg+2}(1);
end

htmp = figure('Visible', 'off', 'IntegerHandle', 'off');
values = get(subplot(p1, p2, p3), copyAxesProperties);
close(htmp);

if ~doset | nargout>0
    Props = {copyAxesProperties, values};
end
if doset
    set(ha, copyAxesProperties, values);
end
