function [X,Y,Z]=ni(element)
%NI        parameters of Ni primitive cell
%          [m,n,o] = NI(element) returns latice coordinates of
%          specified element
%          a = NI('abc') returns latice parameters [a b c alpha beta gamma]
%          S = NI('elements') returns all elements in ni

% 2005 by Pavol

if nargin==0
	X='ni';
	return;
end
X=[]; Y=[]; Z=[];
element=deblank(element);
if strcmp(element,'abc')
	X=[3.524 3.524 3.524 90 90 90];
	return;
elseif strcmp(element, 'elements')
	X=['Ni'];
	return;
elseif strcmp(element, 'Ni')
%% TYPE HERE Ni POSITIONS IN LATICE COORDINATES:
	X = [0 .5  0 .5];
	Y = [0 .5 .5  0];
	Z = [0  0 .5 .5];
else
	error(sprintf('Unknown command option ''%s''', element));
end
X=X(:); Y=Y(:); Z=Z(:);
