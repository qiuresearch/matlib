function figure_format(selection, varargin)
%        figure_format(selection)
% Example: selection: 'talk', 'smallprint', 'tinyprint'

verbose = 1;
if nargin < 1
   funcname = mfilename; % or use dbstack to get its caller if needed
   eval(['help ' funcname]);
   return
end

if ~exist('selection', 'var')
   selection = 'standard';
end

switch upper(selection)
   case {upper('standard'), upper('normal')}
      % axes defaults (font applies to xy labels, ticks, and
      % legend). Note that I have yet 
      set(0, 'DefaultAxesFontSize', 15, 'DefaultAxesFontWeight', 'normal', ...
             'DefaultAxesFontName', 'Arial', 'DefaultAxesLineWidth', 1.3, ...
             'DefaultAxesXMinorTick', 'on', 'DefaultAxesYMinorTick', 'ON', ...
             'DefaultAxesBox', 'ON', 'DefaultAxesNextPlot', 'Add');
      
      % line defaults
      set(0, 'DefaultLineLineWidth', 1.4, 'DefaultLineMarkerSize', 11);
      
      % text defaults (font applies to text(), puttext, not legend);
      set(0, 'DefaultTextFontSize', 14, 'DefaultTextFontWeight', 'Normal');
  
  case {upper('presentation'), upper('talk')}
      % axes defaults (font applies to xy labels, ticks, and legend)
      set(0, 'DefaultAxesFontSize', 16, 'DefaultAxesFontWeight', 'Normal', ...
             'DefaultAxesFontName', 'Times', 'DefaultAxesLineWidth', 1.2, ...
             'DefaultAxesXMinorTick', 'on', 'DefaultAxesYMinorTick', 'ON', ...
             'DefaultAxesBox', 'ON', 'DefaultAxesNextPlot', 'Add');
      
      % line defaults
      set(0, 'DefaultLineLineWidth', 1.55, 'DefaultLineMarkerSize', 14);
      
      % text defaults (font applies to text(), puttext, not legend);
      set(0, 'DefaultTextFontSize', 18, 'DefaultTextFontWeight', ...
             'normal','DefaultAxesFontName', 'Times');
  
  case {upper('publication'), upper('article'), upper('paper')}
      % axes defaults (font applies to xy labels, ticks, and legend)
      set(0, 'DefaultAxesFontSize', 16, 'DefaultAxesFontWeight', 'Normal', ...
             'DefaultAxesFontName', 'Times', 'DefaultAxesLineWidth', 1.2, ...
             'DefaultAxesXMinorTick', 'on', 'DefaultAxesYMinorTick', 'ON', ...
             'DefaultAxesBox', 'ON', 'DefaultAxesNextPlot', 'Add');
      
      % line defaults
      set(0, 'DefaultLineLineWidth', 1.55, 'DefaultLineMarkerSize', 14);
      
      % text defaults (font applies to text(), puttext, not legend);
      set(0, 'DefaultTextFontSize', 18, 'DefaultTextFontWeight', ...
             'normal','DefaultAxesFontName', 'Times');
     
   case {upper('smallprint'), upper('small')}
      % axes defaults
      set(0, 'DefaultAxesFontSize', 11, 'DefaultAxesFontWeight', 'Normal', ...
             'DefaultAxesFontName', 'Times', 'DefaultAxesLineWidth', 1, ...
             'DefaultAxesXMinorTick', 'on', 'DefaultAxesYMinorTick', 'ON', ...
             'DefaultAxesBox', 'ON', 'DefaultAxesNextPlot', 'Add');
      
      % line defaults
      set(0, 'DefaultLineLineWidth', 1.2, 'DefaultLineMarkerSize', 7);
      
      % text defaults
      set(0, 'DefaultTextFontSize', 11, 'DefaultTextFontWeight', 'Normal', ...
             'DefaultAxesFontName', 'Times');
      
   case {upper('tinyprint'), upper('tiny')}
     % axes defaults
     set(0,  'DefaultAxesFontSize', 9, 'DefaultAxesFontWeight', 'Normal', ...
            'DefaultAxesFontName', 'Times', 'DefaultAxesLineWidth', 1, ...
            'DefaultAxesXMinorTick', 'on', 'DefaultAxesYMinorTick', 'ON', ...
            'DefaultAxesBox', 'ON', 'DefaultAxesNextPlot', 'Add');
     
     % line defaults
     set(0, 'DefaultLineLineWidth', 1, 'DefaultLineMarkerSize', 4);
     
     % text defaults
     set(0, 'DefaultTextFontSize', 9, 'DefaultTextFontWeight', 'Normal', ...
            'DefaultAxesFontName', 'Times');
   
   otherwise
      disp('format option not supported yet, no changes made!')
end