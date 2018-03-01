%plots of b1, b2 size/charge mismatches

xl = 0:.01:.25; xl=xl';
xh = .25:.01:1; xh=xh';
x = [xl;xh];
rSc=.745; rW=.6; rTi=.605; rZr=.72;
qSc=3; qW=6; qM=4;

%      Sc	    W		 M
y1 = [ (1-4*xl)/3   (2-2*xl)/3   2*xl
       0*xh	    (2-2*xh)/3   (2*xh+1)/3 ];
y2 = [ 0*xl+1       0*xl	 0*xl
       (4-4*xh)/3   0*xh	 (4*xh-1)/3 ];

for rM = [rTi rZr];
    qa = [qSc qW qM]';
    ra = [rSc rW rM]';
    q1 = y1 * qa;
    q2 = y2 * qa;
    r1 = y1 * ra;
    r2 = y2 * ra;
    dR = abs(r1 - r2);
    dQ = abs(q1 - q2);
    dr1 = sqrt( y1 * ra.^2  -  r1.^2 );
    dq1 = sqrt( y1 * qa.^2  -  q1.^2 );
    dr2 = sqrt( y2 * ra.^2  -  r2.^2 );
    dq2 = sqrt( y2 * qa.^2  -  q2.^2 );
    if rM==rTi
	dRTi = dR; dr1Ti = dr1; dr2Ti = dr2;
    else
	dRZr = dR; dr1Zr = dr1; dr2Zr = dr2;
    end
end
figure(clf);
ax1=subplot(221);
plot(x, dRZr, 'k-', x, dr1Zr, 'k--', x, dr2Zr, 'k:');
title('\Delta{}R, PSW-PZ')
ax2=subplot(222);
plot(x, dRTi, 'k-', x, dr1Ti, 'k--', x, dr2Ti, 'k:');
title('\Delta{}R, PSW-PT')
ax3=subplot 223;
plot(x, dQ, 'k-', x, dq1, 'k--', x, dq2, 'k:');
title('\Delta{}Q, PSW-PM')
ylim -.005 2.5
ylim([ax1 ax2], -.005, .15)
