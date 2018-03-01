function [X,Y,Z]=Y2O3(element)
%Y2O3      parameters of Y2O3 primitive cell
%          [m,n,o] = Y2O3(element) returns latice coordinates of
%          specified element
%          a = Y2O3('abc') returns latice parameters [a b c alpha beta gamma]
%          S = Y2O3('elements') returns all elements in Y2O3

% 1997 by Pavol

if nargin==0
        X='y2o3';
        return;
end
a=10.604;
X=[]; Y=[]; Z=[];
if strcmp(element,'abc')
        X=[a a a 90 90 90];
        return;
elseif strcmp(element,'elements')
        X=['Y'; 'O'];
        return;
elseif strcmp(element,'Y')
        %8b positions
        X=[1;  1;  3;  3;  3;  3;  1;  1]/4;
        Y=[1;  3;  1;  3;  3;  1;  3;  1]/4;
        Z=[1;  3;  3;  1;  3;  1;  1;  3]/4;
        %24d positions
        x=-0.0327;
        X=[X;   x; .25;   0;  -x; .75;   0];
        Y=[Y;   0;   x; .25;   0;  -x; .75];
        Z=[Z; .25;   0;   x; .75;   0;  -x];
        X=[X;   x; .75;  .5;  -x; .25;  .5];
        Y=[Y;  .5;   x; .75;  .5;  -x; .25];
        Z=[Z; .75;  .5;   x; .25;  .5;  -x];
        X=[X; X+.5];
        Y=[Y; Y+.5];
        Z=[Z; Z+.5];
elseif strcmp(element,'O')
        %48e positions
        x=0.3907;
        y=0.152;
        z=0.3804;
        
        X=      [x;    z;    y;   -x;   -z;   -y];
        Y=      [y;    x;    z;   -y;   -x;   -z];
        Z=      [z;    y;    x;   -z;   -y;   -x];
        X=[X;    x;    z;    y;   -x;   -z;   -y];
        Y=[Y;   -y;   -x;   -z;    y;    x;    z];
        Z=[Z; .5-z; .5-y; .5-x; .5+z; .5+y; .5+x];
        X=[X; .5-x; .5-z; .5-y; .5+x; .5+z; .5+y];
        Y=[Y;    y;    x;    z;   -y;   -x;   -z];
        Z=[Z;   -z;   -y;   -x;    z;    y;    x];
        X=[X;   -x;   -z;   -y;    x;    z;    y];
        Y=[Y; .5-y; .5-x; .5-z; .5+y; .5+x; .5+z];
        Z=[Z;    z;    y;    x;   -z;   -y;   -x];
        X=[X; X+.5];
        Y=[Y; Y+.5];
        Z=[Z; Z+.5];
else 
        error(sprintf('Unknown command option ''%s''', element));
end
i = find(X>=1); X(i)=X(i)-1;
i = find(Y>=1); Y(i)=Y(i)-1;
i = find(Z>=1); Z(i)=Z(i)-1;
i = find(X<0); X(i)=X(i)+1;
i = find(Y<0); Y(i)=Y(i)+1;
i = find(Z<0); Z(i)=Z(i)+1;
