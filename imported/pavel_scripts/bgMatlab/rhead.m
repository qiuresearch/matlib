function [data, header, name] = rhead(file, n);
%RHEAD       read data from ASCII file with header
%  [DATA, HEADER] = RHEAD(FILE)  read data from FILE to matrix DATA
%  after skipping all lines, that do not start with number. These
%  lines are returned in HEADER.
%
%  [DATA, HEADER] = RHEAD(FILE, N)  assumes HEADER has at least N lines
%  use [D, HEADER] = RHEAD(FILE, INF)  to read all the file into HEADER
%  [DATA, HEADER, FILE] = RHEAD([N])  uses a dialog box to retrieve FILE
%
%  [DATA, HEADER] = RHEAD(FILE, RE)  data start after first occurence of
%  regular expression pattern RE.  Syntax of RE is [line]/re[/].
%
%  [DATA, HEADER, FILE] = RHEAD(FID, N)  reads from a file specified by
%  integer file identifier FID (obtained by FOPEN). FID remains open.
%  Example:
%    fid = fopen('dataset.dat');    % file with several data sets
%    [data, head] = rhead(fid, 0); i = 1;
%    while ~isempty(data)
%        eval(['data' num2str(i) '=data;']);
%        eval(['head' num2str(i) '=head;']);
%        [data, head] = rhead(fid, 0);
%        i = i+1;
%    end
%    fclose(fid);

%  Pavol
%  $Id: rhead.m 26 2007-02-27 22:45:38Z juhas $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%  Default n:
ndef = 0;

if nargin == 0
    file = [];
    n = ndef;
elseif nargin == 1
    if isstr(file)
       n = ndef;
    else
       n = file;
       file = [];
    end
end

if isempty(file)
    [filename, path] = uigetfile( '*.*', 'Load ASCII Data' ) ;
    file = [path , filename];
    if ~isstr(file)
       return;
    end
end

if isstr(file)
    file= deblank( fliplr(deblank(fliplr ((file(:)).') ) ) );
    if exist(file)~=2
       error('File not found.')
    end
    name = file;
    fid = fopen(file, 'rt');
else
    fid = file;
    name = fopen(fid);
    if isempty(name)
        error('Invalid FID.')
    end
end

header = ''; data = [];
if n==inf
    header=char(fread(fid, 'char')');
% n is minimum number of header lines
elseif isnumeric(n)
    for i=1:n
	s=fgets(fid);
	if s~=-1
	    header=[header s];
	else
	    break;
	end
    end
% n is regular expression
elseif isstr(n)
    [line,cnt,errmsg,nextidx] = sscanf(n, '%i', 1);
    if nextidx <= length(n) & n(nextidx) ~= '/'
        error('invalid RE format')
    end
    pat = n(nextidx+1:end);
    if ~isempty(pat) & pat(end) == '/'
        pat(end) = '';
    end
    if cnt == 0
        line = 0;
    end
    % read full file to header
    header=char(fread(fid, 'char')');
    pdata = 0;
    % skip lines
    inl = find(header == sprintf('\n'));
    if 0 < line & line <= length(inl)
        pdata = inl(line);
    end
    % re search
    if ~isempty(pat)
        i = regexp(header(pdata+1:end), pat, 'once');
        if isempty(i)
            pdata = length(header);
        else
            j = [inl(inl > pdata+i), length(header)];
            pdata = j(1);
        end
    end
    % move to the correct position
    header = header(1:pdata);
    fseek(fid, pdata, 'bof');
end

ncol=0;
while ncol==0 & ~feof(fid)
    s = fgets(fid);
    if ~isstr(s)
       s='';
    end
    [data, ncol]=sscanf(s, '%f', [1, Inf]);
    if ncol==0
       header=[header s];
    end
end
data = [double(data) ; (fscanf(fid, '%f', [ncol, Inf]) ).'];

if isstr(file)
    fclose(fid);
end
