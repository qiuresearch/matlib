function ok = postfl_save(postfl, filename)
% --- Usage:
%        postfl = postfl_save(fem)
% --- Purpose:
%        save the postfl.sldata, mtdata into a matfile
% --- Parameter(s):
%
% --- Return(s):
%        results -
%
% --- Example(s):
%
% $Id: postfl_save.m,v 1.1.1.1 2007-09-19 04:45:38 xqiu Exp $
%

disp(['POSTFL_SAVE::saving the postfl structure to ', filename])

if nargin < 1
   return
end

postfl = rmfield(postfl, {'fem', 'x', 'y', 'z', 'xsection','u', ...
                    'v', 'w', 'c'});
save(filename,'postfl');
ok=1;
return
