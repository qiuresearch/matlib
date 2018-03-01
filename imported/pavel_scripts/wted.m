function wted(file,head,T,eps,D)
%WTED      write to permitivity data file
%   WTED(FILE,HEAD,T,K,D)
%   WTED(FILE, S)  parameters are specified in structure S
%   with the fields: 't', 'k', 'd', 'head'

%   1999 by Pavol

if nargin<5
    if isstr(head)
	head=evalin('caller', head);
    end
    T=head.t;
    eps=head.k;
    D=head.d;
    head=head.head;
end

%make it sure and erase the line with T eps1 eps2...
i=max(findstr(head,sprintf('\nT')));
s=sscanf(head(i+1:length(head)),'%s');
isf.eps1=~isempty(findstr(s,'eps1'));
isf.Cp1=~isempty(findstr(s,'Cp1'));
isf.D1=~isempty(findstr(s,'D1'));
if ~(isf.eps1 | isf.Cp1) | ~isf.D1
   i=length(head);
end
head(i+1:length(head))='';

fno=size(eps,2);
fid=fopen(file, 'wt');
fprintf(fid, '%sT       ', head);
if isf.eps1
     fprintf(fid, 'eps%-12i', 1:fno);
elseif isf.Cp1
     fprintf(fid, 'Cp%-13i', 1:fno);
end
if isf.D1
     fprintf(fid, 'D%-14i', 1:(fno-1));
     fprintf(fid, 'D%i', fno);
end
fprintf(fid,'\n');
fmt1='%-8.1f';
fmt2='%-15.6g';
fmt3='%.6g\n';
i=(1:length(fmt2))';
i=i(:,ones(2*fno-1,1));
fmt=[fmt1 fmt2(i(:)) fmt3];
fprintf(fid,fmt,[T eps D]');
fclose(fid);
