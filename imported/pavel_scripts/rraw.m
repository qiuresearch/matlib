function [TH2,I,desc,ddtt,file] = rraw(file);
%RRAW      reads data from rigaku RAW file
%   S = RRAW(file)   reads all data to a structure S
%   [T2,I] = RRAW(file)   reads data to vectors
%   [T2,I,DESC,DDTT] = RRAW(file)   gets the file description
%   and time of the measurement, DESC and DDTT are strings
%   [T2,I] = RRAW   uses open file dialog box

%   1998 by Pavol

if nargin==0
  file='';
end
if isempty(file)
    [filename, path] = uigetfile('*.raw', 'Load RAW Data', 200,200 ) ;
    file = lower([path , filename]);
    if ~isstr(file)
       return;
    end;
elseif isnumeric(file)
    file=sprintf('z%05i.raw', file);
else
    file=lower( deblank( fliplr(deblank(fliplr ((file(:)).') )) ) );
end;

if all(file>='0' & file<='9') & exist(file)~=2
    file=['z' file];
end
ext=file(max(1,end-3):end);
if ~strcmp(file, '.raw') & all(ext~='.');
    file=[file '.raw'];
end
if exist(file)~=2
    error('File not found.')
end

fid=fopen(file,'r');
head=char(fread(fid,[1 200],'char'));
fseek(fid,4,'bof');            %now at 4
ddtt=fread(fid, 9);            %now at 13
fseek(fid,3,'cof');            %now at 16
ddtt=setstr([ddtt',' ',(fread(fid,8))']);
desc=setstr((fread(fid,40))'); %now at 64
desc=deblank(desc);
fseek(fid,16,'cof');           %now at 80
thr(3)=fread(fid,1,'float');   %now at 84
sspeed=fread(fid,1,'float');   %now at 88
fseek(fid,48,'cof');           %now at 136
thr(1)=fread(fid,1,'float');   %now at 140
thr(2)=fread(fid,1,'float');   %now at 144
TH2=(0:round((thr(3)-thr(1))/thr(2)))'*thr(2)+thr(1);
fseek(fid,56,'cof');           %now at 200
I=fread(fid,inf,'float');
fclose(fid);
if nargout<2
   TH2=struct('th2',TH2,'y', I, 'desc', desc, 'ddtt', ddtt,...
              'sspeed',sspeed,'fname', file, 'head', head);
end
