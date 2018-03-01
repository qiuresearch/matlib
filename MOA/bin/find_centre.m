% find_centre() takes a given image and attempts to locate the optical centre
% of that image.
% Here is the plan
% 1.  Show the image.
% 2.  Ask the user to delineate the inside of the ring by clicking three times
% on their mouse.
% 3.  Ask the user to delineate the outside of the ring by clicking once.
% 4.  Construct r-files at the three sites selected by the user to determine
% the radius of the ring at all three sites.
% 5.  If the user was smart, these should all be the same.
% 6.  Allowing for your average user, we adjust the position of the centre of
% the circle to make it fit the ring properly.
% 7.  Return the co-ordinates of the centre of the ring.
 
function [x,y] = find_centre(piccie)

% Show the image
figure(1); clf ; imagesc(piccie);hold on

% Contain the diffraction ring within two values, r_in and r_out.
'Please pick three points just inside one of the diffraction rings.'
[xe,ye] = ginput(3) ; [xc,yc,r_in] = centre_circle(xe,ye);
for j=1:3 ; theta(j) = atan2(ye(j)-yc,xe(j)-xc); end
circle(r_in,xc,yc,'w');
'Please move the cursor to a position that is outside the diffraction ring'
[xw,yw] = ginput(1); r_out = norm([xw-xc,yw-yc]); circle(r_out,xc,yc,'w');
plot(xe,ye,'w*'); 

% Construct r-files for the three directions
phi_r = 0.3 ; % The angular half-width of the r-file in radians
intens = zeros(r_out-r_in+1, 3); best(3) = 0 ;
for j=1:3 % cycle through all three sites
 k = 1 ; r = r_in;
 brightest = 0 ; 

 while(r<r_out)
      phi = theta(j) - phi_r ; 
      num = 0;

      while(phi<(theta(j)+phi_r)) 

      x = round(xc + r*cos(phi)); 
      y = round(yc + r*sin(phi)) ;

      intens(k, j) = intens(k,j) + piccie(y,x);
      num = num + 1 ;
      phi = phi + 1/r; 
      end
      intens(k,j) = intens(k,j)/num ;
      if intens(k,j) > brightest
           brightest = intens(k,j) ;
           best(j) = k ;
      end

 k = k+1 ; r = r + 1 ;
 end
end

% Plot the r-files out.
 figure(2); clf;
 plot(intens(:,1));hold on; plot(intens(:,2),'r'); plot(intens(:,3),'g');

% Refine the location of the maxima a little using neighbouring values.
 for j=1:3
       temp1 = 0;    
       if and(best(j)>1,best(j)<(r_out-r_in))

           temp1 = 2*intens(best(j)) - intens(best(j)-1) - intens(best(j)+1) ;
           if temp1 > 0 
                 temp1=0.5*(intens(best(j)+1)-intens(best(j)-1))/temp1;end;
           if abs(temp1)>1 temp1 = 0 ; end; 
           temp1;
       end     
       xe(j) = xc + (r_in + best(j) + temp1 - 1)*cos(theta(j));
       ye(j) = yc + (r_in + best(j) + temp1 - 1)*sin(theta(j)); 
       plot(best(j) + temp1, intens(best(j),j),'s') 
 end

% Now locate the real centre.
[x,y,r] = centre_circle(xe,ye);
          
% Finally plot it up for all to see.
          figure(1);circle(r,x,y,'w'); plot(xe,ye,'ws');



function [xc,yc,r] = centre_circle(xe,ye)
% Xe and Ye hold co-ordinates for three points.
% Function makes a circle centred on those three points and returns its 
% centre (xc,yc) and radius r.

for j=1:3
rs(j) = xe(j)^2+ye(j)^2;
end
num = -2.0*(xe(3)*(ye(2)-ye(1))+xe(2)*(ye(1)-ye(3))+xe(1)*(ye(3)-ye(2)));
xc = (ye(3)*(rs(2)-rs(1))+ye(2)*(rs(1)-rs(3))+ye(1)*(rs(3)-rs(2)))/num;
num = -2.0*(ye(3)*(xe(2)-xe(1))+ye(2)*(xe(1)-xe(3))+ye(1)*(xe(3)-xe(2)));
yc = (xe(3)*(rs(2)-rs(1))+xe(2)*(rs(1)-rs(3))+xe(1)*(rs(3)-rs(2)))/num;
r = norm([xc-xe(1),yc-ye(1)]);

