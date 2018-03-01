function loadchi(pat,idx)
% LOADCHI(PAT)	    load all chi files matching shell pattern PAT
% LOADCHI(PAT,IDX)  load scans matching PAT with indices IDX
%
% See also LISTCHI

clear tth Q mon iraw irawsc iavg iavgsc inor Fraw Frawsc Favg Favgsc
setglobal='global tth Q mon iraw irawsc iavg iavgsc inor Fraw Frawsc Favg Favgsc';
eval(setglobal);
tth = []; Q = []; mon = []; iraw = []; irawsc = []; iavg = []; iavgsc = [];
inor = []; Fraw = []; Frawsc = []; Favg = []; Favgsc = [];

allscans = lsc(pat, 't');
if nargin > 1
    if isstr(idx)
	idx = evalin('caller', idx);
        [ignore,i] = unique(idx);
        idx = idx(sort(i));
    end
    selscans = {};
    selscans = allscans(idx);
else
    idx = 1:length(allscans);
    selscans = allscans;
end
    
Nscans = length(selscans);
for i = 1:Nscans
    scan = selscans{i};
    fprintf('%3i loading scan %s\n', i, scan);
    [data,head] = rhead(scan);
    % extract lambda
    lambdacell = regexp(head, '#\s+xray_wavelength = (\S+)', 'tokens');
    lambda = sscanf(lambdacell{1}{1}, '%f', 1);
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
    % find monitor counts
    start = regexp(head, '#L DegK_reg +DegK_sample +Epoch +Seconds +RingCurrent +Monitor[^#]+#', 'end');
    start = start(end) + 1;
    recs = sscanf(head(start:end), '%f', 13);
    mon(1,i) = recs(6);
    inor(:,i) = iraw(:,i)/mon(i);
end
sel4to10 = find(4 <= Q & Q <= 10);
for i = 1:Nscans
    scale(1,i) = iraw(sel4to10,i)\iraw(sel4to10,end);
    irawsc(:,i) = scale(i)*iraw(:,i);
    Frawsc(:,i) = scale(i)*Fraw(:,i);
    %
    iavgsc(:,i) = mean(irawsc(:,1:i),2);
    Favgsc(:,i) = mean(Frawsc(:,1:i),2);
end
evalin('base', setglobal);
fprintf('exported variables: tth Q mon iraw irawsc iavg iavgsc inor Fraw Frawsc Favg Favgsc\n');

if all(xlim() == [0, 1])
    save_xlim = 'auto';
else
    save_xlim = xlim();
end

clf
sel20to25 = find(20 <= Q & Q <= 25);
for i = 1:Nscans
    Fraw(:,i) = Fraw(:,i) - Q*(Q(sel20to25)\Fraw(sel20to25,i));
    Frawsc(:,i) = Frawsc(:,i) - Q*(Q(sel20to25)\Frawsc(sel20to25,i));
    Favg(:,i) = Favg(:,i) - Q*(Q(sel20to25)\Favg(sel20to25,i));
    Favgsc(:,i) = Favgsc(:,i) - Q*(Q(sel20to25)\Favgsc(sel20to25,i));
end

% mask too low F values
if Nscans > 0
    lo = -max(Fraw(:))/10; Fraw(Fraw<lo) = lo;
    lo = -max(Frawsc(:))/10; Frawsc(Frawsc<lo) = lo;
    lo = -max(Favg(:))/10; Favg(Favg<lo) = lo;
    lo = -max(Favgsc(:))/10; Favgsc(Favgsc<lo) = lo;
end

% default plot
plot( Q, iraw )
xlabel('Q', 'Interpreter', 'none');
ylabel('iraw', 'Interpreter', 'none');
ts = sprintf('%s ', selscans{:});
title(ts, 'Interpreter', 'none');

legargs = {};
for i = 1:length(selscans);
    legargs{i} = esctex(selscans{i});
end
legend(legargs{:})

xlim(save_xlim);
