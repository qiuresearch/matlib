function [X,Y,Z]=mgo(element)
%MGO       parameters of MgO primitive cell
%          [m,n,o] = MGO(element) returns latice coordinates of
%          specified element
%          a = MGO('abc') returns latice parameters [a b c alpha beta gamma]
%          S = MGO('elements') returns all elements in MgO

% 1997 by Pavol

if nargin==0
	X='mgo';
	return;
end
X=[]; Y=[]; Z=[];
element=deblank(element);

if strcmp(element,'abc')
	X=[4.211 4.211 4.211 90 90 90];
	return;
elseif strcmp(element, 'elements')
	X=['Mg';'O '];
	return;
elseif strcmp(element, 'Mg')
%% TYPE HERE Mg POSITIONS IN LATICE COORDINATES:
	X = [0 .5  0 .5];
	Y = [0 .5 .5  0];
	Z = [0  0 .5 .5];
elseif strcmp(element, 'O')
%% TYPE HERE O POSITIONS IN LATICE COORDINATES:
	X = [.5  0  0 .5];
	Y = [ 0 .5  0 .5];
	Z = [ 0  0 .5 .5];
else
	error(sprintf('Unknown command option ''%s''', element));
end
X=X(:); Y=Y(:); Z=Z(:);
