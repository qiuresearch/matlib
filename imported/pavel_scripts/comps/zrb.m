function [X,Y,Z]=zrb(element)
%ZRB       parameters of Zr-betta primitive cell
%          [m,n,o] = ZR(element) returns latice coordinates of
%          specified element
%          a = ZR('abc') returns latice parameters [a b c alpha beta gamma]
%          S = ZR('elements') returns all elements in Zr

% 1997 by ??

if nargin==0
	X='zrb';
	return;
end
X=[]; Y=[]; Z=[];
element=deblank(element);
if strcmp(element,'abc')
	X=[3.617 3.617 3.617 90 90 90];
	return;
elseif strcmp(element, 'elements')
	X=['Zr'];
	return;
elseif strcmp(element, 'Zr')
%% TYPE HERE Zr POSITIONS IN LATICE COORDINATES:
	X = [0 .5];
	Y = [0 .5];
	Z = [0 .5];
else
	error(sprintf('Unknown command option ''%s''', element));
end
X=X(:); Y=Y(:); Z=Z(:);
