function [E,P] = rpol(file);
%RPOL      reads RT66 polarization data
%   [E,P]=RPOL(file), reads electric field E(kV/cm) and
%      polarization P(uC/cm2)
%   S = RRAW(file)   returns all data in a structure S, with the fields
%      e, p   electric field, polarization
%      desc   description
%      fname  datafile name
%      smpa   sample area in cm2
%      smpt   sample area in um
%      pPr    +Pr in uC/cm2
%      nPr    -Pr in uC/cm2

%   2000 by Pavol

if nargin==0
  file='';
end
if isempty(file)
    [filename, path] = uigetfile('*.*', 'Load RT66 Data', 200, 200 ) ;
    file = lower([path , filename]);
    if ~isstr(file)
       return;
    end;
end
if exist(file)~=2
    error('File not found.')
end

fid=fopen(file, 'rt');
f_h1 = fgetl(fid);
switch f_h1
case 'CHARGE',
    fseek(fid, 0, 'bof');
    sdat=char(fread(fid)');
    sdat(sdat==sprintf('\r'))='';
    fclose(fid);
    nl=[1 find(sdat==sprintf('\n'))+1];	%start of line positions
    Npts=sscanf(sdat(nl(6):nl(7)), '%f', 1);
    np=[zeros(1, 8) nl(9+2*Npts:end)];	%start of line positions after ep data
    vp=sscanf(sdat(nl(7):end), '%f', [2, Npts+1])'; %V(V), P(uC/cm2) pairs
    f_desc=sdat(np(45):np(46)-1);
    f_desc=strrep(f_desc, 'Sample: ', '');
    f_desc=[f_desc sdat(np(57):np(59)-1)];
    f_desc(f_desc=='\')='';
    f_desc(f_desc==sprintf('\n'))=' ';
    f_desc=deblank(f_desc);
    f_smpa=sscanf(sdat(np(47):np(48)), '%f', 1); %thickness in cm2
    f_smpt=sscanf(sdat(np(48):np(49)), '%f', 1); %thickness in microns
    f_pPr = sscanf(sdat(np(31):np(32)), '%f', 1); % +Pr in uC/cm2
    f_nPr = sscanf(sdat(np(32):np(33)), '%f', 1); % +Pr in uC/cm2
    v = vp(:,1);
    p = vp(:,2);
case 'PIEZO',
    fgetl(fid);
    % line 3
    f_desc = [ fgetl(fid) ' ' fgetl(fid) ];
    % read 6
    fgetl(fid);
    % 7 is date
    f_date = fgetl(fid);
    % 8 is time
    f_time = fgetl(fid);
    % 9 is Npts
    Npts = fscanf( fid, '%i', 1 );
    f_dat1 = fscanf( fid, '%f', [4 Npts+1] )';
    v = f_dat1(:,1);
    p = f_dat1(:,2);
    % 6 numbers before ^10$, probably Pmax etc.
    f_dat2 = fscanf( fid, '%f', 6 )';
    % skip %10$
    fscanf( fid, '%f', 1 );
    % 10 lines of 4 columns
    f_dat3 = fscanf( fid, '%f', [4 10] )';
    % then there are 18 more numbers, but let's read until mode description
    f_dat4 = fscanf( fid, '%f' );
    f_smpa = f_dat4(end-1);
    f_smpt = f_dat4(end);
    fclose(fid);
otherwise,
    fclose(fid);
    error( sprintf('unknown file type: %s', f_h1) );
end

%convert to kV/cm
e = v/1000/(f_smpt*1e-4);

if nargout<2
    E=struct( 'e', e, 'p', p, 'desc', f_desc, 'fname', file, ...
    'smpa', f_smpa, 'smpt', f_smpt, 'pPr', f_pPr, 'nPr', f_nPr, ...
    'Pr', (f_pPr - f_nPr)/2 );
else
    E=e;
    P=p;
end
