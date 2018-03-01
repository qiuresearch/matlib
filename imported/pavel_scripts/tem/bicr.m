function bicr(xyz1, xyz2)
%BICR      Bicrystals visualization

N=[7 1];                                %Grid density

%%%%%%% Compute rotation matrixes %%%%%%
%first...
x=xyz1(1)*pi/180; y=xyz1(2)*pi/180; z=xyz1(3)*pi/180;
Rz = [cos(z)  -sin(z)   0
      sin(z)   cos(z)   0
      0        0        1];
Ry = [cos(y)   0   sin(y)
      0        1        0
     -sin(y)   0   cos(y)];
Rx = [1        0        0
      0    cos(x)  -sin(x)
      0    sin(x)   cos(x)];
Rxyz1=Rx*Ry*Rz;
%and second...
x=xyz2(1)*pi/180; y=xyz2(2)*pi/180; z=xyz2(3)*pi/180;
Rz = [cos(z)  -sin(z)   0
      sin(z)   cos(z)   0
      0        0        1];
Ry = [cos(y)   0   sin(y)
      0        1        0
     -sin(y)   0   cos(y)];
Rx = [1        0        0
      0    cos(x)  -sin(x)
      0    sin(x)   cos(x)];
Rxyz2=Rx*Ry*Rz;

%%%%%%% Display Several Useful Values %%%%%%
% since now x, y and z are Cartesian co-ordinates
n1=Rxyz1(:,3); n2=Rxyz2(:,3);           %normal vectors
s = -cross(n1, n2); s=s./norm(s);        %itersection
sx1=Rxyz1(:,1);sx2=Rxyz2(:,1);
n=n1+n2; n=n./norm(n);
sx1=sx1-n*(n'*sx1);
sx2=sx2-n*(n'*sx2);
fprintf('Si bicrystal - pole 004 - double tilt orientations:');
fprintf('\nFirst half:\tx=%.1f   y=%.1f   z=%.1f', xyz1);
fprintf('\nSecond half:\tx=%.1f   y=%.1f   z=%.1f', xyz2);
fprintf('\n\nDistortion\t%.1f\nMisorientation\t%.1f', ...
	   acos(n1'*n2)*180/pi,...
           acos( (sx1'*sx2)/ (norm(sx1)*norm(sx2)) )*180/pi);
fprintf('\nIntersection\t[%f   %f   %f]\n\n', s);

%%%%%%% Compute surfaces %%%%%%
[x0,y0]=meshgrid(-N:N); z0=0*x0;        %base grid
x1=x0; y1=y0; z1=z0;
x2=x0; y2=y0; z2=z0;xyz = [x0(:) y0(:) z0(:)] * Rxyz1';     %first surface
i = find(xyz*n2 > 0);                   %find area above 2nd surf
if strcmp(n1,n2)
    i=[];
end
xyz(i,:)=NaN*ones(length(i),3);         %hide it
x1(:)=xyz(:,1);
y1(:)=xyz(:,2);
z1(:)=xyz(:,3);
xyz = [x0(:) y0(:) z0(:)] * Rxyz2';     %second surface
i = find(xyz*n1 > 0);                   %find area above 1st surf
if strcmp(n1,n2)
    i=[];
end
xyz(i,:)=NaN*ones(length(i),3);         %hide it
x2(:)=xyz(:,1);
y2(:)=xyz(:,2);
z2(:)=xyz(:,3);
clear xyz;
xr1=x1( 1:N(2):size(x1,1) , 1:N(2):size(x1,2) );     %atoms
yr1=y1( 1:N(2):size(y1,1) , 1:N(2):size(y1,2) );
zr1=z1( 1:N(2):size(z1,1) , 1:N(2):size(z1,2) );
xr2=x2( 1:N(2):size(x2,1) , 1:N(2):size(x2,2) );
yr2=y2( 1:N(2):size(y2,1) , 1:N(2):size(y2,2) );
zr2=z2( 1:N(2):size(z2,1) , 1:N(2):size(z2,2) );

%%%%%%% Plot Them %%%%%%
clf;
hold on;
vdir=n; 
if ~any(isnan(s))
     vdir=vdir/3 + s;
end
view(vdir);
mesh([x1 x2], [y1 y2], [z1 z2]);
plot3(xr1(:), yr1(:), zr1(:), 'wo');
plot3(xr2(:), yr2(:), zr2(:), 'wo');
plot3(1.1*s(1)*[-N(1) N(1)], 1.1*s(2)*[-N(1) N(1)], 1.1*s(3)*[-N(1) N(1)], 'y');
axis([-N(1) N(1) -N(1) N(1) -N(1) N(1)]);
xlabel('x'); ylabel('y'); zlabel('z');
