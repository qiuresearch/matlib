function [X,Y,Z]=zr2si(element)
%ZR2SI     parameters of Zr2Si primitive cell
%          [m,n,o] = ZR2SI(element) returns latice coordinates of
%          specified element
%          a = ZR2SI('abc') returns latice parameters [a b c alpha beta gamma]
%          S = ZR2SI('elements') returns all elements in Zr2Si

% 1997 by ??

if nargin==0
        X='zr2si';
	return;
end
X=[]; Y=[]; Z=[];
element=deblank(element);

if strcmp(element,'abc')
	X=[6.581 6.581 5.372 90 90 90];
	return;
elseif strcmp(element, 'elements')
	X=['Zr';'Si'];
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
else
	error(sprintf('Unknown command option ''%s''', element));
end
X=X(:); Y=Y(:); Z=Z(:);
