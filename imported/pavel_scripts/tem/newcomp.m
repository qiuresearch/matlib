function newcomp()
%NEWCOMP   UI tool for creation of new compound M-file

% 1997 by Pavol

clc;
cpath=fileparts(fileparts(which('newcomp')));
cpath=fullfile(cpath, 'comps');
disp('Enter new compound name.');
fprintf('M-file with this name will be created in %s\n', cpath);
disp([]);
name=input('Compound name: ','s');
name=deblank(fliplr(deblank(fliplr(name))));
fname=fullfile(cpath, [lower(name), '.m']);
fid=fopen(fname,'r');
if fid~=-1
        fclose(fid);
        fprintf('\nM-file %s already exists.\n', fname);
        s=lower(input('Overwrite (y/n)? ','s'));
        if ~strcmp(s,'y')
                return;
        end
end
clc;
fid=fopen(fname,'wt');
if fid==-1
        error(sprintf('Cannot create %s',fname));
end
fprintf('Creating function M-file %s describing %s latice...\n\n',...
         [lower(name) '.m'], name);
disp('Enter necessary parameters [a b c alpha beta gamma]');
disp('of primitive cell (distances in A, angles in degrees)');
s=input('Lattice parameters: ','s');
s=[ '[' s ']' ];
abcABG=eval(s,'[]');
abcABG=(abcABG(:))';
len=length(abcABG);
if len==0
        abcABG=[1 1 1 90  90 90]
elseif len==1
        abcABG=[abcABG abcABG abcABG 90 90 90];
elseif len==2
        abcABG=[abcABG(1) abcABG 90 90 90];
elseif len==3
        abcABG=[abcABG 90 90 90];
elseif len==4
        abcABG=[abcABG(1:3) 90 abcABG(4) 90];
elseif len==5
        abcABG=[abcABG 90];
else
        abcABG=abcABG(1:6);
end
fprintf('\nAnd now enter all elements in %s separated by spaces.\n', name);
repeat=1;
while repeat
        s=input('Elements: ','s');
        repeat=0;
        if isempty(s)
            fprintf('Hey! Specify at least one element!\n');
            repeat=1;
        end
end
i=find(s==' '|s==9);
s(i)=' '*ones(size(i));
j=find(diff(i)==1);
s(i(j))=[];
if s(1)~=' ', s=[' ' s]; end;
if s(length(s))~=' ', s=[s ' ']; end;
i=find(s==' '); i(length(i))=[];
elements='';
len=length(i);
for a=1:len;
        elements=[elements ; s(i(a)+(1:2))];
end
elements=setstr(elements);

%so here starts real work...

%Comment...
fprintf(fid, 'function [X,Y,Z]=%s(element)\n', lower(name));
uname=upper(name);
fprintf(fid, '%%%-10sparameters of %s primitive cell\n', uname, name);
fprintf(fid, '%-11s[m,n,o] = %s(element) returns latice coordinates of\n', '%', uname);
fprintf(fid, '%-11sspecified element\n', '%');
fprintf(fid, '%-11sa = %s(''abc'') returns latice parameters [a b c alpha beta gamma]\n',...
             '%', uname);
fprintf(fid, '%-11sS = %s(''elements'') returns all elements in %s\n', '%', uname, name);
t=clock;
fprintf(fid, '\n%% %i by ??\n', t(1));

%Prologue...

%nargin==0
fprintf(fid, '\nif nargin==0\n');
fprintf(fid, '\tX=''%s'';\n', lower(name));
fprintf(fid, '\treturn;\nend\n');

fprintf(fid, 'X=[]; Y=[]; Z=[];\n');
fprintf(fid, 'element=deblank(element);\n');

%element=='abc'
fprintf(fid, 'if strcmp(element,''abc'')\n');
fprintf(fid,'\tX=[%g %g %g %g %g %g];\n', abcABG);
fprintf(fid,'\treturn;\n');

%element=='elements'
fprintf(fid, 'elseif strcmp(element, ''elements'')\n');
fprintf(fid, '\tX=[''%s''', elements(1,:));
for i=2:len
        fprintf(fid,';''%s''', elements(i,:));
end
fprintf(fid,'];\n\treturn;\n');

%element==el
for i=1:len
    el=deblank(elements(i,:));
    fprintf(fid, 'elseif strcmp(element, ''%s'')\n', el);
    fprintf(fid, '%%%% TYPE HERE %s POSITIONS IN LATICE COORDINATES:\n', el);
    fprintf(fid, '\tX = [];\n\tY = [];\n\tZ = [];\n');
end

%finish M-file...
fprintf(fid, 'else\n');
s='error(sprintf(''Unknown command option ''''%s'''''', element));';
fprintf(fid, '\t%s\n', s);
fprintf(fid, 'end\n');
fprintf(fid, 'X=X(:); Y=Y(:); Z=Z(:);\n');

fclose(fid);

%BYE:
clc;
disp([fname ' was successfully generated.']);
disp('You must edit it to specify atomic positions');
s=input('Edit right now? (y/n) ', 's');
clc;
if strcmp(lower(s),'y')
        edit(name);
end

