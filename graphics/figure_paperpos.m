function hf = figure_paperpos(hf, varargin);
%        hf = figure_paperpos(hf, varargin);
%   varargin
%       'twinsize', 'queensize', 'kingsize', 
%    or 'paperposition' matlab default is: [0.25, 2.5, 8, 6]
   
paperposition = [0.25,1,8,9];
twinsize = 0;
queensize = 1;
kingsize = 0;
parse_varargin(varargin);
if (twinsize == 1);
   paperposition = [0.25, 2.5, 8, 6];
end
if (queensize == 1);
   paperposition = [0.25, 1, 8, 9];
end
if (kingsize == 1);
   paperposition = [0,0,8.5,11];
end

if exist('hf', 'var') && ishandle(hf)
   set(hf, 'PaperPosition', paperposition);
else
   hf = figure('PaperPosition', paperposition);
end
