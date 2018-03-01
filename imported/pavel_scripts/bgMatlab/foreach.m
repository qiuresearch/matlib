function foreach(filevar, name, cmds)
%FOREACH     repeat commands for a list of files
%  FOREACH VAR FILELIST COMMANDS
%
%  $VAR tries to quote the VAR string in COMMANDS when necessary
%  $$VAR never quotes
%  modifiers:  #VAR 	index of the file
%              $VAR:r 	file without the extension
%  FILELIST can be a shell pattern, e.g., *.dat
%    if FILELIST starts with &, it is replaced with the value of variable
%    FILELIST in the caller workspace
%
%  Examples:
%    foreach file &filelist 'disp $file'
%    foreach file *.m 'help $file'
%    foreach file *.m 'edit $file'

%  $Id: foreach.m 26 2007-02-27 22:45:38Z juhas $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%if these characters come before $VAR, $VAR is quoted
quotecharspre=',([''=';
if nargin<2
    error('foreach needs at least 2 arguments')
end
if ischar(name) & name(1)=='&'
    name=evalin('caller', name(2:end));
end
if ischar(name) & any(name=='?' | name=='*')
    namedir=fileparts(name);
    f=dir(name);
    fnames=strvcat(f.name);
    [ig, i]=sortrows(lower(fnames));
    fnames=fnames(i,:);
    if ~isempty(namedir)
	if namedir(end)~='\'
	    namedir(end+1)='\';
	end
	fnames=[namedir(ones(length(f),1),:) fnames];
    end
else
    fnames=char(name);
end
nf=size(fnames,1);
if nargin<3
    if nf==0
	disp('no match, nothing to do...')
	return;
    end
    fprintf('`fend'' to execute, `!!'' to execute previous, `fc'' to edit\n')
    cmds={}; cmdrows=0; dosave=1;
    s=deblank(input('foreach> ','s'));
    while ~strcmp(s,'fend')
	switch s
	case 'fc',
	    cmds=fcedit(cmds);
	    cmdrows=size(cmds,1);
	    dosave=0;
	    break
	case '!!'
	    cmds=fcedit(cmds,1);
	    cmdrows=size(cmds,1);
	    dosave=0;
	    break
	end
	cmdrows=cmdrows+1;
	cmds{cmdrows}=s;
	s=deblank(input('foreach> ','s'));
    end
    if dosave & cmdrows>0
	fcbuf=[tempdir 'foreach.cmd.tmp'];
	fou=fopen(fcbuf, 'w');
	for i=1:cmdrows
	    fprintf(fou, '%s\n', cmds{i});
	end
	fclose(fou);
    end
else
    if isequal(cmds, '!!')
	cmds=fcedit({},1);
    end
    cmdrows=size(cmds,1);
end
cmds=char(cmds);

spacetab = sprintf(' \t');
for n=1:nf
    s_f=deblank(fnames(n,:));
    [s_path, s_fname, s_ext,s_version] = fileparts(s_f);
    s_r = fullfile(s_path, s_fname);
    s_n=sprintf('%i',n);
    try,
	cmds1='';
	nl = sprintf('\n');
	for m=1:cmdrows
	    m_cmd=cmds(m,:);
	    m_cmd=strrep(m_cmd, ['#' filevar ], s_n);
	    m_cmd=strrep(m_cmd, ['$$' filevar ':r'], s_r);
	    m_cmd=strrep(m_cmd, ['$' filevar ':r'], [ '''' s_r '''' ]);
	    m_cmd=strrep(m_cmd, ['$$' filevar], s_f);
	    m_cmd=strrep(m_cmd, ['$' filevar], [ '''' s_f '''' ] );
	    % ca=findstr(m_cmd, ['$' filevar]);
	    % vl=1+length(filevar);
	    % for ci=1:length(ca)
	    %     sp=ca(ci)-1;
	    %     sc=m_cmd(max(1,sp));
	    %     while sp>1 & any(sc==spacetab)
	    %         sp=sp-1;
	    %         sc=m_cmd(sp);
	    %     end
	    %     if any(sc==quotecharspre)
	    %         %quote the string
	    %         m_cmd=[m_cmd(1:ca(ci)-1) '''' m_cmd(ca(ci)+(0:vl-1)) ,...
	    %     	'''' m_cmd(ca(ci)+vl:end)];
	    %         ca(ci+1:end)=ca(ci+1:end)+2;
	    %     end
	    % end
	    % m_cmd=strrep(m_cmd, ['$' filevar], s_f);
	    cmds1 = [cmds1 m_cmd nl];
	    %fprintf('cmd = %s\n', m_cmd);
	end
	evalin('caller', cmds1);
    catch,
	fprintf('---\n%s\n  error in "%s"\n  %s\n---\n', s_f, m_cmd, lasterr);
    end
end

function cmd1=fcedit(cmd0, bang)
if nargin<2
    bang=0;
end
fcbuf=[tempdir 'foreach.cmd.tmp'];
s0=char(cmd0);
nr=size(s0,1);
fh='';
cr=sprintf('\r');
if nr>0
    for i=1:nr
	fh=[fh sprintf('%s\n', deblank(s0(i,:)))];
    end
    fb='';
    fin=fopen(fcbuf, 'r');
    if fin~=-1
	fb=char(fread(fin))';
	fclose(fin);
    end
    fb=[fh fb];
    fb(fb==cr)='';
    fou=fopen(fcbuf, 'w');
    fwrite(fou, fb);
    fclose(fou);
end
if ~bang
    rc=fileparts(which(mfilename));
    rc(rc=='\')='/'; rc=[rc '/fcvimrc.vim'];
    eval(sprintf('!gvim --noplugin -u %s +%i "%s"', rc, nr+1, fcbuf));
    cmd1 = textread(fcbuf,'%s','delimiter','\n','whitespace','');
    cmd1 = char(cmd1);
else
    cmd1 = textread(fcbuf,'%s','delimiter','\n','whitespace','');
    o = strcmp(cmd1, 'fend');
    if any(o)
	out = find(o);
	out = out(1):length(o);
	cmd1(o) = [];
    end
    cmd1 = char(cmd1);
    disp(cmd1)
    fprintf('');
end
