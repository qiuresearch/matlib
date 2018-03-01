function ovi(varargin)
% OVI      run remote GVIM - similar to edit
% OVI [-n] +LINE mfile   opens mfile at line LINE in remote GVIMn

cmd='gvim';
% resolve server name
server = 'GVIM';
argc = length( varargin );
if argc > 0 & length(varargin{1}) > 1
    a1 = varargin{1};
    if sum(strmatch( '-', a1 )) & all( a1(2:end) >= '0' & a1(2:end) <= '9' )
	% let us ignore GVIM0
	na1 = sscanf( a1(2:end), '%i' );
	server = sprintf( 'GVIM%i', na1 );
	varargin(1) = [];
	argc = argc  - 1;
    end
end
opts=[ '-T builtin_gui --servername ' server ];


ropts = '--remote-silent';
files='';
for i=1:argc
    carg=varargin{i};
    if length(carg)>0 & (carg(1)=='+' | carg(1)=='-')
	ropts=[ropts ' ' carg];
    else
	%it has to be a file
	if any(carg=='*') | ~isempty( dir( carg ) )
	    files=[files carg ' '];
	else
	    wf=which(carg);
	    if isempty(wf)
		fprintf('file %s not found\n', carg);
	    else
		files=[files  wf ' '];
	    end
	end
    end
end
if isempty(files)
    % do not use any ropts, only run gvim
    ropts = '';
end
cmd=[cmd ' ' opts ' ' ropts ' ' files ' & ' ];
unix(cmd);
