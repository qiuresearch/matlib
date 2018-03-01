function listchi(pat)
% LISTCHI(PAT)      list indices of chi files matching shell pattern PAT

if nargin == 0
    pat = '*.chi';
end

allscans = lsc(pat, 't');
for i = 1:length(allscans)
    fprintf('%3i %s\n', i, allscans{i});
end
