function [tc,etc,a,b]=tcted(file, tlo, thi, cols)
%TCTED     calculate Curie temperature from dielectric data
%[TC,ETC,A,B]=TCTED(FILE, TLOW, THIGH[, COLS]) or
%[TC,ETC,A,B]=TCTED(RTED_STRUCT, TLOW, THIGH[, COLS])
%   fits line to 1/eps(:,COLS) between TLOW to THIGH
%   ETC is an estimated TC error,
%   A, B parameters of the fitted line

%1998 by Pavol

if nargin<4
    cols='all';
end
if nargin<3
    thi=inf;
end
if ~isstruct(file)
    file=rted(file);
end
t=file.t;
kr=file.k.^(-1);
if strcmp(cols, 'all')
    cols=1:size(kr,2);
end
if isstr(tlo)
    tlo=sscanf(tlo, '%f', 1); 
end
if isstr(thi)
    thi=sscanf(thi, '%f', 1); 
end
if isstr(cols)
   cols=eval(cols,'[]');
end
tlo=tlo(1);
thi=thi(1);
%end of junk

i=find(t>=tlo & t<=thi);
t=t(i);
t=t(:,ones(1,length(cols)));
kr=kr(i,cols);
[a,b,ea,eb]=linreg(t,kr);
tc=-b/a;
etc=sqrt( (eb/a)^2 + (ea*b/a^2)^2 );