function h=circle(r,x0,y0,C,Nb)
% CIRCLE adds circles to the current plot
%
% CIRCLE(r,x0,y0) adds a circle of radius r centered at point x0,y0. 
% If r is a vector of length L and x0,y0 scalars, L circles with radii r 
% are added at point x0,y0.
% If r is a scalar and x0,y0 vectors of length M, M circles are with the same 
% radius r are added at the points x0,y0.
% If r, x0,y0 are vector of the same length L=M, M circles are added. (At each
% point one circle).
% if r is a vector of length L and x0,y0 vectors of length M~=L, L*M circles are
% added, at each point x0,y0, L circles of radius r.
%
% CIRCLE(r,x0,y0,C)
% adds circles of color C. C may be a string ('r','b',...) or the RGB value. 
% If no color is specified, it makes automatic use of the colors specified by 
% the axes ColorOrder property. For several circles C may be a vector.
%
% CIRCLE(r,x0,y0,C,Nb), Nb specifies the number of points used to draw the 
% circle. The default value is 300. Nb may be used for each circle individually.
%
% h=CIRCLE(...) returns the handles to the circles.
%
% Try out the following (nice) examples:
%
%% Example 1
%
% clf;
% x=zeros(1,200);
% y=cos(linspace(0,1,200)*4*pi);
% rad=linspace(1,0,200);
% cmap=hot(50);
% circle(rad,x,y,[flipud(cmap);cmap]);
%
%% Example 2
%
% clf;
% the=linspace(0,pi,200); 
% r=cos(5*the);
% circle(0.1,r.*sin(the),r.*cos(the),hsv(40));
% 
%
%% Example 3
%
% clf
% [x,y]=meshdom(1:10,1:10);
% circle([0.5,0.3,0.1],x,y,['r';'y']);
%
%% Example 4
%
% clf
% circle(1:10,0,0,[],3:12);
%
%% Example 5
%
% clf;
% circle((1:10),[0,0,20,20],[0,20,20,0]);

% written by Peter Blattner, Institute of Microtechnology, University of 
% Neuchatel, Switzerland, blattner@imt.unine.ch



% Check the number of input arguments 

if nargin<1,
  r=[];
end;

if nargin==2,
  error('Not enough arguments');
end;

if nargin<3,
  x0=[];
  y0=[];
end;
 

if nargin<4,
  C=[];
end

if nargin<5,
  Nb=[];
end

% set up the default values

if isempty(r),r=1;end;
if isempty(x0),x0=0;end;
if isempty(y0),y0=0;end;
if isempty(Nb),Nb=300;end;
if isempty(C),C=get(gca,'colororder');end;

% work on the variable sizes

x0=x0(:);
y0=y0(:);
r=r(:);
Nb=Nb(:);


if isstr(C),C=C(:);end;

if length(x0)~=length(y0),
  error('length(x0)~=length(y0)');
end;

% how many rings are plottet

if length(r)~=length(x0)
  maxk=length(r)*length(x0);
else
  maxk=length(r);
end;

% drawing loop

for k=1:maxk
  
  if length(x0)==1
    xpos=x0;
    ypos=y0;
    rad=r(k);
  elseif length(r)==1
    xpos=x0(k);
    ypos=y0(k);
    rad=r;
  elseif length(x0)==length(r)
    xpos=x0(k);
    ypos=y0(k);
    rad=r(k);
  else
    rad=r(fix((k-1)/size(x0,1))+1);
    xpos=x0(rem(k-1,size(x0,1))+1);
    ypos=y0(rem(k-1,size(y0,1))+1);
  end;

  the=linspace(0,2*pi,Nb(rem(k-1,size(Nb,1))+1,:)+1);
  h(k)=line(rad*cos(the)+xpos,rad*sin(the)+ypos);
  set(h(k),'color',C(rem(k-1,size(C,1))+1,:));

end;





