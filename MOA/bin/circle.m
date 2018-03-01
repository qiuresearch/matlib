%  function [positions] = circle()

%  lets you plot a circle to screen and move it round.
%  Good for finding the centre of circles
%  returns in positions a column of x-values and a column of y-values.
%  these are the circle centre locations used during execution.
%  to use it, display a figure.
%  clicking the left mouse button (or push 'c')will put the circle centre there.
%  clicking the middle mouse button (or type 'p') will put the circle perimeter there.
%  clicking the right mouse button (or typeing 'q') quits .

function [positions] = circle()

%  Tell the user what to do.
fprintf(1,'\nClick left mouse button (or type ''c'') to locate circle centre.\n');
fprintf(1,'Click centre mouse button (or type ''p'') to locate circle perimeter.\n');
fprintf(1,'Click right mouse button (or type ''q'') to finish.\n\n');

% Define the elements of the circle
Num_elements = 72;  % Number of edges in circle.
angles = [0:Num_elements] * 2 * pi/ Num_elements;
x_circle = cos(angles); y_circle=sin(angles);

% Find out if the image hold was on and initialize number of circles drawn.
hold_state=ishold; num_circle=0; hold on;

% Try to get one circle up.
% We need to be careful first time to get the image handles right.
% Note that x and y for images versus plots are switched.
[x,y,state]= ginput(1); 
if (state==3)|(state==113) positions=0; return; 
else
   num_circle=1;
   positions(num_circle,1)=y; positions(num_circle,2)=x; % Save the first centre
   x_perimeter=x; y_perimeter=y;
   radius = 0; % Start circle out infinitely small.
   % Mark centre, perimeter and circle
   centre_handle=plot(positions(num_circle,2),positions(num_circle,1),'w+');
   perimeter_handle=plot(x,y,'w+');
   circle_handle=plot(x+radius*x_circle, y+radius*y_circle,'w');
   fprintf(1,'X_centre = %f, Y_centre = %f\n', positions(num_circle,1), positions(num_circle,2));  
end

%  Now iterate.
while(state~=3)&(state~=113)
   
   [x,y,state]=ginput(1); % get mouse command.
   
   if (state==2)|(state==112) % moving the perimeter
      radius = norm([positions(num_circle,2)-x, positions(num_circle,1)-y]);
      delete(perimeter_handle);
      perimeter_handle=plot(x,y,'w+');
      delete(circle_handle);
      circle_handle=plot(positions(num_circle,2)+radius*x_circle, positions(num_circle,1)+radius*y_circle,'w');
   	x_perimeter=x; y_perimeter=y;   
   end
   
   if (state==1)|(state==99) % moving the centre.
      num_circle=num_circle+1;
      positions(num_circle,:)=[y,x];
      radius = norm([x-x_perimeter,y-y_perimeter]);
      delete(centre_handle);centre_handle=plot(x,y,'w+');
      delete(circle_handle);
      circle_handle=plot(x+radius*x_circle, y+radius*y_circle,'w');
      fprintf(1,'X_centre = %f, Y_centre = %f\n', positions(num_circle,1), positions(num_circle,2));   
   end      
end

% return the image to its original shape.
delete(centre_handle); delete(perimeter_handle); delete(circle_handle);
if (hold_state==0) hold off; end
