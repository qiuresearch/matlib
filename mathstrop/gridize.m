function [outarr, xoutarr, youtarr] = gridize(inarr, x_grid, varargin)
% here inarr is a non-uniform array, it is expected to be an nx1, or
% 1xn, or mxn array. In case of mxn, first column x. 

arr_size = size(inarr);
if (length(arr_size) > 2)
   disp('ERROR:: maximum dimension is 2!!!')
   return
end
if (arr_size(1) == 1) || (arr_size(2) ==1)
   xdata = inarr;
   num_interps = 0;
else
   xdata = inarr(:,1);
   num_interps = arr_size(2)-1;
end
xdata = reshape(xdata, 1, length(xdata)); % adjust to 1xn

% whether to overshoot when making turns
overshoot=0;
x_start = xdata(1); % note that x_start and x_end work differently
x_end = xdata(end); % x_end usually is used to extend the data set
                    % to the end
% x_start is used to cut the data set from the beginning
parse_varargin(varargin);

if (x_end ~= xdata(end))
   xdata = [xdata, x_end];
end

% find where turns are and the sign before the turn
diff = [1,xdata(2:end) - xdata(1:end-1)];
%diff(find(diff ==0)) = 1;
diff = sign(diff);
i_turns = find((diff(3:end) - diff(2:end-1)) ~= 0) + 2;
i_turns = [i_turns, length(xdata)+1];
sign_turns = sign(xdata(i_turns-1) - xdata(i_turns-2));

% add first memeber to be the second elements
i_turns = [2,i_turns];
sign_turns = [1,sign_turns];
% combine the new array
xoutarr(1) = x_start; % xoutarr is a 1xn array
for i=2:length(i_turns)
   num_points=ceil(abs((xdata(i_turns(i)-1)-xoutarr(end))/ x_grid))+overshoot;
   x_new =  xoutarr(end)+(0:num_points-1)*x_grid* sign_turns(i);
   y_new = zeros(length(x_new), num_interps);
   for k=1:num_interps
      if (inarr(i_turns(i-1),1) == inarr(i_turns(i)-1,1)) 
         % if equal, should be only two elements, just take the average
         y_new(:,k) = (inarr(i_turns(i-1)-1,k+1)+inarr(i_turns(i)- 1,k+1))/2;
      else
         y_new(:,k) = interp1(inarr(i_turns(i-1)-1:i_turns(i)-1,1), ...
                              inarr(i_turns(i-1)-1:i_turns(i)-1,k+1), ...
                              x_new, 'pchip', inarr(i_turns(i)-1,k+ 1));
      end
   end
   xoutarr=[xoutarr, x_new(2:end)];
   if (i==2)
      youtarr = y_new;
   else
      youtarr = [youtarr;y_new(2:end,:)];
   end
end

% the return variable
outarr = [xoutarr',youtarr];
