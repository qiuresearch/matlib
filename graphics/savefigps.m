function ok = savefigps(hf, basename)
% --- Usage:
%
%
% --- Purpose:
%
% --- Return(s): 
%
% --- Parameter(s):
%
%
% --- Example(s):
%
% $Id: savefigps.m,v 1.3 2014/02/23 05:00:38 schowell Exp $

ok = [];
saveas(hf, [basename '.fig']);
disp(['Saving figure into FIG file: ' basename, '.fig'])
ok = [ok saveps(hf, [basename '.eps'])];
ok = mean(ok);
