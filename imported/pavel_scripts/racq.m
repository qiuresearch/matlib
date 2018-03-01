function [theta2,I] = racq(file);
%RACQ      read ACQ file used by some X-ray systems
%   T2I = RACQ(file)   returns n by 2 matrix
%   [T2,I]=RACQ(file)
%   [T2,I]=RACQ   uses open file dialog box

%       1997 by Pavol

if nargin==0
  file=[];
end
if isempty(file)
  [filename, path] = uigetfile('*.acq', 'Load ACQ Data', 200,200 ) ;
  file = lower([path , filename]);
  if ~isstr(file)
     return;
  end;
else
  file=lower( deblank( fliplr(deblank(fliplr ((file(:)).') )) ) );
  n=length(file);
  ext=file(max(1,n-3):n);
  if ~strcmp(file, '.acq') & ext(1)~='.';
        file=[file '.acq'];
  end
end;

if exist(file)~=2
  error('File not found.')
end

fid=fopen(file,'r');
for i=1:5
   fgets(fid);
end
theta2=fscanf(fid, '%f', 3);
theta2=(theta2(1):theta2(2):theta2(3))';
I=fscanf(fid, '%f', length(theta2));
fclose(fid);
if nargout<2
  theta2=[theta2 I];
end
