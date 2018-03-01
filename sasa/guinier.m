function iq = guinier(iq)
%        iq = guinier(iq)
% returns log(I(Q) vs Q^2: [iq(:,1).^2, log(iq(:,2))]
%
verbose = 1;
if nargin < 1
    help guinier
    return
end

iq(:,1) = iq(:,1) .* iq(:,1);  %Square the first column of iq
i_nopositive = find(iq(:,2) <= 0);
if ~isempty(i_nopositive)
    showinfo([num2str(length(i_nopositive)), ' zero or negative values found!']);
    iq(i_nopositive,2) = NaN;
end
iq(:,2) = log(iq(:,2));
