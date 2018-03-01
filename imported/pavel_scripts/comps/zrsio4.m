function [X,Y,Z]=zrsio4(element)
%ZRSIO4    parameters of ZrSiO4 primitive cell
%          [m,n,o] = ZRSIO4(element) returns latice coordinates of
%          specified element
%          a = ZRSIO4('abc') returns latice parameters [a b c alpha beta gamma]
%          S = ZRSIO4('elements') returns all elements in ZrSiO4

% 1997 by ??

if nargin==0
        X='zrsio4';
	return;
end
X=[]; Y=[]; Z=[];
element=deblank(element);

if strcmp(element,'abc')
	X=[6.604 6.604 5.979 90 90 90];
	return;
elseif strcmp(element, 'elements')
	X=['Zr';'Si';'O '];
	return;
elseif strcmp(element, 'Zr')
%% TYPE HERE Zr POSITIONS IN LATICE COORDINATES:
	X = [];
	Y = [];
	Z = [];
elseif strcmp(element, 'Si')
%% TYPE HERE Si POSITIONS IN LATICE COORDINATES:
	X = [];
	Y = [];
	Z = [];
elseif strcmp(element, 'O')
%% TYPE HERE O POSITIONS IN LATICE COORDINATES:
	X = [];
	Y = [];
	Z = [];
else
	error(sprintf('Unknown command option ''%s''', element));
end
X=X(:); Y=Y(:); Z=Z(:);
