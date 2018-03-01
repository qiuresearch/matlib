function hf = figure_fullsize(hf)
%        hf = figure_fullsize(hf)

   position_monitors = get(0, 'MonitorPositions');
   [num_monitors, num_dimensions] = size(position_monitors);
   
   if (num_monitors > 1)
      global current_monitor_xqiu
      if isempty(current_monitor_xqiu)
         current_monitor_xqiu = 1;
      else
         current_monitor_xqiu = current_monitor_xqiu+1;
         current_monitor_xqiu = mod(current_monitor_xqiu-1, num_monitors)+1;
      end
      scrsz = position_monitors(current_monitor_xqiu, :);
   else
      scrsz = get(0,'ScreenSize');
   end
   
   scrsz(3:4) = min(scrsz(3:4))*0.9;
   % set the figure size
   if exist('hf', 'var') && ishandle(hf)
      set(hf, 'Position', scrsz);
   else
      hf = figure('Position', scrsz);
   end
