function data = rhead(file,n);
%RHEAD             rozumne ��ta d�ta z ASCII s�boru
%data = RHEAD(file,n)
%                - na��ta d�ta zo s�boru file do matice, 
%                  pri�om ��tanie za�ne po presko�en� aspo� 
%                  n riadkov (potom ��ta od prv�ho riadku, ktor� 
%                  za��na ��slom).
%RHEAD(file)     - berie n=0.
%RHEAD([n])      - to ist�, ale s�bor sa zad� cez dialog box 
%RHEAD(fid,n)      za�ne �ita� z fid s�boru, pri�om fid nezavrie
%
%                  Pou��va� len pre ASCII s�bory!

%               1995 by Pavol



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
  [filename, path] = uigetfile('*.*', 'Load ASCII Data', 200,200 ) ;
  file = lower([path , filename]);
  if ~isstr(file)
     return;
  end;
elseif isstr(file)
  file=lower( deblank( fliplr(deblank(fliplr ((file(:)).') )) ) );
end;

if isstr(file)
     if exist(file)~=2
        error('File not found.')
     end
     fid = fopen(file,'r');
else
     fid = file;
end

for i=1:n
   fgets(fid);
end

ncol=0;
while ncol==0 & ~feof(fid)
        s = setstr(fgets(fid));
        data=sscanf(s,'%f');ncol=length(data);
end
if ncol>1
   data = [data , (fscanf(fid,'%f',[ncol,Inf]) )];
   data = data.';
else
   data = [data ; (fscanf(fid,'%f',[ncol,Inf]) ).'];
end

if isstr(file)
    fclose(fid);
end
