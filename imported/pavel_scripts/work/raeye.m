function [r,abadness] = raeye(filename)
% [R,ABADNESS] = RAEYE(FILENAME)    read atomeye file from BGAlib

fid = fopen(filename);
[ignore,header] = rhead(fid, 0);
if isempty(strfind(header, 'Number of particles'))
    fclose(fid);
    error('Invalid atomeye format')
end
pat   = 'H0(1,1) =';
start = strfind(header, pat);
if isempty(start)
    fclose(fid);
    error('Invalid atomeye format')
end
metrics=zeros(3);
[metrics(:),n] = sscanf(header(start(1):end), '%*s =%f%*s', 9);
if n ~= 9
    fclose(fid);
    error('cannot parse metrics')
end
metrics = metrics';
r = []; abadness = [];
while ~feof(fid)
    r1 = rhead(fid, 1);
    if ~feof(fid) & all(r1(end,2:end)==0)
	r1(end,:)=[];
    end
    r = [r; r1(:,1:3)];
    abadness = [abadness; r1(:,4:end)];
end
r = (r-0.5) * metrics';
fclose(fid);
