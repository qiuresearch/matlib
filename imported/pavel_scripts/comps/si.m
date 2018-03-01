function [X,Y,Z]=SI(element)
%SI        parameters of SI primitive cell
%          [m,n,o] = SI(element) returns latice coordinates of
%          specified element
%          a = SI('abc') returns latice parameters [a b c alpha beta gamma]
%          S = SI('elements') returns all elements in SI

% 1997 by Pavol

a=5.43;
X=[]; Y=[]; Z=[];
if nargin==0
   X='Si';
   return;
end
if strcmp(element,'abc')
        X=[a a a 90 90 90];
elseif strcmp(element,'elements')
        X='Si';
elseif strcmp(element,'Si')
        X=[0; .5; .5;  0];
        Y=[0; .5;  0; .5];
        Z=[0;  0; .5; .5];
        X=[X; X+.25];
        Y=[Y; Y+.25];
        Z=[Z; Z+.25];
else 
        error(sprintf('Unknown command option ''%s''', element));
end
