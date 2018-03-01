function [X,Y,Z]=zro2(element)
%ZRO2      returns parameters of ZrO2 primitive cell
%          [m,n,o] = ZRO2(element) returns latice coordinates of
%          specified element
%          a = ZRO2('abc') returns latice parameters [a b c alpha beta gamma]
%          S = ZRO2('elements') returns all elements in ZRO2

% 1997 by Pavol

if nargin==0
        X='zro2';
	return;
end
a=5.08;
X=[]; Y=[]; Z=[];
if strcmp(element, 'abc')
        X=[a a a 90 90 90];
elseif strcmp(element, 'elements')
        X=['Zr';'O '];
elseif strcmp(element, 'Zr')
        X = [ 0; .5; .5;  0];
        Y = [ 0; .5;  0; .5];
        Z = [ 0;  0; .5; .5];
elseif strcmp(element, 'O')
        X = [ 1;  3;  1;  1;  3;  3;  1;  3] / 4;
        Y = [ 1;  1;  3;  1;  3;  1;  3;  3] / 4;
        Z = [ 1;  1;  1;  3;  1;  3;  3;  3] / 4;
else 
        error(sprintf('Unknown command option ''%s''', element));
end
