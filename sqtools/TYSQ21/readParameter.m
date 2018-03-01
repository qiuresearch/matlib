function coeArray = readParameter(fileName)

fid = fopen(fileName,'r+');

flag = 1;

i=0;
while flag
    line = fgetl(fid);
    
    %End of file. End loop
    if ~ischar(line), break, end;
    
%    if line == ''
%       fprintf('hello'); 
%       break;
%    end;

    %Skip white space lines;
    while length(line) < 3 | strcmp(deblank(line), '')
        %display('blank line');
        line = fgetl(fid);
       if ~ischar(line)
            flag = 0;
            break;
        end
    end
    
    if flag == 0, break, end;
     
    %Comment line, skip it
    while line(1) == '%'
       % display('comment line');
        line = fgetl(fid);
        if ~ischar(line)
            flag = 0;
            break;
        end        
        if line(1) ~= '%'
            flag = 2;
            break;
        end
    end
    
    if flag == 0, break, end;   
    
    %Skip first description line
    line = fgetl(fid);
    if ~ischar(line),break,end;
    
    i=i+1;
    %Read Z1
    line = fgetl(fid);
    coeArray(i).Z1=readPattern(line);
    
    %Read Z2
    line = fgetl(fid);
    coeArray(i).Z2=readPattern(line);
    
    %Read K1
    line = fgetl(fid);
    coeArray(i).K1=readPattern(line);
    
    %Read K2
    line = fgetl(fid);
    coeArray(i).K2=readPattern(line);
    
    %Read volume fraction
    line = fgetl(fid);
    coeArray(i).volF=readPattern(line);
    
    %Skip blank line
    line = fgetl(fid);
    
    %Read a00
    line=fgetl(fid);
    coeArray(i).a00=readPattern(line);
    
    %Read b00
    line=fgetl(fid);
    coeArray(i).b00=readPattern(line);
    
    %Read v1
    line=fgetl(fid);
    coeArray(i).v1=readPattern(line);
    
    %Read v2
    line=fgetl(fid);
    coeArray(i).v2=readPattern(line);
    
    %Skip blank line
    line = fgetl(fid);
    
    %Read Description;
    line = fgetl(fid);
    coeArray(i).message = line;
end

fclose(fid);

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = readPattern(line)

[temp,remain]=strtok(line,'=');
remain=strrep(remain,'=','');
remain=strrep(remain,';','');
data=str2num(remain);

return
