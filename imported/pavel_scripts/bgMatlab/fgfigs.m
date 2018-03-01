function fgfigs(hf)
%FGFIGS      raise all or specified figure windows
%  FGFIGS(HF)  raise only the figures with handles in HF

%  $Id: fgfigs.m 26 2007-02-27 22:45:38Z juhas $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin == 0
    hf = fliplr(get(0, 'Children'));
else
    hf = hf(:)';
end

for f = hf
    figure(f)
end
