function N=laids(varargin)
%LAIDS     LAIDS [compound] list matching PDF files in pdfcards directory
%Example:  LAIDS lead
%	   N=LAIDS('lead')
%
%See also RAIDS

wd=cd;
arg=' ';
n=[];
for i=1:length(varargin)
    arg=[arg '"' varargin{i} '" '];
end
cmd=['gawk.exe -f laids.awk ' arg '*.aid'];
cd(pjtbxdir('pdf'));
[ignore,out]=dos(cmd);
cd(wd)
if isempty(strmatch('no match', out)) & nargout>0
    cr=sprintf('\r');
    nl=sprintf('\n');
    out(out==cr)='';
    inl=find(out==nl);
    i1=[1 inl(1:end-1)+1];
    i1=i1(ones(6,1), :);
    i2=(0:5)';
    i2=i2(:, ones(size(i1,2),1));
    ind=i1+i2; ind=ind(:);
    str=out(ind);
    n=sscanf(str, '%6f', inf);
end
if nargout>0
    N=n;
else
    fprintf('%s', out)
end
