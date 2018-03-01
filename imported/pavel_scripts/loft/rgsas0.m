function [th2,y,esd,desc]=rgsas(file)
%[TH2,Y,ESD,DESC]=RGSAS(FILE)

file=deblank(file);
f=fopen(file, 'rt');
l1=fgetl(f);
desc=deblank(l1(1:48));
time=deblank(l1(49:56));
date=deblank(l1(58:66));
l2=fgetl(f);
d1=sscanf(l2, 'BANK %*i %i %*i %*s %f %f');
n = d1(1); 
th1 = d1(2)/100;
dth = d1(3)/100;
th2=(0:n-1)' * dth + th1;
str=fread(f);
fclose(f);
cr=sprintf('\r');
nl=sprintf('\n');
str(str==cr | str==nl)='';
str1=zeros(8, length(str)/8);
str1(:)=str(:);
str1=[str1; nl+zeros(1,length(str)/8)];
str1=char(str1(:))';
%god knows why it is much faster through fscanf...
%d2=sscanf(str1, '%f', [2 n]);
tmp=[tempname '.dat'];
ft=fopen(tmp,'w+');
fwrite(ft, str1); 
fseek(ft,0,'bof');
d2=fscanf(ft, '%f', [2 n]);
fclose(ft);
delete(tmp)
y=d2(1,:)';
esd=d2(2,:)';
