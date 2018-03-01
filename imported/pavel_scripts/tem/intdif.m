function hkli=intdif(compound,hkl)
%INTDIF    calculates electron difraction intensities
%	   HKLI=INTDIF(COMPOUND, HKL) returns 4-column matrix filled
%	   with diffraction indexes hkl and corresponding intensities
%	   HKL is 3-column matrix of diffraction indexes
%	   COMPOUND is function describing crystal unit cell

% 1997 by Pavol

if exist(compound)==0
	error('Specified compound not found');
end
if nargin==1
	[h,k,l]=meshgrid(0:4,0:4,0:4);
	h=h(:); k=k(:); l=l(:);
	hkl=[h,k,l];
elseif max(size(hkl))==1
	[h,k,l]=meshgrid(0:hkl,0:hkl,0:hkl);
	h=h(:); k=k(:); l=l(:);
	hkl=[h,k,l];
elseif size(hkl,2) ~= 3
	error('HKL must be 3-column matrix');
end

els = feval(compound, 'elements');
ne = size(els,1);
nuly = zeros(1, size(hkl,1));
Int = nuly;
for i=1:ne
	el = deblank(els(i,:));
	[x,y,z]=feval(compound, el);
	Z = protno(el);
        Int=Int + Z*sum([nuly; exp( 2i*pi*( ([x,y,z]) * hkl' ))]);
end
Int=Int.*conj(Int);
hkli=[hkl, Int'];
