function fpbshift(xo)
%upb=fpbshift(xo) o moves along 111, -.5 < xo < .5

ro=[.5+xo 0 0; .5-xo 1 0; .5+xo 1 1; .5-xo 0 1;
    0 .5+xo 0; 0 .5-xo 1; 1 .5+xo 1; 1 .5-xo 0;
    0 0 .5+xo; 1 0 .5-xo; 1 1 .5+xo; 0 1 .5-xo;];
zo=-.5;
%large, inactive [Sc]
r1=[0 0 0; 1 1 0; 1 0 1; 0 1 1];
z1=3/8;
%small, active [Nb]
r2=[1 0 0; 0 1 0; 1 1 1; 0 0 1];
z2=5/8;
%Pb cation:
za=2;
%all z's:
zc = [zo*ones(12,1); z1*ones(4,1); z2*ones(4,1)];
rc = [ro;r1;r2];

xpb=linspace(-.48,.48);
upb=0*xpb;
for i=1:prod(size(upb))
    ra=zeros(12+4+4,3) + .5+xpb(i);
    upb(i) = za * sum( zc ./ sqrt(sum( (ra-rc).^2,2 )) );
end
[ym,i]=min(upb);
xm=xpb(i);
figure(1); plot(xpb, upb, xm, ym, '*');
figure(2); plot3(ro(:,1),ro(:,2),ro(:,3),'ok');
hold on;
plot3(r1(:,1),r1(:,2),r1(:,3),'.','MarkerSize', 28, 'Color', ncol(2));
plot3(r2(:,1),r2(:,2),r2(:,3),'.','MarkerSize', 20, 'Color', 'b');
plot3(xm+.5, xm+.5, xm+.5, '*','MarkerSize', 10, 'Color', 'r');
plot3([0 1], [0 1], [0 1], 'k--');
%axis([0 1 0 1 0 1])
view(-28.5,-16);
hold off
