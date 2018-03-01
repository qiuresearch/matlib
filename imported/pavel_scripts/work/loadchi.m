function loadscans(pat,idx)
% LOADCHI(PAT)  load all chi files matching shell pattern PAT
% LOADCHI(PAT,IDX)  load scans matching PAT with index IDX

clear tth Q iraw irawsc iavg iavgsc Fraw Frawsc Favg Favgsc
setglobal='global tth Q iraw irawsc iavg iavgsc Fraw Frawsc Favg Favgsc';
eval(setglobal);
tth = []; Q = []; iraw = []; irawsc = []; iavg = []; iavgsc = [];
Fraw = []; Frawsc = []; Favg = []; Favgsc = [];
lambda = 0.142959; % A

allscans = lsc(pat);
if nargin > 1
    selscans = {};
    for selidx = idx(:)'
	for i=1:length(allscans)
	    [p,n,e] = fileparts(allscans{i})
	    if length(n>=3) & strcmp(n(end-2:end), sprintf('%03i',selidx))
		selscans{end+1} = allscans{i};
		break;
	    end
	end
    end
else
    selscans = allscans;
end
    
Nscans = length(selscans);
for i = 1:Nscans
    scan = selscans{i};
    data = rhead(scan);
    fprintf('%2i loading scan %s\n', i, scan);
    tth = data(:,1);
    if i == 1
        tth0 = tth;
    elseif ~isequal(tth, tth0)
        error(sprintf('incompatible scan %s', scan))
    end
    Q = 4*pi*sind(tth/2)/lambda;
    iraw(:,i) = data(:,2);
    iavg(:,i) = mean(iraw,2);
    Fraw(:,i) = Q.*iraw(:,i);
    Favg(:,i) = Q.*iavg(:,i);
end
sel4to10 = find(4 <= Q & Q <= 10);
for i = 1:Nscans
    sc = iraw(sel4to10,i)\iraw(sel4to10,end);
    irawsc(:,i) = sc*iraw(:,i);
    Frawsc(:,i) = sc*Fraw(:,i);
    %
    iavgsc(:,i) = mean(irawsc(:,1:i),2);
    Favgsc(:,i) = mean(Frawsc(:,1:i),2);
end
evalin('base', setglobal);
fprintf('exported variables: tth Q iraw irawsc iavg iavgsc Fraw Frawsc Favg Favgsc\n');

clf
sel20to25 = find(20 <= Q & Q <= 25);
slope = zeros(length(Q),Nscans);
for i = 1:Nscans
    slope(:,i) = Q(sel20to25)\Favg(sel20to25,i);
end
plot( Q, Favg - slope.*Q(:,ones(1,Nscans)) )
xlabel('Q', 'Interpreter', 'none');
ylabel('Favg - slope*Q', 'Interpreter', 'none');
title(pat, 'Interpreter', 'none');

legargs = {}; for s = selscans; legargs{end+1} = esctex(s{1}); end
% legend(legargs{:})
