% quick and dirty test of hedgehog search
subclusterIdx = 1:69;

r = rhead('rand50.xyz');
r = rhead('/u24/juhas/MSU/LIGA_runs/LJ/88.xyz');
r = rhead('/u24/juhas/MSU/LIGA_runs/C60func/c60nmethylpyrrolidine.xyz');
D = distmx(r);

submissingIdx = 1:size(r,1);
submissingIdx(subclusterIdx) = [];

% subcluster points
rsub = r(subclusterIdx,:);
nsub = length(subclusterIdx);
% subcluster distance list
dsub = D(subclusterIdx,subclusterIdx);
idx = tril(ones(size(dsub,1)),-1);
idx = (idx(:) == 1);
dsub = dsub(idx);

% missing cluster points
rmis = r(submissingIdx,:);
nmis = length(submissingIdx);
% missing cluster distance list
dmis = D;
idx = tril(ones(size(dmis,1)),-1);
idx(subclusterIdx,subclusterIdx) = 0;
idx = (idx(:) == 1);
dmis = dmis(idx);

% define unit size hedgehog
uhh = [
    -.5 -.5 0.0
    -.5 0.0 -.5
    0.0 -.5 -.5
    -.5 +.5 0.0
    -.5 0.0 +.5
    0.0 -.5 +.5
    +.5 -.5 0.0
    +.5 0.0 -.5
    0.0 +.5 -.5
    +.5 +.5 0.0
    +.5 0.0 +.5
    0.0 +.5 +.5
] / sqrt(0.5);
% [ignore,uhh] = bucky;

% real-size hedgehog
% idxpiv = 1;
idxpiv = ceil(rand(1)*length(dmis));
rhh = uhh*dmis(idxpiv);
rhh = uhh*min(dmis);
rtest = [];
for i = 1:size(rsub,1)
    rtest = [rtest; rhh+rsub(i*ones(size(rhh,1),1),:)];
end

% find the nearest thorn
Dtm = distmx2(rtest, rmis);
[dm,itest] = min(Dtm);
[dm,imis] = min(dm);
itest = itest(imis);

% fprintf('rtest(%i,:) = [%f, %f, %f]\n', itest, rtest(itest,:));
% fprintf('rmis(%i,:)  = [%f, %f, %f]\n', imis, rmis(imis,:));
% fprintf('Dtm(%i,%i)  =  %f\n', itest, imis, Dtm(itest, imis));

rn = rtest(itest,:);

disp('calculating abadness')
ab = abad(rtest, rsub, dmis);
[ignore,iab] = sort(ab);
disp('checking 40 best points:')
tic
success = 0;
for ichk = 1:40;
    fprintf('%i: abad0 = %f ', iab(ichk), ab(iab(ichk)));
    rn = rtest(iab(ichk),:);
    while 1
        dn = distmx2(rsub, rn);
        Ln = lsqchoice(dmis, dn);
        dd = Ln - dn;
        dvarn0 = mean(dd.^2);
%         fprintf('rn = [%f, %f, %f], dvarn = %g\n', rn, dvarn0);

        Rsub = sqrt(sum(rsub.^2,2));
        % build Dong matrix
        [ignore,ibest] = min(abs(dd));
        M = -2*(rsub-rsub(ibest*ones(nsub,1),:));
        rhs = Ln.^2 - Rsub.^2 - (Ln(ibest).^2 - Rsub(ibest).^2);
        ig = 1:length(dd);
    %   ig = find(abs(dd) > 0.5 *max(abs(dd)));
%       [ignore,ig] = sort(abs(dd)); ig=ig(1:ceil(length(ig)/2));
%       rn1 = (M(ig,:)\rhs(ig))';
        rn1 = fitsprings(rsub, Ln, ones(size(Ln)), rn);
        dn1 = distmx2(rsub,rn1);
        Ln1 = lsqchoice(dmis, dn1);
        dvarn1 = mean((dn1-Ln1).^2);
%         fprintf('rn1 = [%f, %f, %f], dvarn = %g\n', rn1, dvarn1);
        if dvarn1 < dvarn0
            rn = rn1;
        else
            break
        end
    end
    if dvarn0 < 1e-8
        success = success+1;
    end
    [dnear,inear] = min(distmx2(rn,rmis));
    fprintf('abad = %g dnear = %g inear = %i\n', abad(rn, rsub, dmis), dnear, inear);
end
fprintf('found %i positions\n', success);
toc
