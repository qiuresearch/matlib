function X = xaty(y, varargin)
%XATY        finds the X values of line crossings of a given Y level
%  X = XATY(1, XP, YP, ['v'])  find X values where [XP, YP] crosses 1
%  X = XATY(1, P1, P2, ...)  find X values where the current line object
%    equals 1
%
%  Optional arguments P are:
%    'xl'  xlim, must be followed by a vector of [xmin, xmax]
%    'nl'  line number within gca, must be followed by integer
%    'hl'  handle to line object, must be followed by a handle
%    'v'   show the points

%  $Id: xaty.m 26 2007-02-27 22:45:38Z juhas $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%defaults
hl_set = 0;
xl=[-inf inf];
c_v=0;
if nargin==1 & isstr(y)
    y=sscanf(y,'%f',1);
end
y=y(1);

%process the arguments
xp = []; yp = [];
i=1;
while i<=length(varargin)
    curarg=varargin{i};
    if isnumeric( curarg )
	if isempty( xp )
	    xp = curarg;
	elseif isempty( yp )
	    yp = curarg;
	else
	    error( 'too many numerical arguments' );
	end
    else
	switch(curarg)
	case 'xl',
	i=i+1;
	xl=varargin{i}(1:2);
	case 'nl',
	i=i+1;
	hls=findobj(gca,'type','line','visible','on');
	hl=hls(varargin{i}(1));
	case 'hl',
	i=i+1;
	hl=varargin{i}(1);
	case 'v',
	c_v=1;
	otherwise,
	error(sprintf('unknown switch %s', curarg))
	end
    end
    i=i+1;
end

if ~isequal( size(xp), size(yp) )
    error( 'xp and yp must have the same size' );
end

if length( xp ) == 0
    if isempty(hl)
	hls=findobj(gca,'type','line','visible','on');
	hl=hls(1);
    end
    xp=get(hl,'XData');
    yp=get(hl,'YData');
    hl_set = 1;
end

%now calculate it
xpl=xp(xp>=xl(1) & xp<=xl(2));
ypl=yp(xp>=xl(1) & xp<=xl(2));
ily=ypl<y;
ic=find((ily(1:end-1)+ily(2:end))==1);
X=xpl(ic);
for i=1:length(ic)
    j=ic(i);
    X(i) = (xpl(j+1)-xpl(j)) / (ypl(j+1)-ypl(j)) * (y-ypl(j)) + xpl(j);
end
if c_v & ~isempty(X)
    if ~hl_set
	hl = plot( xp, yp );
    end
    ha = get(hl, 'Parent');
    hf = get(ha, 'Parent');
    hs = line( 'Parent', ha, 'Marker', '*', 'Color', 'r' ,...
	'LineStyle', 'none', 'XData', X, 'YData', 0*X+y);
    figure(hf);
    drawnow;
    if hl_set
	pause;
	delete(hs);
    end
end
