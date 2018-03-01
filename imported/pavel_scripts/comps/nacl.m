function [X,Y,Z]=nacl(element)
%NACL      parameters of nacl primitive cell
%          [m,n,o] = NACL(element) returns latice coordinates of
%          specified element
%          a = NACL('abc') returns latice parameters [a b c alpha beta gamma]
%          S = NACL('elements') returns all elements in nacl

% PJ, 2006
% Ref: Webster, Michael.  Some diffractometer test crystals: a summary.
%      Journal of Applied Crystallography  (1998),  31(3),  510-514.

if nargin==0
	X='nacl';
	return;
end
X=[]; Y=[]; Z=[];
element=deblank(element);
if strcmp(element,'abc')
	X=[5.6402, 5.6402, 5.6402, 90, 90, 90];
	return;
elseif strcmp(element, 'elements')
	X=['Na';'Cl'];
	return;
elseif strcmp(element, 'Na')
%% TYPE HERE Na POSITIONS IN LATICE COORDINATES:
        X=[0; .5; .5;  0];
        Y=[0; .5;  0; .5];
        Z=[0;  0; .5; .5];
elseif strcmp(element, 'Cl')
%% TYPE HERE Cl POSITIONS IN LATICE COORDINATES:
        X=[.5; 0;  0; .5];
        Y=[0; .5;  0; .5];
        Z=[0;  0; .5; .5];
else
	error(sprintf('Unknown command option ''%s''', element));
end
X=X(:); Y=Y(:); Z=Z(:);
