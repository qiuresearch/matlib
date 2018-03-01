function out=dump2t(clip)
%DUMP2T       returns matrix from the dump file
%DUMP2T c[lip]  first overwrites dump file with the clipboard
%
%See also DUMP2M, S2DUMP, S2CLIP

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
out = textread(fn,'%s','delimiter','\n','whitespace','');
