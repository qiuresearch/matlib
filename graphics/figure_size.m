function hf = figure_size(hf, newsize);
%        hf = figure_size(hf, newsize);
%   parameters
%       newsize: [width, height] in inches (matlab default [8, 6])
%                or
%                '
%                'qeen' (0.25in margin)
%                'king' (0in margin)

fullsize=[8.5,11];

if ischar(newsize)
    switch newsize
      case {'crib', 'cribsize'}
        newsize = [4,3];
      case {'twin', 'twinsize'}
        newsize = [4,6];
      case {'full', 'fullsize'}
        newsize = [8,6];
      case {'queen', 'queensize'}
        newsize = [8,10.5];
      case {'king', 'kingsize'}
        newsize = [8.5,11];
      otherwise
        newsize = [8,6];
    end
end

% equal margins on opposing sides
paperposition = [[fullsize-newsize]/2, newsize];
if exist('hf', 'var') && ishandle(hf)
   set(hf, 'PaperPosition', paperposition);
else
   hf = figure('PaperPosition', paperposition);
end

return
% 
% % Set the default Size for display
% defpos = get(0,'defaultFigurePosition');
% set(0,'defaultFigurePosition', [10 10 width*100, height*100]);
% 
% % Set the defaults for saving/printing to a file
% set(0,'defaultFigureInvertHardcopy','on'); % This is the default anyway
% set(0,'defaultFigurePaperUnits','inches'); % This is the default anyway
% defsize = get(gcf, 'PaperSize');
% left = (defsize(1)- width)/2;
% bottom = (defsize(2)- height)/2;
% defsize = [left, bottom, width, height];
% set(0, 'defaultFigurePaperPosition', defsize);
