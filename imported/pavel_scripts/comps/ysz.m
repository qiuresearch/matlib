function [X,Y,Z]=ysz(element)
%YSZ       parameters of YSZ primitive cell
%          [m,n,o] = YSZ(element) returns latice coordinates of
%          specified element
%          a = YSZ('abc') returns latice parameters [a b c alpha beta gamma]
%          S = YSZ('elements') returns all elements in YSZ

% 1997 by ??

if nargin==0
        X='ysz';
        return;
end
X=[]; Y=[]; Z=[];

element=deblank(element);
if strcmp(element,'abc')
	X=[5.14 5.14 5.14 90 90 90];
	return;
elseif strcmp(element, 'elements')
	X=['Zr';'O '];
	return;
elseif strcmp(element, 'Zr')
%% TYPE HERE Zr POSITIONS IN LATICE COORDINATES:
	X = [ 0; .5; .5;  0];
	Y = [ 0; .5;  0; .5];
	Z = [ 0;  0; .5; .5];
elseif strcmp(element, 'O')
%% TYPE HERE O POSITIONS IN LATICE COORDINATES:
	X = [ 1;  3;  1;  1;  3;  3;  1;  3] / 4;
	Y = [ 1;  1;  3;  1;  3;  1;  3;  3] / 4;
	Z = [ 1;  1;  1;  3;  1;  3;  3;  3] / 4;
else
	error(sprintf('Unknown command option ''%s''', element));
end
X=X(:); Y=Y(:); Z=Z(:);
