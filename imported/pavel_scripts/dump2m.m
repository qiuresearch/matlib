function out=dump2m(clip)
%DUMP2M       returns matrix from the dump file
%DUMP2M c[lip]  first overwrites dump file with the clipboard
%
%See also DUMP2T, S2DUMP, S2CLIP

if nargin > 0 & strmatch(clip, 'clipboard')
    clip=1;
else
    clip=0;
end

fn=s2dump;
if clip
    cygsh = 'c:\cygwin\bin\sh.exe';
    if exist(cygsh, 'file')
	dos([cygsh ' -c "cat > ' fn ' < /dev/clipboard"']);
    elseif strcmp(getenv('OS'), 'Windows_NT')
	dos(['start /WAIT /MIN gvim.exe -i NONE -u NONE -c "%d|0put *|x!" ' fn]);
    else
	dos(['gvim.exe -i NONE -u NONE -c "%d|0put *|x!" ' fn]);
    end
end
out = rhead(fn);
