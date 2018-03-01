function [x,y]=pickxy
%PICKXY    wizard for picking up data points from scanned plots
%    [X,Y] = PICKXY
%    [XY] = PICKXY or

%Define axis
prompt={'Coordinates of point 1:',...
        'Coordinates of point 2:',...
        'Coordinates of point 3:'};
def={'[0 0]','[1 0]','[0 1]'};
tit='Define xy axis by selecting 3 points';
lineNo=1;
axes(gca);
orgax={get(gca,'NextPlot'),...
         get(gca,'XLimMode'),...
         get(gca,'YLimMode'),...
         get(gca,'ZLimMode')};
answer=inputdlg(prompt,tit,lineNo,def);
if isempty(answer)
   return;
end
h=line('parent',gca,'xdata',[],'ydata',[],...
   'marker','+','linestyle','none','color','r');
for i=1:3
        xyax(i,:)=eval([ '[' answer{i} ']' ]);          %true coordinates
end
axis(axis);
set(gca,'NextPlot','Add');
for i=1:3
   XYax(i,:)=ginput(1);
    %position within gca
   set(h,'xdata',XYax(1:i,1),'ydata',XYax(1:i,2));
   ht(i)=text(XYax(i,1),XYax(i,2),sprintf('[%.2g %.2g]',xyax(i,:)),...
      'HorizontalAlignment','Left','VerticalAlignment','Bottom',...
      'color','r');
end

%Calculations...
v=[xyax(2:3,1)-xyax(1,1) , xyax(2:3,2)-xyax(1,2)];
V=[XYax(2:3,1)-XYax(1,1) , XYax(2:3,2)-XYax(1,2)];
M=v'/V';
%Transformation matrix;
XY0=XYax(1,:) - ( M \ (xyax(1,:))' )';                  %coz xy'=M*(XY'-XY0')

%Pick up points...
msgbox({'Now pickup your points','and finish with return key.'},'PICKXY','modal');
pause(.1);drawnow;
XY=ginput;
XY(1,:)=[];
xy=M*(XY-XY0( ones(1,size(XY,1)) , : ) )';
xy=xy';
if nargout<2
   x=xy;
else
   x=xy(:,1);
   y=xy(:,2);
end

%Clean Up the Mess...
delete(h,ht);
set(gca, 'NextPlot',orgax{1},...
         'XLimMode',orgax{2},...
         'YLimMode',orgax{3},...
         'ZLimMode',orgax{4});
