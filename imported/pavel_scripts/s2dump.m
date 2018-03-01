function out=s2dump(a)
%S2DUMP(A)  save variable A to c:/tmp/matlabdump.tmp
%
%See also S2CLIP, DUMP2M, DUMP2T

OFMT = '%13.6g';
OFS  = '\t';
user = getenv('USER');
if isempty(user)
    user = getenv('USERNAME');
end
if isunix
    fn=strcat('/tmp/', 'matlabdump-', user, '.tmp');
elseif strcmp(computer, 'PCWIN')
    fn=strcat('c:/tmp/', 'matlabdump-', user, '.tmp');
end
if nargin==0
    out=fn;
    return;
end

if isstr(a) & length(a)<20 & evalin('caller',['exist(''' a ''',''var'')'] )
    b=evalin('caller', a);
    a=b;
end

if ~isstr(a) & ~iscellstr(a) & ~isnumeric(a)
    whos a
    error('cannot save this datatype')
end

fid=fopen(fn, 'w');
if isstr(a)
    fwrite(fid, a);
elseif iscellstr(a)
    for i=1:length(a)
	fprintf(fid, '%s\n', a{i});
    end
elseif isnumeric(a)
    % original:
    % save(fn, 'a', '-ascii', '-tabs')
    % new: hacked from whead
    if size(a,1)==1
	a=a';
    end
    c=size(a,2);
    fmt='';
    for i=1:c-1
	fmt=[fmt OFMT OFS ];
    end
    fmt=[fmt OFMT '\n'];
    fprintf(fid, fmt, double(real(a')));
end
fclose(fid);

if nargout>0
    out=fn;
end
