function lsla(arg)
%LSLA      DIR with description of data files 
%   works similarly as DIR

unknownfiles={'xls', 'zip', 'swp', 'dll', 'exe'};

if nargin==0
   arg='';
end

warning off
if iscell(arg)
    arg=char(arg);
end
if size(arg,1) > 1
    for i=1:size(arg,1)
	lsla(arg(i,:));
    end
    return
end
if exist(arg)==7
   argdir=[arg '\'];
   arg='';
elseif exist(arg)==2
   datdesc(arg, unknownfiles)
   return;
elseif any(arg=='\') | any(arg=='/')
   i=max(find(arg=='\' | arg=='/'));
   argdir=arg(1:i);
   arg=arg(i+1:length(arg));
else
   argdir=cd;
end
warning on
orgdir=cd;
cd(argdir);
d=dir(arg);
if isempty(d)
   cd(orgdir);
   return
end

%remove directories...
isd=cat(1,d.isdir);
d=d(~isd);
if isempty(d)
   cd(orgdir);
   return
end
names=sortrows(lower(char(d.name)));
ext=setstr(' '*ones(size(names)));
m=size(names,2);
[i,j]=find(names=='.');
for a=1:length(i)
    ext(i(a),1:m-j(a))=names(i(a),(j(a)+1):m);
end
[ext,i]=sortrows(lower(ext));
names=names(i,:);

s=sprintf('\n%s%10i file(s)\n\n', cd, size(names,1));
for a=1:size(names,1)
    nm=deblank(names(a,:));
    datdesc(nm, unknownfiles);
end
cd(orgdir)

function datdesc(fname, unknownfiles)
%gets description of the file fname
desc='';
fid=fopen(fname);
if fid==-1
    return
end
i=find(fname=='.');
if ~isempty(i)
    ex=lower(deblank(fname(i(end)+1:end)));
else
    ex='';
end
if strcmp(ex, 'm')
    r=fgets(fid);
    i=min(find(r~=' ' & r~=9));
    if r(i(1))~='%'
	r=fgets(fid);
	i=min(find(r~=' ' & r~=9));
    end
    if r(i(1))=='%'
	r=r(i+1:length(r));
	r=r(r~=10 & r~=13);
	desc=r;
    else
	desc='';
    end
elseif strcmp(ex, 'raw')
    fseek(fid, 24, 'bof');
    desc=setstr((fread(fid,40))');
elseif strcmp(ex, 'pks')
    fseek(fid, 36, 'bof');
    desc=setstr((fread(fid,40))');
elseif any(strcmp(ex, unknownfiles))
    desc='';
else
    desc=fgetl(fid);
    if strcmp(desc, 'CHARGE')
	sdat=[desc sprintf('\n') char(fread(fid)')];
	sdat(sdat==sprintf('\r'))='';
	nl=[1 find(sdat==sprintf('\n'))+1];	%start of line positions
	Npts=sscanf(sdat(nl(6):nl(7)),'%f',1);
	np=[zeros(1,8) nl(9+2*Npts:end)];	%start of line positions after ep data
	desc=sdat(np(45):np(46)-1);
	desc=strrep(desc, 'Sample: ', '');
	desc=[desc sdat(np(57):np(59)-1)];
	desc(desc=='\')='';
	desc(desc==sprintf('\n'))=' ';
    elseif strcmp(desc, 'PIEZO');
	fgetl(fid);
	desc = [ fgetl(fid) ' ' fgetl(fid) ];
    end
end
fclose(fid);
ind=find(desc>127);
if ~isempty(ind)
    desc=desc(1:ind(1)-1);
end
desc=fliplr(deblank(fliplr(desc)));
fprintf('%-15s%.63s\n', fname, desc);
