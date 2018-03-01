function ha = axes_zoom(varargin)
%        ha = axes_zoom(varargin)
%   varargin - 'ha'
%       'twinsize', 'queensize', 'kingsize', 
%    or 'position' matlab default is: [0.25, 2.5, 8, 6]
   
position = [0.15, 0.15, 0.7, 0.7];
twinsize = 0;
queensize = 1;
kingsize = 0;
parse_varargin(varargin);
if (twinsize == 1);
   position = [0.2, 0.2, 0.6, 0.6];
end
if (queensize == 1);
   position = [0.15, 0.15, 0.7, 0.7];
end
if (kingsize == 1);
   position = [0.05,0.05,0.9, 0.9];
end

if exist('ha', 'var') && ishandle(ha(1))
   set(ha, 'Position', position);
else
   set(gca, 'Position', position);
end
