function [A,I] = bangles(D,maxblen)
% BANGLES     get bond angles from distance matrix
%     [A,I] = BANGLES(D,MAXBLEN)  calculate bond angles in degrees from
%     distance matrix D using bond length cutoff MAXBLEN.  Return column
%     vector of angles A and point indices [neighbor1,center,neighbor2]
%     in Nx3 matrix I
%
%  See also DISTMX

%  $Id: bangles.m 26 2007-02-27 22:45:38Z juhas $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

A = [];
I = [];
isbond = (0.0 < D & D < maxblen);
% get coordination of every atom
zn = sum(isbond);
for center = find(zn > 1)
    ligidx = find(isbond(:,center));
    for i = (1:length(ligidx))
        for j = (i+1:length(ligidx))
            neighbor1 = ligidx(i);
            neighbor2 = ligidx(j);
            blen1 = D(center,neighbor1);
            blen2 = D(center,neighbor2);
            dneib = D(neighbor1,neighbor2);
            angle = acosd( (blen1^2 + blen2^2 - dneib^2) / (2*blen1*blen2) );
            A(end+1,1) = angle;
            I(end+1,:) = [neighbor1,center,neighbor2];
        end
    end
end
