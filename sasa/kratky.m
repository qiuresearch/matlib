function iq = kratky(iq, mode)
%        iq = kratky(iq, mode)
% returns, iq(:,1) VS iq(:,2).iq(:,1).^2
%   
%        if (mode == 'inverse')
%             
%

if nargin < 1
   help kratky
   return
end
if ~exist('mode', 'var')
   mode = 'forward';
end

[num_rows, num_cols] = size(iq);

if strmatch(mode, 'forward')
   iq(:,2:end) = iq(:,2:end) .* iq(:,ones(num_cols-1,1)) .* iq(:, ...
                                                     ones(num_cols-1,1));
end

if strmatch(mode, 'inverse')
   iq(:,2) = iq(:,2) ./ iq(:,1) ./ iq(:,1);
   if (iq(1,1) == 0)
      iq(1,2) = 0;
   end
end

