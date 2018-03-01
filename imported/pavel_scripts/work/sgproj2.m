% STEREOGRAPHIC PROJECTION

function sgproj2

close all;

figure;
hold on;
axis equal off;

phi = 3/2*pi:pi/50:2*pi;
x = cos(phi);
y = sin(phi);
plot(x,y,'k-');

idx = 0;
for i=0:1,
  for j=0:1,
    for k=0:1,
      if ~(i==0 & j==0 & k==0),
        plot_dir([i,j,k],'blue',1);
        idx = idx+1;
        base(idx,1:3) = [i,j,k];
      end;  
    end;
  end;
end;

sline([0,0,1],[0,1,0],'k-');
sline([0,0,1],[1,0,0],'k-');

plot_dir([1,1,2],'blue',1);
plot_dir([1,2,1],'blue',1);
plot_dir([2,1,1],'blue',1);
base = [base; 1 1 2; 1 2 1; 2 1 1];

A1 = middir([0,0,1; 1,1,2]);
A2 = middir([0,1,1; 1,1,2]);
A3 = middir([0,0,1; 0,1,1]);
B1 = middir([1,1,2; 1,2,1]);
B2 = middir([1,2,1; 0,1,1]);
C1 = middir([1,1,2; 1,1,1]);
C2 = middir([1,2,1; 1,1,1]);
D1 = middir([1,2,1; 0,1,0]);
D2 = middir([0,1,0; 0,1,1]);

X1 = middir([0,0,1; 1,1,2; 0,1,1]);
X2 = middir([1,1,2; 1,2,1; 0,1,1]);
X3 = middir([1,1,2; 1,1,1; 1,2,1]);
X4 = middir([0,1,0; 0,1,1; 1,2,1]);

pairs = [X1,A1;
X1,A2;
X1,A3;
X2,B1;
X2,B2;
X2,A2;
X3,C1;
X3,C2;
X3,B1;
X4,D1;
X4,D2;
X4,B2];

perm = [1,2,3; 2,3,1; 3,1,2];
for idx=1:3,
  for i=1:size(pairs,1),
    sline(pairs(i,perm(idx,:)),pairs(i,3+perm(idx,:)),'b-');
  end;  
end;  






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function md = middir(mdir)

n = size(mdir,1);
sum = 0;
for i=1:n,
  sum = sum+mdir(i,:)/norm(mdir(i,:));
end;

md = sum/n;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function proj = calc_projection(dir)

south_pole = [0,0,-1];
coeff = 1/sqrt(sum(dir.^2));
acoord = coeff*dir;
bavect = -south_pole+acoord;
proj = bavect(1:2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function h = plot_dir(dir,color,atext)

proj = calc_projection(dir);

if atext,
  if abs(dir(1))<10 & abs(dir(2))<10 & abs(dir(3))<10,
    txt = sprintf('[%d%d%d]',dir(1),dir(2),dir(3));
  else
    txt = sprintf('[%d,%d,%d]',dir(1),dir(2),dir(3));
  end;  
  text(proj(2)+1/40,-proj(1),txt);  
end;

h = plot(proj(2),-proj(1),'ko-');
set(h,'MarkerFaceColor',color,'MarkerEdgeColor',color);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_all_dirs(m,color),

for h=-m:m,
  for k=-m:m,
    for l=0:m,
      dir = [h,k,l];
      plot_dir(dir,color);
    end;
  end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% factor=0 - exactly dir1
% factor=1 - exactly dir2
% factor increases -> we are approaching dir2 and moving further from dir1

function dir = calc_dir_between(dir1,dir2,factor)

dir = dir1+(dir2-dir1)*factor;
dir = rational(dir);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function handle = sline(dir1,dir2,pattern),

delta = (dir2-dir1)/100;

for i=1:101,
  dir = dir1+(i-1)*delta;
  dxy(i,:) = calc_projection(dir);
end;  

handle = plot(dxy(:,2),-dxy(:,1),pattern);
