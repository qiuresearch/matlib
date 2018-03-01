function [X,Y,Z]=gaas(element)
%GAAS      parameters of GaAs primitive cell
%          [m,n,o] = GAAS(element) returns latice coordinates of
%          specified element
%          a = GAAS('abc') returns latice parameters [a b c alpha beta gamma]
%          S = GAAS('elements') returns all elements in GAAS

% 1997 by Pavol

a=5.646;
X=[]; Y=[]; Z=[];
if nargin==0
        X='gaas';
        return;
end
if strcmp(element,'abc')
        X=[a a a 90 90 90];
elseif strcmp(element,'elements')
        X=['Ga';'As'];
elseif strcmp(element,'Ga')
        X=[0; .5; .5;  0];
        Y=[0; .5;  0; .5];
        Z=[0;  0; .5; .5];
elseif strcmp(element,'As')
        X=[0; .5; .5;  0]+.25;
        Y=[0; .5;  0; .5]+.25;
        Z=[0;  0; .5; .5]+.25;
else 
        error(sprintf('Unknown command option ''%s''', element));
end
