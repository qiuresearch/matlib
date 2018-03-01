function HKLTI=xrd(compound,N)
%XRD       Bragg angles for x-ray diffraction
%	   hklti=XRD(COMPOUND,N) returns 5-column matrix filled
%	   with diffraction indexes hkl and corresponding Bragg angles 
%	   (in degrees) and intensities up to the (NNN) (by default, N=4).
%	   COMPOUND is function describing crystal unit cell

% 1997 by Pavol

L=1.5418;	%Kalpha
if nargin==1
   N=4;
end
if exist(compound)==0
	error('Specified compound not found');
end

%Calculate intensities
hklti = feval('intdif', compound, N);
i = find(hklti(:,4)<5);
hklti(i,:) = [];
abcABG=feval(compound, 'abc');
if strcmp(abcABG, [[1 1 1]*abcABG(1), 90, 90, 90])
	%get rid off repeating indexes...
	i=find(hklti(:,2)<hklti(:,3));
	hklti(i,:) = [];
	i=find(hklti(:,1)<hklti(:,2));
	hklti(i,:) = [];
	hklti(:,5) = hklti(:,4);
end
%Calculate fundamental lattice vectors
a=abcABG; a(4:6)=a(4:6)*pi/180;
alpha=a(4);beta=a(5);gamma=a(6);
b=a(2);c=a(3);a=a(1);
a1=a * [1               0                                               0];
a2=b * [cos(gamma)      sin(gamma)                                      0];
a3=    [cos(beta)       (cos(alpha)-cos(beta)*cos(gamma))/sin(gamma)    0];
a3(3) = sqrt(1-a3*a3');
a3=c * a3;

%base vectors of reciprocal lattice
ainv=inv([a1;a2;a3]);   %columns of ainv are base vectors

%Bragg equation...
hkl=hklti(:,1:3);
g=hkl*ainv';
g=sqrt(g(:,1).^2 + g(:,2).^2 + g(:,3).^2);
theta = asin( L./2 * g );
i=find(imag(theta));
theta(i)=[]; hklti(i,:)=[];
[theta,i] = sort(180/pi*theta);
hklti=hklti(i,:);
hklti(:,4)=theta;
if nargout==1
	HKLTI=hklti;
else
	hklti=hklti';
	hklti(6,:)=hklti(5,:);
	hklti(5,:)=2*hklti(4,:);
	fprintf('\n\th\tk\tl\ttheta\t2*theta\t       Int\n');
	fprintf('\t--------------------------------------------------\n');
	fprintf('\t%.0f\t%.0f\t%.0f%12.2f\t%7.2f\t%10.0f\n', hklti);
end
