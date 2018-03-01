function d = dspace(latpar, hkl)
%DSPACE      calculates plane spacing for a given lattice
%  D = DSPACE(LATPAR, HKL)  LATPAR can be a compound function
%  describing crystal unit cell or vector abcABG of necessary
%  lattice parameters. HKL is Nx3 matrix of Miller indices

%  1999 Pavol
%  $Id: dspace.m 26 2007-02-27 22:45:38Z juhas $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if length(hkl)==1
   if hkl<=999 & hkl>0
	l=rem(hkl, 10);
	k=rem(hkl-l, 100)/10;
	h=(hkl-l-10*k)/100;
	hkl=[h k l];
   else
	error('Cannot understand hkl argument');
   end
end

if size(hkl,2)~=3
    error('HKL must be Nx3 matrix')
end

if isstr(latpar)
    if exist(latpar)==0
	error('Specified latpar not found');
    end
    latpar=feval(latpar, 'abc');
else
    latpar=(latpar(:))';
    len=length(latpar);
    if len==0
	latpar=[1 1 1 90  90 90]
    elseif len==1
	latpar=[latpar latpar latpar 90 90 90];
    elseif len==2
	latpar=[latpar(1) latpar 90 90 90];
    elseif len==3
	latpar=[latpar 90 90 90];
    elseif len==4
	latpar=[latpar(1:3) 90 latpar(4) 90];
    elseif len==5
	latpar=[latpar 90];
    else
	latpar=latpar(1:6);
    end
end

latpar(4:6)=latpar(4:6)*pi/180;
alpha=latpar(4);beta=latpar(5);gamma=latpar(6);
a=latpar(1);b=latpar(2);c=latpar(3);

%Ref.: Warren X-ray diffraction, chapter 2.5
h=hkl(:,1); k=hkl(:,2); l=hkl(:,3);
sa=sin(alpha); sb=sin(beta); sg=sin(gamma);
ca=cos(alpha); cb=cos(beta); cg=cos(gamma);

d2i = 1 ./ (1 + 2*ca*cb*cg - ca^2 -cb^2 -cg^2) .* ...
    ( h.^2*sa^2/a^2 + k.^2*sb^2/b^2 + l.^2*sg^2/c^2 + ...
      2.*h.*k/(a*b) * (ca*cb-cg) + ...
      2.*k.*l/(b*c) * (cb*cg-ca) + ...
      2.*l.*h/(c*a) * (cg*ca-cb) );
d=sqrt(1./d2i);
