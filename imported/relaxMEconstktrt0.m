%use global REGLAMDA to penalize fit according to second derivative
% 
% % change from parameters with leading ktr to one those without ktr:
% fitlog10ktransport = parameter(1);
% distribution = exp(parameter(2:(1+nFitDistParams)));
% logdistribution = log(distribution);
% Baselines = parameter((nFitDistParams+2):(1+nFitDistParams+nBaselines));

global BASELINES;
BASELINES = Baselines;

PLOTINFOSTRING = 're-fitting preparing for ME';


%remove all zeros
tmpsol = distribution;
% makeuniformfract = 0.5; 
% tmpdistribution = ((1-makeuniformfract)*tmpsol') + sum(tmpsol)*makeuniformfract/(length(tmpsol));
tmpdistribution = (sum(tmpsol)/(length(tmpsol)))*ones(1,length(tmpsol));
tmpdistribution = tmpdistribution';

logtmpsol = log(tmpdistribution);logtmpsol = logtmpsol';
distribution = tmpsol;
logdistribution = logtmpsol;
parameter = [logdistribution];
plotparameters = [distribution BASELINES t0times fitlog10ktransport];
mexplotresultstrans;

plotparameters = [exp(logdistribution) BASELINES t0times fitlog10ktransport];
mexplotresultstrans;

% 
% % calculate so far best-fit sosq0 and plot
% REGLAMDA = 0; 
global REGPENALTYOFFSET;
REGPENALTYOFFSET = 0;
% parameter = [logdistribution];
% % NMEXFUNCOUNT = 0; MEXDISTRIBUTIONARRAY = []; HOLDRMSD = [];nmexfunphase = 0;
% % 
% % resv = MEmexlsqlogMLTransFunFix(parameter,ODETstruct,theosignalmats,signalmats,fitlog10ktransport,konvec,koffvec,fitlimits,tcontact,concs,ndattotal,BaselineInfo,t0times);
% % testsosq = resv*resv';
% % testrmsd = sqrt(testsosq/(length(resv)));
% % 
nfuncs = 5000;
options = optimset('Display', 'iter', 'MaxFunEvals', nfuncs, 'DiffMinChange', 1e-3,'LargeScale', 'off','TolCon', 1e-6,'TolFun', 1e-3, 'TolX', 1e-4,'LevenbergMarquardt', 'off');
pack;
% [parameter,sosq] = lsqnonlin(@MEmexlsqlogMLTransFunFixNOB,parameter,[],[],options,...
%                 ODETstruct,theosignalmats,signalmats,fitlog10ktransport,konvec,koffvec,fitlimits,tcontact,concs,ndattotal,BaselineInfo,t0times);
% distribution = exp(parameter(1:nFitDistParams));
% Baselines = BASELINES;
% plotparameters = [distribution Baselines t0times fitlog10ktransport];
% mexplotresultstrans;
% 
% entropy0 = -logdistribution*distribution';
% resv = MEmexlsqlogMLTransFunFixNOB(parameter,ODETstruct,theosignalmats,signalmats,fitlog10ktransport,konvec,koffvec,fitlimits,tcontact,concs,ndattotal,BaselineInfo,t0times);
% sosq0 = rmsd0*rmsd0';
% ConfidenceLevel = 0.95;
% ConfidenceSInc = finv(ConfidenceLevel,length(resv),length(resv));
% % 




% %starting value for REGLAMDA: make penalty ~ 1% of sosq
% StartRegLamda = 0.001*sosq0/(-1*entropy0);
StartRegLamda = 1000;
REGLAMDA = StartRegLamda;
CurrentRegLamda = REGLAMDA;

PLOTINFOSTRING = ['ME, lamda = ' num2str(0.001*floor(1000*CurrentRegLamda))];

%optimize distribution:
NMEXFUNCOUNT = 0; MEXDISTRIBUTIONARRAY = []; HOLDRMSD = [];nmexfunphase = 0;
nfuncs = 5000;
pack;
[parameter,sosq] = lsqnonlin(@MEmexlsqlogMLTransFunFixNOB,parameter,[],[],options,...
                ODETstruct,theosignalmats,signalmats,fitlog10ktransport,konvec,koffvec,fitlimits,tcontact,concs,ndattotal,BaselineInfo,t0times);
distribution = exp(parameter(1:nFitDistParams));
Baselines = BASELINES;%parameter((nFitDistParams+1):(nFitDistParams+nBaselines));
plotparameters = [distribution Baselines t0times fitlog10ktransport];
mexplotresultstrans;

REGLAMDA = 0;
rmsdtmp = MEmexlsqlogMLTransFunFixNOB(parameter,ODETstruct,theosignalmats,signalmats,fitlog10ktransport,konvec,koffvec,fitlimits,tcontact,concs,ndattotal,BaselineInfo,t0times);
sosqtmp = rmsdtmp*rmsdtmp';
logdistribution = parameter(1:nFitDistParams); distribution = exp(logdistribution);
entropytmp = -logdistribution*distribution';

ConfidenceLevel = 0.95;
ConfidenceSInc = finv(ConfidenceLevel,length(rmsdtmp),length(rmsdtmp));
% 



newrmsd = plotrmsd;
criticalrmsdinc = sqrt(ConfidenceSInc);
oldrmsd = 2*newrmsd*criticalrmsdinc;

% 
% desiredsosqfact = 2;
% desiredsosqfact = ConfidenceSInc;

while newrmsd < oldrmsd/criticalrmsdinc,
%     %remove all zeros
%     tmpsol = distribution;
%     makeuniformfract = 0.1; 
%     tmpdistribution = ((1-makeuniformfract)*tmpsol') + sum(tmpsol)*makeuniformfract/(length(tmpsol));
%     logtmpsol = log(tmpdistribution);logtmpsol = logtmpsol';
%     distribution = tmpsol;
%     logdistribution = logtmpsol;
%     parameter = [logdistribution Baselines];
%     plotparameters = [distribution Baselines t0times fitlog10ktransport];
%     mexplotresultstrans;
    %decrease regularization constraint:
    
  
    CurrentRegLamda = 0.1*CurrentRegLamda;
    REGLAMDA = CurrentRegLamda;
    PLOTINFOSTRING = ['ME, lamda = ' num2str(0.001*floor(1000*CurrentRegLamda))];
    NMEXFUNCOUNT = 0; MEXDISTRIBUTIONARRAY = []; HOLDRMSD = [];nmexfunphase = 0;
    nfuncs = 5000;
    pack;
    [parameter,sosq] = lsqnonlin(@MEmexlsqlogMLTransFunFixNOB,parameter,[],[],options,...
        ODETstruct,theosignalmats,signalmats,fitlog10ktransport,konvec,koffvec,fitlimits,tcontact,concs,ndattotal,BaselineInfo,t0times);
    distribution = exp(parameter(1:nFitDistParams));
    Baselines = BASELINES;%parameter((nFitDistParams+1):(nFitDistParams+nBaselines));
    plotparameters = [distribution Baselines t0times fitlog10ktransport];
    mexplotresultstrans;
    oldrmsd = newrmsd;
    newrmsd = plotrmsd;
    REGLAMDA = 0;
    rmsdtmp = MEmexlsqlogMLTransFunFixNOB(parameter,ODETstruct,theosignalmats,signalmats,fitlog10ktransport,konvec,koffvec,fitlimits,tcontact,concs,ndattotal,BaselineInfo,t0times);
    sosqtmp = rmsdtmp*rmsdtmp';
    logdistribution = parameter(1:nFitDistParams); distribution = exp(logdistribution);
    entropytmp = -logdistribution*distribution';
    save tmp.mat;
    entropytmp;
    
end;


criticalrmsd = 1.07*criticalrmsdinc;
while newrmsd < criticalrmsd,
%     %remove all zeros
%     tmpsol = distribution;
%     makeuniformfract = 0.1; 
%     tmpdistribution = ((1-makeuniformfract)*tmpsol') + sum(tmpsol)*makeuniformfract/(length(tmpsol));
%     logtmpsol = log(tmpdistribution);logtmpsol = logtmpsol';
%     distribution = tmpsol;
%     logdistribution = logtmpsol;
%     parameter = [logdistribution Baselines];
%     plotparameters = [distribution Baselines t0times fitlog10ktransport];
%     mexplotresultstrans;
    %decrease regularization constraint:
    
  
    CurrentRegLamda = 2*CurrentRegLamda;
    REGLAMDA = CurrentRegLamda;
    PLOTINFOSTRING = ['ME, lamda = ' num2str(0.001*floor(1000*CurrentRegLamda))];
    NMEXFUNCOUNT = 0; MEXDISTRIBUTIONARRAY = []; HOLDRMSD = [];nmexfunphase = 0;
    nfuncs = 5000;
    pack;
    [parameter,sosq] = lsqnonlin(@MEmexlsqlogMLTransFunFixNOB,parameter,[],[],options,...
        ODETstruct,theosignalmats,signalmats,fitlog10ktransport,konvec,koffvec,fitlimits,tcontact,concs,ndattotal,BaselineInfo,t0times);
    distribution = exp(parameter(1:nFitDistParams));
    Baselines = BASELINES;%parameter((nFitDistParams+1):(nFitDistParams+nBaselines));
    plotparameters = [distribution Baselines t0times fitlog10ktransport];
    mexplotresultstrans;
    oldrmsd = newrmsd;
    newrmsd = plotrmsd;
    REGLAMDA = 0;
    rmsdtmp = MEmexlsqlogMLTransFunFixNOB(parameter,ODETstruct,theosignalmats,signalmats,fitlog10ktransport,konvec,koffvec,fitlimits,tcontact,concs,ndattotal,BaselineInfo,t0times);
    sosqtmp = rmsdtmp*rmsdtmp';
    logdistribution = parameter(1:nFitDistParams); distribution = exp(logdistribution);
    entropytmp = -logdistribution*distribution';
    save tmp.mat;
    entropytmp;
    
end;



criticalrmsd = 1.07*criticalrmsdinc;
while newrmsd > criticalrmsd,
%     %remove all zeros
%     tmpsol = distribution;
%     makeuniformfract = 0.1; 
%     tmpdistribution = ((1-makeuniformfract)*tmpsol') + sum(tmpsol)*makeuniformfract/(length(tmpsol));
%     logtmpsol = log(tmpdistribution);logtmpsol = logtmpsol';
%     distribution = tmpsol;
%     logdistribution = logtmpsol;
%     parameter = [logdistribution Baselines];
%     plotparameters = [distribution Baselines t0times fitlog10ktransport];
%     mexplotresultstrans;
    %decrease regularization constraint:
    
  
    CurrentRegLamda = 0.5*CurrentRegLamda;
    REGLAMDA = CurrentRegLamda;
    PLOTINFOSTRING = ['ME, lamda = ' num2str(0.001*floor(1000*CurrentRegLamda))];
    NMEXFUNCOUNT = 0; MEXDISTRIBUTIONARRAY = []; HOLDRMSD = [];nmexfunphase = 0;
    nfuncs = 10000;
    options = optimset('Display', 'iter', 'MaxFunEvals', nfuncs, 'DiffMinChange', 1e-3,'LargeScale', 'off','TolCon', 1e-6,'TolFun', 1e-3, 'TolX', 1e-4,'LevenbergMarquardt', 'on');
    pack;
    [parameter,sosq] = lsqnonlin(@MEmexlsqlogMLTransFunFixNOB,parameter,[],[],options,...
        ODETstruct,theosignalmats,signalmats,fitlog10ktransport,konvec,koffvec,fitlimits,tcontact,concs,ndattotal,BaselineInfo,t0times);
    distribution = exp(parameter(1:nFitDistParams));
    Baselines = BASELINES;%parameter((nFitDistParams+1):(nFitDistParams+nBaselines));
    plotparameters = [distribution Baselines t0times fitlog10ktransport];
    mexplotresultstrans;
    oldrmsd = newrmsd;
    newrmsd = plotrmsd;
    REGLAMDA = 0;
    rmsdtmp = MEmexlsqlogMLTransFunFixNOB(parameter,ODETstruct,theosignalmats,signalmats,fitlog10ktransport,konvec,koffvec,fitlimits,tcontact,concs,ndattotal,BaselineInfo,t0times);
    sosqtmp = rmsdtmp*rmsdtmp';
    logdistribution = parameter(1:nFitDistParams); distribution = exp(logdistribution);
    entropytmp = -logdistribution*distribution';
    save tmp.mat;
    entropytmp;
    
end;


