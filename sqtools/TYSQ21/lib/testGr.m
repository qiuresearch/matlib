function flag=testGr(r,g_r,displayFlag)

global debugFlag;

if nargin == 2
    displayFlag = 0;
end

if max(g_r) > 20
%    flag=1;
%    return;
     if displayFlag, fprintf('Warning! Maximum value of g(r) > 20 \n'),end;
end

index = find(r<1);
average=sum(g_r(index)) / length(index);

if average < -1
    flag=-2;
    if displayFlag, fprintf('Negative warning g(r), less than -1 in the hardcore'),end;
    return;
elseif average < -0.3 
    flag = -1;
    if displayFlag, fprintf('Negative warning g(r), less than -0.3 in the hardcore'),end;
    return
elseif average < -10
    flag = 1;
    return;
end

index = find(r<1);
index =index(2:length(index));
average=sum((g_r(index))) /length(index);

if average > 1
    flag = -3;
    if displayFlag, fprintf('Positive warning g(r), average > 1 inside hardcore'),end;
    return
elseif average > 0.3 
    flag = -1;
    if displayFlag, fprintf('Positive warning g(r), average > 0.1 inside hardcore'),end;   
    return
elseif average > 10
    flag = 1;
    return;
end

flag = 0;
return
