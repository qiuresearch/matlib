% particle sizes to test
Rvalues = 15:.25:25;
rlow = 1.3471;
load('data.data') ;
load('topogrnd.data') ;
load('CdSe15.gr');
r = data(:,1);
Gbulk = data(:,2);
Gtopo = topogrnd(:,2);
Gexp = CdSe15(:,2);

Gcorrall = [];
Rwall = [];
for R = Rvalues
    s = 1-1.5*(r/R)+0.5*(r/R).^3 ;
    s(r/R > 1) = 0;
    Gshapedbulk = s.*Gbulk;
    fitInterval = find(rlow < r);
    % mixing coefficients ab must be positive
    ab = lsqnonneg([ Gshapedbulk(fitInterval), Gtopo(fitInterval) ], Gexp(fitInterval));
    Gcorr = ab(1)*Gshapedbulk + ab(2)*Gtopo;
    Gcorrall = [Gcorrall, Gcorr];
    Rw = sqrt( sum( (Gcorr(fitInterval)-Gexp(fitInterval)).^2 ) / sum(Gexp(fitInterval).^2) );
    Rwall = [Rwall, Rw];
end

[ignore,best] = min(Rwall);

figure(1); clf
plot(Rvalues, Rwall);
xlabel('particle size');
ylabel('Rw');
title(sprintf('best Rw at R = %.2f', Rvalues(best)));

figure(2); clf
plot(r,[Gexp,Gbulk.*s*0.39+Gtopo*0.405, Gcorrall(:,best)])
hold on;
plot([rlow;rlow], ylim, 'k--');
Rvalues(best)
xlabel('r')
ylabel('G')
legend('experiment', 'Ahmad', 'best size'); 
