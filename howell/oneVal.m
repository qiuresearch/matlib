%function oneVal(i)
mySubplot;
d.data(i).title;
hold all;
xyplot(b.data(i).data);
xyplot(a.data(i).data);
xyplot(d.data(i).data);
title(regexprep(d.data(i).title,'_',' '));
legend({'before','after','difference'});
axis([200 400 -.08 .2]);