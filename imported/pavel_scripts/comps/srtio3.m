function [X,Y,Z]=srtio3(element)
%SRTIO3    parameters of SrTiO3 primitive cell
%          [m,n,o] = SRTIO3(element) returns latice coordinates of
%          specified element
%          a = SRTIO3('abc') returns latice parameters [a b c alpha beta gamma]
%          S = SRTIO3('elements') returns all elements in SRTIO3

% 1997 by Pavol

a=3.905;
X=[]; Y=[]; Z=[];
if nargin==0
	X='srtio3';
	return;
end
if strcmp(element,'abc')
        X=[a a a 90 90 90];
elseif strcmp(element,'elements')
        X=['Sr';'Ti';'O '];
elseif strcmp(element,'Sr')
        X=[.5];
        Y=[.5];
        Z=[.5];
elseif strcmp(element,'Ti')
        X=0; Y=0; Z=0;
elseif strcmp(deblank(element),'O')
        X=[0.5;  0;  0];
        Y=[0;   .5;  0];
        Z=[0;    0; .5];
else 
        error(sprintf('Unknown command option ''%s''', element));
end
