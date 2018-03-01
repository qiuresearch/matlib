function iq = guinier_rod(iq)
%        iq = guinier_rod(iq)
% returns, iq(:,1).^2 VS log(q*iq(:,2))
%
if nargin < 1
   help guinier_rod
   return
end

i_nopositive = find(iq(:,2) <= 0);
if ~isempty(i_nopositive)
   iq(i_nopositive,2) = NaN;
end

% check the presence of error column
switch size(iq, 2)
   case 3
      iq(:,3) = iq(:,1)./iq(:,2).*iq(:,3);
   case 4
      iq(:,4) = iq(:,1)./iq(:,2).*iq(:,4);
   otherwise
end
      
iq(:,2) = iq(:,2) .* iq(:,1);
iq(:,1) = iq(:,1) .* iq(:,1);
iq(:,2) = log(iq(:,2));
