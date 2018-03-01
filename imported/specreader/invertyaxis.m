function invertyaxis(varargin)
% Copyright 2012, Zhang Jiang
hLine = findall(gca,'Type','line');
if isempty(hLine)
    return;
end
for iLine = 1:length(hLine)
        set(hLine(iLine),'YData',-get(hLine(iLine),'YData'));
end

updateparams;


