function s2clip(a)
%S2CLIP(A)  copy matrix or string A to the clipboard
%
%See also S2DUMP, DUMP2M, DUMP2T

fn=s2dump(a);
cygsh = 'c:\cygwin\bin\sh.exe';
if exist(cygsh, 'file')
    dos(['start /MIN ' cygsh ' -c "cat ' fn ' > /dev/clipboard"']);
elseif strcmp(getenv('OS'), 'Windows_NT')
    dos(['start /MIN /B gvim.exe -R -i NONE -u NONE -c "%y*|q" ' fn]);
else
    dos(['start /m gvim.exe -R -i NONE -u NONE -c "%y*|q" ' fn]);
end
