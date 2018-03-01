function [X,Y,Z]=sio2(element)
%SIO2      parameters of SiO2 primitive cell
%          [m,n,o] = SIO2(element) returns latice coordinates of
%          specified element
%          a = SIO2('abc') returns latice parameters [a b c alpha beta gamma]
%          S = SIO2('elements') returns all elements in SiO2

% 1997 by ??

if nargin==0
	X='sio2';
	return;
end
X=[]; Y=[]; Z=[];
element=deblank(element);
if strcmp(element,'abc')
	X=[5.03 5.03 8.22 90 90 120];
	return;
elseif strcmp(element, 'elements')
	X=['Si';'O '];
	return;
elseif strcmp(element, 'Si')
%% TYPE HERE Si POSITIONS IN LATICE COORDINATES:
	X = [1/3  2/3  2/3  1/3];
	Y = [2/3  1/3  1/3  2/3];
	Z = [.44  .56  .94  .06];
elseif strcmp(element, 'O1')
%% TYPE HERE O1 POSITIONS IN LATICE COORDINATES:
	X = [1/3  2/3];
	Y = [2/3  1/3];
	Z = [1/4  3/4];
elseif strcmp(element, 'O2')
%% TYPE HERE O2 POSITIONS IN LATICE COORDINATES:
	X = [1/2 0    1/2  1/2  0    1/2];
	Y = [0   1/2  1/2    0  1/2  1/2];
	Z = [0   0    0    1/2  1/2  1/2];
elseif strcmp(element, 'O')
	for i=1:2
		[x,y,z]=sio2(sprintf('O%i',i));
		X=[X;x]; Y=[Y;y]; Z=[Z;z];
	end
else
	error(sprintf('Unknown command option ''%s''', element));
end
X=X(:); Y=Y(:); Z=Z(:);
