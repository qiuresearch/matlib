function agbplot(theta, grid, showel, cellno, rotin)
%AGBPLOT   plots YBCO angle grain boundary
%          AGBPLOT(THETA, GRID, SHOWEL, CELLNO, ROTIN)
%          GRID    if nonzero, grid is showed
%          SHOWEL  show YBCO elements corresponding to
%                  nonzero indexes
%          THETA   vector with left and right misorientation
%                  angles in degrees
%          CELLNO  number of cells
%          ROTIN   specifies element in the centre of rotation
%
%          elements numbering:
%                  Y==1, Cu==2, O1==3, O2==4

% 1996 by Pavol

if nargin==0
     error('Not enough input arguments');
end, if nargin<5
     rotin=2;
end, if nargin<4
     cellno=8;
end, if nargin<3
     showel=[1 1 0 0];
end, if nargin<2
     grid=0;
end, if cellno(1)<2
     cellno=2;
end, if length(cellno)<2
     cellno(2)=cellno(1);
end

global ElStyles
if isempty(ElStyles)
        ElStyles=['og';'.r';'oc';'+c'];
end
el=str2mat('Y','Cu1','O1','O2');
a=ybco('abc'); b=a(2);a=a(1);

b=a(1);

xlim=[0.01 .5]*(cellno(1)+.5)*a;
ylim=[-.5 .5]*(cellno(2)+.5)*b;
n=ceil(sqrt( (cellno(1)*a)^2 + (cellno(2)*b)^2 )/min(a,b))+1;
theta=theta*pi/180;
Rl=[    cos(theta(1))   -sin(theta(1))
        sin(theta(1))   cos(theta(1))   ];
Rr=[    cos(theta(2))   sin(theta(2))
       -sin(theta(2))   cos(theta(2))   ];

ax=gca;
%Check Axes
if ~strcmp(get(ax, 'Tag'), 'AGB')
     cla;
     set(ax, 'Tag', 'AGB');
end
%Check zoom status
if strcmp(get(gcf,'windowbuttondownfcn'),'zoom(''down'')')     %zoom is on
     set(ax, 'NextPlot', 'Add', 'DrawMode', 'Fast');
else
     set(ax, 'XLim', xlim(2)*[-1 1], 'YLim', ylim, 'NextPlot', 'Add',...
        'DrawMode', 'Fast');
end
axis equal;

if rotin==1
     cnt=(round(n/2) + [.5 .5]) .* [a b];
elseif rotin==2
     cnt=round(n/2) .* [a b];
elseif rotin==3
     cnt=(round(n/2) + [0 .5]) .* [a b];
else
     cnt=(round(n/2) + [.5 0]) .* [a b];
end

h=get(ax, 'Children');
plts=zeros(4,2);
if isempty(h)                %First-Time Plot
     hgrid=plot(0, 0, '-', 'Tag', 'grid', 'Color', [.5 .5 .5],...
                'EraseMode', 'normal', 'Visible', 'Off', 'LineWidth', .1);
     for j=1:4
          [x,y]=lattice([n n 0], 'ybco', el(j,:));
          plts(j,1)=plot(0, 0, ElStyles(j,:), 'Tag', [el(j,:) 'left'],...
                     'EraseMode', 'normal', 'Visible', 'Off');
          plts(j,2)=plot(0, 0, ElStyles(j,:), 'Tag', [el(j,:) 'right'],...
                     'EraseMode', 'normal', 'Visible', 'Off');
          if(ElStyles(j,1)=='.')
               set(plts(j,:), 'MarkerSize', 13);
          else
               set(plts(j,:), 'MarkerSize', 4);
          end
     end
     plot(0, 0, 'wo', 'MarkerSize', 13);
     if isempty(findobj(gcf,'tag','legend'))
        hl=legend(plts(:,1), str2mat('Y', 'Cu', 'O1', 'O2'));
     end
     set(hl, 'Tag', 'legend');
else
     for i=1:4
          plts(i,1)=findobj(h, 'Tag', [el(i,:), 'left']);
          plts(i,2)=findobj(h, 'Tag', [el(i,:), 'right']);
     end
     hgrid=findobj(h, 'Tag', 'grid');
end

