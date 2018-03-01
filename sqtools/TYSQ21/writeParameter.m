function writeParameter(result,fileName,index)

if nargin == 2
    if length(result) > 1
        fprintf('Too many arguments');
        return
    end
        
    fid1 = exist(fileName);
    
    if fid1 == 2
        
        coeArray = readParameter(fileName)
        fid = fopen(fileName,'a+');        
        N=length(coeArray);        
    elseif fid1 == 0
        
        fid = fopen(fileName,'w+')
        N = 0;
    end

    fprintf(fid,'\n');
    fprintf(fid,'%d) Data set %d (attractive potential %e kT)', [N+1,N+1,result.K1]);
    fprintf(fid,'\n');
    fprintf(fid,'\n Z1=%1.15e ;',result.Z1);
    fprintf(fid,'\n Z2=%1.15e ;',result.Z2);
    fprintf(fid,'\n K1=%1.15e ;',result.K1);
    fprintf(fid,'\n K2=%1.15e ;',result.K2);
    fprintf(fid,'\n volF=%1.15e ;',result.volF);
    fprintf(fid,'\n');
    fprintf(fid,'\n a00=%1.15e ;',result.a00);
    fprintf(fid,'\n b00=%1.15e ;',result.b00);
    fprintf(fid,'\n v1=%1.15e ;',result.v1);
    fprintf(fid,'\n v2=%1.15e ;',result.v2);
    fprintf(fid,'\n');
    fprintf(fid,'\n %s ;',result.message);
    fprintf(fid,'\n');    

    fclose(fid);
end

if nargin == 3 & index > 0
    
    coeArray = readParameter(fileName);

    N=length(coeArray);    
    if index > N
        fprintf('\n Wrong index');
        return;
    end
    
    fid = fopen(fileName,'w');

    coeArray(index) = result;
%    coeArray(index).Z1 = result.Z1;
%    coeArray(index).Z2 = result.Z2;    
%    coeArray(index).K1 = result.K1;    
%    coeArray(index).K2 = result.K2;    
%    coeArray(index).volF = result.volF;
%    coeArray(index).a00 = result.a00;    
%    coeArray(index).b00 = result.b00;    
%    coeArray(index).v1 = result.v1;    
%    coeArray(index).v2 = result.v2;  
%    coeArray(index).message = result.message;    
    
    for i = 1:N
        result = coeArray(i);
        fprintf(fid,'\n');
        fprintf(fid,'%d) Data set %d (attractive potential %e kT)', [i,i,result.K1]);
        fprintf(fid,'\n');
        fprintf(fid,'\n Z1=%1.15e ;',result.Z1);
        fprintf(fid,'\n Z2=%1.15e ;',result.Z2);
        fprintf(fid,'\n K1=%1.15e ;',result.K1);
        fprintf(fid,'\n K2=%1.15e ;',result.K2);
        fprintf(fid,'\n volF=%1.15e ;',result.volF);
        fprintf(fid,'\n');
        fprintf(fid,'\n a00=%1.15e ;',result.a00);
        fprintf(fid,'\n b00=%1.15e ;',result.b00);
        fprintf(fid,'\n v1=%1.15e ;',result.v1);
        fprintf(fid,'\n v2=%1.15e ;',result.v2);
        fprintf(fid,'\n');
        fprintf(fid,'\n %s ;',result.message);
        fprintf(fid,'\n');
    end
    fclose(fid);    
end


if nargin == 3 & index == -1
    
    coeArray = result;
    N=length(coeArray);    
    
    fid = fopen(fileName,'w');

    for i = 1:N
        result = coeArray(i)
        fprintf(fid,'\n');
        fprintf(fid,'%d) Data set %d (attractive potential %e kT)', [i,i,result.K1]);
        fprintf(fid,'\n');
        fprintf(fid,'\n Z1=%1.15e ;',result.Z1);
        fprintf(fid,'\n Z2=%1.15e ;',result.Z2);
        fprintf(fid,'\n K1=%1.15e ;',result.K1);
        fprintf(fid,'\n K2=%1.15e ;',result.K2);
        fprintf(fid,'\n volF=%1.15e ;',result.volF);
        fprintf(fid,'\n');
        fprintf(fid,'\n a00=%1.15e ;',result.a00);
        fprintf(fid,'\n b00=%1.15e ;',result.b00);
        fprintf(fid,'\n v1=%1.15e ;',result.v1);
        fprintf(fid,'\n v2=%1.15e ;',result.v2);
        fprintf(fid,'\n');
        fprintf(fid,'\n %s ;',(result.message));
        fprintf(fid,'\n');        
    end
    fclose(fid);    
end

return