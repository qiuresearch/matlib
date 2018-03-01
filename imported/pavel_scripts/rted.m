function [t,k,d,f,desc,fname]=rted(file)
%RTED      reads old or new formats of permitivity data
%   [T,K,D,F,DESC]=RTED(file)
%   [T,K,D,F,DESC,FILE]=RTED   uses open file dialog box
%   S=RTED(file)  returns all data in structure S

%   1998 by Pavol

if nargin==0
  file=[];
end
if isempty(file)
    [filename, path] = uigetfile('*.*', 'Load TED Data', 200,200 ) ;
    file = lower([path , filename]);
    if ~isstr(file)
       return;
    end;
else
    file=lower( deblank( fliplr(deblank(fliplr ((file(:)).') )) ) );
end;
fname=file;

if exist(file)~=2
    error('File not found.')
end

fid=fopen(file,'r');
s=fread(fid,[1,200]);
pos=findstr(s,'TEMPMEAS');
if ~isempty(pos)           %is old fashioned format
    cn=findstr(s, sprintf('\n')); cn=cn(1)-1;
    if s(cn)==sprintf('\r'),  cn=cn-1;  end
    desc=setstr(s(1:cn));
    fseek(fid,pos+8,'bof');
    cn=round(fscanf(fid,'%f',1));
    [data,N]=fscanf(fid,'%f');
    N=4*cn*floor(N/4/cn);
    fclose(fid);
    t=zeros(cn,N/4/cn);
    t(:)=data(1:4:N);
    t=(mean(t))';
    f=(data(2:4:cn*4-2))';
    k=zeros(cn,N/4/cn);
    d=k;
    k(:)=data(3:4:N);
    k=k';
    d(:)=data(4:4:N);
    d=d';
else
    f=[];
    fseek(fid, 0, 'bof');
    [data,s]=rhead(fid, 6);
    if size(data,1)>0 & data(end,end)==0 %file not finished...
       data(end,:)=[];
    end
    fclose(fid);
    s(s==sprintf('\r'))='';
    lnbrk=find(s==sprintf('\n'));
    desc=s(1:lnbrk(1)-1);
    pos=findstr(s(lnbrk(1):length(s)), sprintf('\nf:'));
    pos=pos(1)-1+lnbrk(1)+3;
    f=sscanf(s(pos:length(s)), '%f');
    t=[]; k=[]; d=[];
    n=round((size(data,2)-1)/2);
    if n>0
	t=data(:,1);
	k=data(:,2:1+n);
	d=data(:,2+n:1+2*n);
    end
end
if nargout<2
   t=struct( 't', t, 'k', k, 'd', d, 'k2', k.*d, 'f', f, ...
	     'desc', desc, 'fname', fname, 'head', s );
end
