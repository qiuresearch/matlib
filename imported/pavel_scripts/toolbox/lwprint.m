function lwprint(varargin)
%LWPRINT   same as PRINT, just prints to Apple Laser Writer at 304

%DEV - printer device, CMD - printing command
DEV='-dps2';
switch whichpc,
case {'COMPAQ315', 'DELL332', 'DELL325', 'DELL325B', 'GATEWAY325', 'PJHP'}
    CMD='COPY /B %s LPT2: > NUL';
case 'asturias',
    CMD='lpr -r -P apple304 %s'
otherwise 
    error('LWPRINT not defined for this computer');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pcmd=['print ' DEV];
isfilearg=0;
for i=1:nargin
    cur_arg = varargin{i};
    pcmd=[pcmd ' ' cur_arg];
    if ~isempty(cur_arg) & isstr(cur_arg) & cur_arg(1) ~= '-'
	isfilearg=1;
    elseif isnumeric(cur_arg)
	cur_arg=cur_arg(1);
	pcmd=[pcmd sprintf(' -f%.0f', cur_arg)];
    end
end
if isfilearg
    evalin('caller', pcmd);
else
    psname=[tempname '.ps'];
    pcmd=[pcmd ' ' psname];
    evalin('caller', pcmd);
    cmd=sprintf(CMD, psname);
    if ispc
	curdir=cd;
	if curdir(1:2)=='\\'; cd c:; end
	dos(cmd);
	if curdir(1:2)=='\\'; cd(curdir); end
	delete(psname);
    else
	unix(cmd);
    end
end
