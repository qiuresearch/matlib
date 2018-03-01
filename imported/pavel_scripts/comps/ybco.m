function [X,Y,Z]=YBCO(element)
%YBCO      parameters of YBCO primitive cell
%          [m,n,o] = YBCO(element) returns latice coordinates of
%          specified element
%          a = YBCO('abc') returns latice parameters [a b c alpha beta gamma]
%          S = YBCO('elements') returns all elements in YBCO

% 1997 by Pavol


a=3.83; b=3.89; c=11.69;
X=[]; Y=[]; Z=[];
if nargin==0
	X='ybco';
	return;
end
element=deblank(element);
if strcmp(element,'abc')
        X=[a b c 90 90 90];
elseif strcmp(element, 'elements')
        X=['Y '; 'Ba'; 'Cu'; 'O '];       
elseif strcmp(element, 'Y')
        X=.5; Y=.5; Z=.5;
elseif strcmp(element, 'Ba')
        X=[.5 ; .5];
        Y=[.5 ; .5];
        Z=[1  ;  5]/6;
elseif strcmp(element, 'Cu1')
        X=0; Y=0; Z=0;
elseif strcmp(element, 'Cu2')
        X=[0 ; 0];
        Y=[0 ; 0];
        Z=[1 ; 2]/3;
elseif strcmp(element, 'O1')
        X= 0;
        Y=.5;
        Z= 0;
elseif strcmp(element, 'O2')
        X=[.5 ; .5];
        Y=[ 0 ;  0];
        Z=[1  ;  2]/3;
elseif strcmp(element, 'O3')
        X=[ 0 ;  0];
        Y=[.5 ; .5];
        Z=[1  ;  2]/3;
elseif strcmp(element, 'O4')
        X=[0 ; 0];
        Y=[0 ; 0];
        Z=[1 ; 5]/6;
elseif strcmp(element, 'Ov')
        X=.5;
        Y=0;
        Z=0;
elseif strcmp(element, 'Cu')
        for i=1:2
                [x,y,z]=ybco(sprintf('Cu%i',i));
                X=[X;x]; Y=[Y;y]; Z=[Z;z];
        end
elseif strcmp(element, 'O')
        for i=1:4
                [x,y,z]=ybco(sprintf('O%i',i));
                X=[X;x]; Y=[Y;y]; Z=[Z;z];
        end
else        
        error(sprintf('Unknown command option ''%s''', element));
end

