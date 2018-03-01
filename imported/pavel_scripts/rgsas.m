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
str=fread(f,82*ceil(n/5))';
str=char(str);
fclose(f);
%deblank str
j=find(str(end-79:end)~=' ');
str(length(str)-80+j(end)+1:end)='';
str(str==' ') = '0';
d2=sscanf(str, '%8f', [2 n])';
y=d2(:,1);
esd=d2(:,2);
