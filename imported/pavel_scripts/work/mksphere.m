% MKSPHERE    create N random xyz positions of atoms inside sphere with
%     specified minimum bondlength.

% number of atoms
if ~exist('N', 'var')
    N = 60;
end
% box size
if ~exist('L', 'var')
    L = 10;
end
% minimum bond length
if ~exist('minblen', 'var')
    minblen = 1.15;
end
% maximum distance of atoms (sphere diameter)
if ~exist('maxdist', 'var')
    maxdist = 7.3;
end
% maximum number of trials
Ctrial = 500;
fprintf('N=%g\nL=%g\nminblen=%g\nmaxdist=%g\nCtrial=%g\n', ...
    N, L, minblen, maxdist, Ctrial);

xyz = [];
t=1;
oldmore = get(0, 'More'); more off;
while t<=Ctrial & size(xyz,1)<N
    t = t+1;
    % make twice as many so that enough of them are inside the sphere
    rv = maxdist*(rand(2*N,3) - 0.5);
    ra = sqrt(sum(rv.^2,2));
    rv(ra>maxdist/2,:) = [];
    if isempty(xyz)
        xyz(1,:) = rv(1,:);
        fprintf('%6.0i', size(xyz,1));
        rv(1,:) = [];
    end
    for j=1:length(rv)
        rc = rv(j,:);
        rd = sqrt( sum((xyz - rc(ones(1,size(xyz,1)),:)).^2, 2) );
        if all(rd > minblen)
            xyz = [xyz; rc];
            fprintf('%6.0i', size(xyz,1));
            if rem(size(xyz,1),12) == 0
                fprintf('\n');
            end
            if size(xyz,1) >= N
                xyz = xyz(1:N,:);
                fprintf('\n');
                break;
            end
        end
    end
end

xyz = xyz + L/2;
if size(xyz,1) < N
    fprintf('sorry only %i atoms found\n', size(xyz,1));
    plainstru = '';
    return;
else
    disp('success! See plainstru variable')
end
set(0, 'More', oldmore);

plainstru = [
sprintf('title    %i randomly placed atoms, minblen=%.2f, maxdist=%.2f\n',...
    N, minblen, maxdist), ...
sprintf('natoms   %i\n', N), ...
sprintf('format   plain\n'), ...
sprintf('xyzLims  %.4f%10.4f%10.4f%10.4f%10.4f%10.4f\n', 0, L, 0, L, 0, L), ...
sprintf('atom     x            y            z            o          Uiso       b(fm)\n'), ...
sprintf('C     %13.8f%13.8f%13.8f%11.6f%11.6f%11.6f\n', ...
    [xyz, ones(N,1), 0.002*ones(N,1), 6.646*ones(N,1)]'), ...
];

xyz0 = xyz - ones(size(xyz,1),1)*mean(xyz);
