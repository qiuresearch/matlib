function [X,Y,Z]=zrsi(element)
%ZRSI      parameters of ZrSi primitive cell
%          [m,n,o] = ZRSI(element) returns latice coordinates of
%          specified element
%          a = ZRSI('abc') returns latice parameters [a b c alpha beta gamma]
%          S = ZRSI('elements') returns all elements in ZrSi

% 1997 by ??

if nargin==0
        X='zrsi';
        return;
end
X=[]; Y=[]; Z=[];

element=deblank(element);
if strcmp(element,'abc')
	X=[6.968 3.778 5.291 90 90 90];
	return;
elseif strcmp(element, 'elements')
	X=['Zr';'Si'];
	return;
elseif strcmp(element, 'Zr')
%% TYPE HERE Zr POSITIONS IN LATICE COORDINATES:
%Pnma (62) 4c:
	x=0.178; z=1/8;
	X = [x    1-x  1/2-x  1/2+x];
	Y = [1/4  3/4    3/4    1/4];
	Z = [z    1-z  1/2+z  1/2-z];
elseif strcmp(element, 'Si')
%% TYPE HERE Si POSITIONS IN LATICE COORDINATES:
%Pnma (62) 4c:
	x=0.0032; z=0.611;
	X = [x    1-x   1/2-x  1/2+x];
	Y = [1/4  3/4     3/4    1/4];
	Z = [z    1-z  -1/2+z  3/2-z];
else
	error(sprintf('Unknown command option ''%s''', element));
end
X=X(:); Y=Y(:); Z=Z(:);
