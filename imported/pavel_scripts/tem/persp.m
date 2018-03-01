function [phi,target]=persp(PHI, XC)
%PERSP     3-D graph perspective specification.
%          PERSP(PHI) or PERSP(PHI, XC) set the perspective of the
%          current 3-D plot
%          PHI is the subtended view angle of the normalized plot cube
%          (in degrees) and controls the amount of perspective distortion:
%               PHI =  0 degrees is orthographic projection
%               PHI = 10 degrees is like a telephoto lens
%               PHI = 25 degrees is like a normal lens
%               PHI = 60 degrees is like a wide angle lens
%          XC is the target (or look-at) point within
%          the normalized plot cube.  XC=[xc,yc,zc] specifies the
%          point (xc,yc,zc) in the plot cube.
%          [PHI, XC]=PERSP returns parameters of the current perspective view

% Pavol 1997

azel=get(gca,'View');
if nargin==0
       a=get(gca,'Xform');
       az=azel(1)*pi/180; el=azel(2)*pi/180;
       T = [ cos(az)           sin(az)           0       0
            -sin(el)*sin(az)   sin(el)*cos(az)   cos(el) 0
             cos(el)*sin(az)  -cos(el)*cos(az)   sin(el) 0
             0                 0                 0       1 ];
       M = a/T;
       if M(4,3)~=0
               d=-1/M(4,3);
       else
               d=-inf;
       end
       phi=atan(1/(sqrt(2)*d))*360/pi;
       r=M(:,4); r(4)=d*(r(4)-1);
       target=T\r;
       target=-target(1:3);
elseif nargin==1
       view(viewmtx(azel(1), azel(2), PHI));
elseif nargin==2
       view(viewmtx(azel(1), azel(2), PHI, XC));
end
