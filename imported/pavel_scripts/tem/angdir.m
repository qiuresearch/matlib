function theta=angdir(mno1, mno2, abcABG)
%ANGDIR    Angle between lattice directions
%          ANGDIR(MNO1, MNO2)
%          calculates angles between directions MNO1 and MNO2
%          MNO1 and MNO2 can be 3-column matrixs
%          ANGDIR(MNO1, MNO2, abcABG)
%          abcABG is 6-elements vector [a b c alpha beta gamma] of
%          lattice parameters
%          ANGDIR(MNO1, MNO2, compound)
%          compound is function describing lattice

% 1997 by Pavol

if nargin<3
	abcABG=[1 1 1 90 90 90];
elseif isstr(abcABG)
        abcABG=feval(abcABG, 'abc');
elseif length(abcABG)~=6
	error('abcABG must be 6-elements vector');
end
if size(mno1,1)==1 & size(mno2,1)>1
	mno1=mno1(ones(size(mno2,1),1),1:3);
elseif size(mno2,1)==1 & size(mno1,1)>1
	mno2=mno2(ones(size(mno1,1),1),1:3);
end
if any(size(mno1)~=size(mno2))
	error('mno1 and mno2 must be of the same size');
end
abcABG(4:6)=abcABG(4:6)*pi/180;
a=abcABG(1); b=abcABG(2); c=abcABG(3);
alpha=abcABG(4);beta=abcABG(5);gamma=abcABG(6);

%Calculate fundamental lattice vectors
a1=a * [1               0                                               0];
a2=b * [cos(gamma)      sin(gamma)                                      0];
a3=    [cos(beta)       (cos(alpha)-cos(beta)*cos(gamma))/sin(gamma)    0];
a3(3) = sqrt(1-a3*a3');
a3=c * a3;

%Calculate directions in cartezian co-ordinates
A=([a1;a2;a3]);   
r1=(mno1)*A;	%r1 and r2 have 3 columns
r2=(mno2)*A;	

%Calculate angles...
nom=(sum((r1.*r2)'))';
n1=sqrt(sum((r1').^2));
n2=sqrt(sum((r2').^2));
den=(n1.*n2)';
theta=180/pi*acos(nom./den);