for j=1:4
     [x,y]=lattice([n n 0], 'ybco', el(j,:));
     xyl=[x-cnt(1), y-cnt(2)] * Rl';
     if theta(2)~=theta(1)
          xyr=[x-cnt(1), y-cnt(2)] * Rr';
     else
          xyr=xyl;
          xyr(:,1)=-xyr(:,1);
     end
     %Eliminate points behind boundary
     i=find(xyl(:,1)>xlim(1) | xyl(:,1)<-xlim(2) |...
            xyl(:,2)>ylim(2) | xyl(:,2)<ylim(1) ); 
     xyl(i,:)=[];
     i=find(xyr(:,1)<-xlim(1) | xyr(:,1)>xlim(2) |...
            xyr(:,2)>ylim(2) | xyr(:,2)<ylim(1) );
     xyr(i,:)=[];
     %find boundary points
     il=find(xyl(:,1)>-a); xybl=xyl(il,:);
     ir=find(xyr(:,1)<a);  xybr=xyr(ir,:);
     ll=size(xybl,1); lr=size(xybr,1);
     R = ( xybl(:,ones(lr,1)) - xybr(:,ones(ll,1))' ).^2 + ...
         ( xybl(:,2*ones(lr,1)) - xybr(:,2*ones(ll,1))' ).^2;
     R = sqrt(R);       %Matrix of distances rows...left side, cols...right side
     [outl,outr]=find(R<.99*a);
     %Eliminate point closer to boundary
     c=find(xybr(outr,1) > -xybl(outl,1));
     d=find(xybr(outr,1) < -xybl(outl,1));
     e=find(xybr(outr,1) == -xybl(outl,1));
     if isempty(outl)
          e=[];
     end
     %get rid of repeating elements in e
     le=length(e);
     i=1;
     while(i<le)
          q=find(e(i)==e(i+1:le));
          e(q)=[];
          le=length(e);
          i=i+1;
     end
     c=[c;e(1:2:length(e))];
     d=[d;e(2:2:length(e))];
     xyl(il( outl(c) ), :)=[];
     xyr(ir( outr(d) ), :)=[];
     if showel(j)
          set(plts(j,1), 'XData', xyl(:,1), 'YData', xyl(:,2), ...
              'Visible', 'On');
          set(plts(j,2), 'XData', xyr(:,1), 'YData', xyr(:,2), ...
              'Visible', 'On');
     else
          set(plts(j,:), 'Visible', 'Off');
     end
end
if grid
%LEFT SIDE
     [x,y]=lattice([n n 0], 'ybco', 'grid');
     xy=[x-cnt(1), y-cnt(2)] * Rl';
     xy(3:3:size(xy,1),:)=[];            %get rid of NaN
     len=size(xy,1);
%whole line behind x==0
     i=find(xy(1:2:len,1)>0 & xy(2:2:len,1)>0); i=2*i-1;
     xy([i i+1],:)=[];
     len=size(xy,1);
%first point behind x==0
     i=find(xy(1:2:len,1)>0); i=2*i-1;
     k=(0-xy(i+1,1)) ./ (xy(i,1)-xy(i+1,1));
     xy(i,1)=0*xy(i,1);
     xy(i,2)=k.*(xy(i,2)-xy(i+1,2)) + xy(i+1,2);
%second point behind x==0
     i=find(xy(2:2:len,1)>0); i=2*i;
     k=(0-xy(i-1,1)) ./ (xy(i,1)-xy(i-1,1));
     xy(i,1)=0*xy(i,1);
     xy(i,2)=k.*(xy(i,2)-xy(i-1,2)) + xy(i-1,2);
%add NaN
     xy0=xy; xy=zeros(1.5*len,2)+NaN;
     xy(1:3:1.5*len,:)=xy0(1:2:len,:);
     xy(2:3:1.5*len,:)=xy0(2:2:len,:);
     xyl=xy;
%RIGHT SIDE
     xy=[x-cnt(1), y-cnt(2)] * Rr';
     xy(3:3:size(xy,1),:)=[];            %get rid of NaN
     len=size(xy,1);
%whole line behind x==0
     i=find(xy(1:2:len,1)<0 & xy(2:2:len,1)<0); i=2*i-1;
     xy([i i+1],:)=[];
     len=size(xy,1);
%first point behind x==0
     i=find(xy(1:2:len,1)<0); i=2*i-1;
     k=(0-xy(i+1,1)) ./ (xy(i,1)-xy(i+1,1));
     xy(i,1)=0*xy(i,1);
     xy(i,2)=k.*(xy(i,2)-xy(i+1,2)) + xy(i+1,2);
%second point behind x==0
     i=find(xy(2:2:len,1)<0); i=2*i;
     k=(0-xy(i-1,1)) ./ (xy(i,1)-xy(i-1,1));
     xy(i,1)=0*xy(i,1);
     xy(i,2)=k.*(xy(i,2)-xy(i-1,2)) + xy(i-1,2);
%add NaN
     xy0=xy; xy=zeros(1.5*len,2)+NaN;
     xy(1:3:1.5*len,:)=xy0(1:2:len,:);
     xy(2:3:1.5*len,:)=xy0(2:2:len,:);
     xyr=xy;
%plot it
     xy=[xyl; xyr];
     set(hgrid, 'XData', xy(:,1), 'YData', xy(:,2), 'Visible', 'On');
else
     set(hgrid, 'Visible', 'Off');
end
axes(ax);
