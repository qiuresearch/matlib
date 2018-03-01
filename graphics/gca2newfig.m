function [ha_new, hf] = gca2newfig(varargin)
% --- Usage:
%        [ha, hf] = gca2newfig(varargin)
%
% --- Purpose:
%        copy a axes (default: gca) to a figure (default: new figure).
% 
% --- Return(s): 
%
% --- Parameter(s):
%        varargin   - 'ha', 'hf', 'fullsize', 'nolegend'
%
% --- Example(s):
%
% $Id: gca2newfig.m,v 1.1 2012/07/05 03:08:57 xqiu Exp $
%

verbose = 1;
fullsize = 1;
nolegend = 0;
parse_varargin(varargin);

if ~exist('ha', 'var')
   ha = gca;
end

if ~exist('hf', 'var')
   hf = figure;
end

for i=1:length(ha)
   hchildren = get(get(ha(i), 'parent'), 'Children');
   iha = find(hchildren == ha(i)); 
   if (iha > 1) && strcmpi(get(hchildren(iha-1),'tag'), 'legend')
      hlegend = hchildren(iha-1);
   else
      hlegend = [];
   end

   num_children = length(get(hf, 'children'));
   ha_new(i)=copyobj(ha(i), hf);
   if ((length(get(hf, 'children')) - num_children) == 1) && ...
          ~isempty(hlegend) && (nolegend == 0);
      copyobj(hlegend, hf);
   end
   if (fullsize == 1);
      set(ha_new(i), 'Position', [0.1,0.1,0.8,0.8]);
   end
end
