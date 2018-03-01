function H=shfed(file,sty)
%SHFED     plots fed data file
%   SHFED(FILE[, S]) or
%   SHFED(DATA[, S])

%1998 by Pavol

if nargin==0
    file='';
end
if nargin<2
    sty='';
end
if isnumeric(file)
    data=file;
else
    data=rhead(file, 1);
end
f=data(:,1);
e=data(:,2);
d=data(:,3);
if size(data,2)>=5
   se=data(:,4);
   sd=data(:,5);
end
subplot(211);
he=semilogx(f,e,sty);
ylabel('K')
subplot(212);
hd=semilogx(f,d,sty);
xlabel('f (Hz)');
ylabel('D');
if nargout>0
    H=[he hd];
end
