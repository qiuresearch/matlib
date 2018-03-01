function [TH2,IREL] = rpks(a_file, refflag);
%RPKS      reads data from rigaku PKS file
%   [T2,IREL] = RPKS(file)   reads data to vectors
%   S = RPKS(file)   reads all data to a structure S with the
%   following fields: th2, d, irel, icps, fwhm, fname
%   S = RPKS(file, 'ref')   reads refined pks structure from 
%	../pavol/data/ref_pks.mat
%   RPKS -l lists refined pks files

if nargin==0
    file='';
else
    file=a_file;
end
if nargin<2
    refflag='';
end
if isempty(file)
    [filename, path] = uigetfile('*.pks', 'Load PKS Data', 200,200 ) ;
    file = lower([path , filename]);
    if ~isstr(file)
       return;
    end;
elseif isnumeric(file)
    file=sprintf('Z%05i.PKS', file);
else
    file=lower( deblank( fliplr(deblank(fliplr ((file(:)).') )) ) );
    if all(file>='0' & file<='9') & exist(file)~=2
        file=['z' file];
    end
    n=length(file);
    ext=file(max(1,n-3):n);
    if ~strcmp(file, '.pks') & all(ext-'.');
          file=[file '.pks'];
    end
end;

matname=[pjtbxdir('data') '/ref_pks.mat'];
if strcmp(refflag, 'ref')
    %build the variable name
    [ignore, vn]=fileparts(file);
    if ~strcmp('fp',file(1:2))
        vn=['fp' lower(vn)];
    end
    if nargout==0
        fprintf('loading to variable %s\n', vn);
        evalin('caller', ['load ' matname ' ' vn])
    else
        load(matname, vn)
        eval(['TH2=' vn ';'], 'TH2=[];')
    end
    return
end
if ~exist(file,'file')
    if strcmp(a_file,'-l')
        who('-file', matname);
        return
    elseif strcmp(refflag,'-l')
        who(a_file, '-file', matname);
        return
    else
        error('File not found.')
    end
end

fid=fopen(file,'r');
fseek(fid, 36, 'bof');
desc=setstr((fread(fid,40))');
ind=[find(desc>127) length(desc)+1];
desc=deblank(desc(1:ind(1)-1));
fseek(fid, 325, 'bof');
data=fread(fid, inf, 'float');
fclose(fid);
TH2=data(1:9:end);
D=data(2:9:end);
IREL=data(3:9:end);
ICPS=data(4:9:end);
FWHM=data(5:9:end);
%make sure it is sorted
if any(diff(TH2)<0)
    [TH2,isort]=sort(TH2);
    D=D(isort);
    IREL=IREL(isort);
    ICPS=ICPS(isort);
    FWHM=FWHM(isort);
end
if nargout<2
   TH2=struct('th2', TH2,...
	      'd',   D,...
	      'irel',IREL,...
	      'icps',ICPS,...
	      'fwhm',FWHM,...
              'desc', desc,...
              'fname', file);
end
