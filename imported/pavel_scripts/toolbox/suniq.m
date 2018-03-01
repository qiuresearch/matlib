function [X,Y]=suniq(xx,yy,fnc)
%SUNIQ     sort and uniq values of vector X, get new values of vector Y
%[X,Y]=UNIQ(XX,YY,FNC) will return sorted and uniqued values of X,
%   Y(i)=FNC(YY(XX==X(i))),  where FNC should be a function returning a single
%   value from vector, such as MEAN, MIN, MAX. Default is FNC(YY)=YY(1)
%examples:
%   x=suniq([1 5 1 3 1])
%   [x,y]=suniq([1 5 1 3 1],[2 1 0 1 2])
%   [x,y]=suniq([1 5 1 3 1],[2 1 0 1 2],'min')
%   [x,y]=suniq([1 5 1 3 1],[2 1 0 1 2],'max')

if isempty(xx)
    X=[]; Y=[];
    return;
end

[xx1,ind]=sort(xx);
dx1=(diff(xx1)~=0); dx1(end+1)=1;
X=xx1(dx1);
if nargin==1
    return;
end

if ~all(size(xx)==size(yy)) | min(size(xx))>1
    error('xx and yy must be vectors of the same size');
end
if size(xx,2)==1
    iscolumn=1;
    yy=yy'; dx1=dx1';
else
    iscolumn=0;
end
if nargin<3
    fnc=inline('x(1)');
end
yy1=yy(ind);
dx2=diff([1 dx1 1]);
lind=find(dx2==-1);
hind=find(dx2==1);
for a=1:length(lind)
    yy1(lind(a):hind(a))=feval(fnc, yy1(lind(a):hind(a)));
end
Y=yy1(dx1);
if iscolumn
    Y=Y';
end
