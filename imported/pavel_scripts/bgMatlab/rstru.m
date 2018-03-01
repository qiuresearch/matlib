function struData = rstru(file)
%RSTRU       read PDFFit structure file
%  S = RSTRU(FILE)  read data from FILE to structure variable S with
%  following fields
%    title, scale, sharp, spcgr, cell, dcell, ncell
%    abc        [a;b;c] matrix of unit cell vectors
%    atom       cell array of element symbols
%    x, sigx    fractional coordinate x with STD
%    y, sigy    fractional coordinate y with STD
%    z, sigz    fractional coordinate z with STD
%    o, sigo    occupancies with STD
%    U, sigU    Nx3x3 array of temperature factors
%    r, sigr    Nx3 matrix of cartesian coordinates
%    desc       same as title
%    fname      name of the original file
%    head       ascii header

%  $Id: rstru.m 26 2007-02-27 22:45:38Z juhas $

if exist(file, 'file') ~= 2
    error('File not found.')
end

% read header info
fid=fopen(file,'r');
desc = '';
head = '';
while ~feof(fid)
    line = fgets(fid);
    head = [ head, line ];
    [item,ignore,ignore,nextindex] = sscanf( line, '%s', 1 );
    values = line(nextindex:end);
    switch (item)
    case 'title',
        d_title = strtrim(values);
    case 'scale',
        d_scale = sscanf(values, 'scale %f', 1);
    case 'sharp',
        line(line == ',') = ' ';
        d_sharp = sscanf(line, 'sharp %f %f %f', [1, 3]);
    case 'spcgr',
        d_spcgr = strtrim( line(6:end) );
    case 'cell',
        line(line == ',') = ' ';
        d_cell = sscanf(line, 'cell %f %f %f %f %f %f', [1, 6] );
    case 'dcell',
        line(line == ',') = ' ';
        d_dcell = sscanf(line, 'dcell %f %f %f %f %f %f', [1, 6] );
    case 'ncell',
        line(line == ',') = ' ';
        d_ncell = sscanf(line, 'ncell %f %f %f %f', [1, 4] );
    case 'atoms',
        break;
    end
end
if feof(fid)
    error('could not find "atoms" line')
end

% read atom data
N = d_ncell(4);
[d_x, d_sigx, d_y, d_sigy, d_z, d_sigz, d_o, d_sigo] = deal( zeros(N, 1) );
[d_U, d_sigU] = deal( zeros(3, 3, N) );
[d_r, d_sigr] = deal( zeros(3, N) );
d_atom = {};

for i = 1:N
    a = upper( fscanf( fid, '%s', 1 ) );
    d_atom{i} = a;
    d = fscanf( fid, '%f', 20);
    d = num2cell( d );
    [ ...
      d_x(i), d_y(i), d_z(i), d_o(i), ...
      d_sigx(i), d_sigy(i), d_sigz(i), d_sigo(i), ...
      d_U(1,1,i), d_U(2,2,i), d_U(3,3,i), ...
      d_sigU(1,1,i), d_sigU(2,2,i), d_sigU(3,3,i), ...
      d_U(1,2,i), d_U(1,3,i), d_U(2,3,i), ...
      d_sigU(1,2,i), d_sigU(1,3,i), d_sigU(2,3,i), ...
    ] = deal( d{:} );
    d_U(2,1,i) = d_U(2,1,i);
    d_U(3,1,i) = d_U(1,3,i);
    d_U(3,2,i) = d_U(2,3,i);
    d_sigU(2,1,i) = d_sigU(2,1,i);
    d_sigU(3,1,i) = d_sigU(1,3,i);
    d_sigU(3,2,i) = d_sigU(2,3,i);
end
fclose(fid);

% calculate fundamental lattice vectors
alpha = d_cell(4); beta = d_cell(5); gamma = d_cell(6);
uc_i = [ 1          ,  0                                               ,  0 ];
uc_j = [ cosd(gamma),  sind(gamma)                                     ,  0 ];
uc_k = [ cosd(beta) ,  (cosd(alpha)-cosd(beta)*cosd(gamma))/sind(gamma),  0 ];
uc_k(3) = sqrt(1.0 - uc_k*uc_k');
d_abc = [ uc_i*d_cell(1);  uc_j*d_cell(2);  uc_k*d_cell(3) ];

d_r = [d_x, d_y, d_z] * d_abc;
d_sigr = [d_sigx, d_sigy, d_sigz] * d_abc;

struData = struct(      ...
    'title', d_title,   ...
    'scale', d_scale,   ...
    'sharp', d_spcgr,   ...
    'cell',  d_cell,    ...
    'dcell', d_dcell,   ...
    'ncell', d_ncell,   ...
    'abc',   d_abc,   ...
    'atom',  {d_atom},  ...
    'x',     d_x,       'sigx', d_sigx, ...
    'y',     d_y,       'sigy', d_sigy, ...
    'z',     d_z,       'sigz', d_sigz, ...
    'o',     d_o,       'sigo', d_sigo, ...
    'U',     d_U,       'sigU', d_sigU, ...
    'r',     d_r,       'sigr', d_sigr, ...
    'desc',  d_title,   ...
    'fname', file,      ...
    'head',  head       ...
);
