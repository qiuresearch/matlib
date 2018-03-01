function [hf, ha, hl] = gethandles()
% --- Usage:
%        [hf, ha, hl] = gethandles()
% --- Purpose:
%        get the handles of figures, axis, and lines to arrays "hf",
%        "ha", and 'hl'.
% --- Parameter(s):
%
% --- Return(s):
%        results -
%
% --- Example(s):
%
% $Id: gethandles.m,v 1.2 2013/02/28 16:52:10 schowell Exp $
%

hf = get(0, 'child');
% there should be better ways to delselect those legend axis
ha = findobj(hf, 'Type', 'axes', 'tag', []);
hl = [0];
for i_axis =1:length(ha)
  hl = [hl; flipud(findobj(ha(i_axis), 'Type', 'line'))];
end
hl = hl(2:end);
