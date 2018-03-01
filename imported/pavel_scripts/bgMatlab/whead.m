function whead(File,Data,Header,Fmt)
%WHEAD       save data in ASCII format with header
%  WHEAD(FILE, DATA, HEADER)  writes data from matrix DATA to FILE
%    with preciding HEADER, data are <tab> delimited
%  WHEAD(FID, DATA, HEADER)  writes to a file specified by integer
%    file identifier FID (obtained by FOPEN). FID remains open.
%  WHEAD(FILE, DATA, HEADER, PREC)  uses %.PRECg format
%  WHEAD(FILE, DATA, HEADER, FMT)   uses format string FMT
%    If DATA is a string starting with '&', it would be
%    evaluated in the caller environment, e.g.,  WHEAD FILE &DATA

%  1999 by Pavol
%  $Id: whead.m 26 2007-02-27 22:45:38Z juhas $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Defaults:
header = [];
data = Data;
c_prec = 10;
c_ofs  = ' ';

% Data argument
if isstr(Data) & size(Data,1) == 1 & Data(1) == '&'
    data=evalin('caller', Data(2:end));
end
if size(data,1)==1
    data=data';
end
cols=size(data,2);

% Header argument
if nargin > 2
    header = Header;
end
%convert CRLF to CR
i=findstr(header, sprintf('\r\n'));
header(i)=[];
if ~isempty(header) & header(end) ~= sprintf('\n')
    header(end+1) = sprintf('\n');
end

% Fmt argument
fmt = '';
if nargin > 3
    if isnumeric(Fmt) & min(size(Fmt)) == 1
	c_prec = Fmt(1);
    elseif isstr(Fmt)
	fmt = Fmt;
    else
	error('Invalid value of FMT');
    end
end

if isempty(fmt)
    % use %.C_PRECg format
    fmt1 = sprintf( '%%.%ig', c_prec );
    for i=1:cols-1
	fmt=[fmt, fmt1, c_ofs];
    end
    fmt=[fmt, fmt1, '\n'];
    if cols == 0
        fmt = '';
    end
else
    iperc = find( fmt == '%' );
    iperc(diff(iperc) == 1) = [];
    iperc = length(iperc);
    if iperc ~= cols
	error(sprintf('wrong number of format items: %i, cols=%i',iperc,cols))
    end
end

if isnumeric(File)
    fid=File;
else
    fid=fopen(File, 'w');
end

fwrite(fid, header);
fprintf(fid, fmt, data');
if ~isnumeric(File)
    fclose(fid);
end
