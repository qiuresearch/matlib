function [x,y,z,o,m] = rrstr(file);
%RRSTR      reads atom positions from PDFFIT RSTR file
%   S = RRSTR(file)   reads all data to structure S
%   [X,Y,Z,O,M] = RRSTR(file)   reads data to vectors

%   2003 by Pavol

if exist(file, 'file') ~= 2
    error('File not found.')
end

fid=fopen(file,'r');
desc = '';
head = '';
% c_nl = sprintf( '\n' );
while ~feof(fid)
    s = fgets(fid); 
    head = [ head s ];
    s1 = sscanf( s, '%s', 1 );
    switch (s1)
    case 'title',
	desc = s(6:end);
	j = find( desc ~= ' ' );
	desc = deblank( desc(j(1):end) );
    case 'cell',
	abcABG = sscanf(s, 'cell %f,%f,%f,%f,%f,%f', [1, 6] );
    case 'ncell',
	ncell = sscanf(s, 'ncell %f,%f,%f,%f', [1, 4] );
    case 'atoms',
	break;
    end
end

na = ncell(4);
[x, y, z, o, m] = deal( zeros( na, 1 ) );
[sx, sy, sz, so] = deal( x );
[u, su] = deal( zeros( na, 3, 3 ) );
at = {};

for i = 1:na
    a = upper( fscanf( fid, '%s', 1 ) );
    mi = find( strcmp( at, a ) );
    if isempty( mi )
	mi = max(m) + 1;
	at{end+1,1} = a;
    end
    m(i) = mi;
    d = fscanf( fid, '%f' );
    d = num2cell( d );
    [ ...
      x(i), y(i), z(i), o(i), ...
      sx(i), sy(i), sz(i), so(i), ...
      u(i,1,1), u(i,2,2), u(i,3,3), ...
      su(i,1,1), su(i,2,2), su(i,3,3), ...
      u(i,1,2), u(i,1,3), u(i,2,3), ...
      su(i,1,2), su(i,1,3), su(i,2,3), ...
    ] = deal( d{:} );
end
fclose(fid);

if nargout<3
    x = struct( 'x', x, 'y', y, 'z', z, 'o', o, 'm', m, 'at', { at }, ...
	'u', u, 'sx', sx, 'sy', sy, 'sz', sz, 'so', so, 'su', su, ...
	'desc', desc, 'fname', file, 'head', head );
end
