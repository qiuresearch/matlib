function H=pkplt(x, y, varargin)
%PKPLT     draw stems without circles, line
%    PKPLT(X, Y, p1, p2, ...) 
%    X can also be pks or aids structure
%    possible additional arguments p:
%    'S'       use linestyle S
%    'z', ZL   set base level to ZL
%    'n', NL   normalize Y to NL
%    'xd'      use D for X instead of TH2


%defaults and constants
SX=''; BL=0; NL=[];
args=varargin;
if isstruct(x)
    d_s=x;
    if nargin>1
        args={y varargin{:}};
    end
    %work out pks or aids structure
    if isfield(d_s, 'icps')
        x=d_s.th2;
        y=d_s.icps;
    elseif isfield(d_s, 'abcABG')
        x=d_s.th2;
        y=d_s.irel;
    else
        error('argument X is unknown struct')
    end
end
if ~isequal(size(x),size(y)) & size(x,1)~=size(y,1)
    error('X and Y dimensions do not match')
end

%process the arguments
i=1;
while i<=length(args)
    curarg=args{i};
    switch(curarg)
    case 'xd',
	if isstruct('d_s') & isfield(d_s, 'd')
	    x = d_s.d;
	else
	    error('option "xd" can be used only with pks or aids structure')
	end
    case 'z',
        i=i+1;
        BL=args{i}(1);
    case 'n',
        i=i+1;
        NL=args{i}(1);
    otherwise,
        SX=curarg;
    end
    i=i+1;
end

%now let's go
if min(size(x))==1
    nsx=size(x);
    if nsx(1)>1
	nsx(1)=3*nsx(1);
    else
	nsx(2)=3*nsx(2);
    end
    xx=NaN*ones(nsx);
    xx(1:3:end)=x;
    xx(2:3:end)=x;
    xx(3:3:end)=NaN;
else
    xx=NaN*ones(3*size(x,1),size(x,2));
    xx(1:3:end,:)=x;
    xx(2:3:end,:)=x;
    xx(3:3:end,:)=NaN;
end
if ~isempty(NL)
    y=NL*y/max(y);
end
y=y+BL;
if min(size(y))==1
    nsy=size(y);
    if nsy(1)>1
	nsy(1)=3*nsy(1);
    else
	nsy(2)=3*nsy(2);
    end
    yy=NaN*ones(nsy);
    yy(1:3:end)=BL;
    yy(2:3:end)=y;
    yy(3:3:end)=NaN;
else
    yy=NaN*ones(3*size(y,1),size(y,2));
    yy(1:3:end,:)=BL;
    yy(2:3:end,:)=y;
    yy(3:3:end,:)=NaN;
end
h=plot(xx,yy,SX);
if nargout>0
    H=h;
end

