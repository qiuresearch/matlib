function [X,Y,Z]=zn(element)
%ZN        parameters of Zn primitive cell
%          [m,n,o] = ZN(element) returns latice coordinates of
%          specified element
%          a = ZN('abc') returns latice parameters [a b c alpha beta gamma]
%          S = ZN('elements') returns all elements in Zn

% 2005 by ??

if nargin==0
	X='zn';
	return;
end
X=[]; Y=[]; Z=[];
element=deblank(element);
if strcmp(element,'abc')
	X=[2.6649, 2.6649, 4.9468, 90, 90, 120];
	return;
elseif strcmp(element, 'elements')
	X=['Zn'];
	return;
elseif strcmp(element, 'Zn')
%% TYPE HERE Zn POSITIONS IN LATICE COORDINATES:
	X = [0, 2/3];
	Y = [0, 1/3];
	Z = [0, 1/2];
else
	error(sprintf('Unknown command option ''%s''', element));
end
X=X(:); Y=Y(:); Z=Z(:);
